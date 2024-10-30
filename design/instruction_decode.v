module instruction_decode (
    input wire i_clk,
    input wire i_reset,
    input wire [31:0] i_pc4,
    input wire [31:0] i_instruction,

    input wire i_write_enable_WB,
    input wire [4:0] i_register_WB,
    input wire [31:0] i_data_WB,

    // senal de stall del detector de riesgos
    input wire i_stall,

    // halt, de la debug unit o de la instruccion HALT, no continuar con la ejecucion
    input wire i_halt,

    output reg [31:0] o_RA,
    output reg [31:0] o_RB,
    output reg [ 4:0] o_rs,
    output reg [ 4:0] o_rt,
    output reg [ 4:0] o_rd,
    output reg [ 5:0] o_funct,
    output reg [31:0] o_inmediato,
    output reg [ 5:0] o_opcode,
    output reg [ 4:0] o_shamt,

    // senales de control
    output reg o_WB_write,  // si 1 la instruccion escribe en el banco de registros
    output reg o_WB_mem_to_reg,  // si 0 guardo el valor de MEM (load) sino el valor de ALU (tipo R)
    output reg o_MEM_read,  // si 1 leo la memoria de datos (LOAD)
    output reg o_MEM_write,  // si 1 escribo en la memoria de datos (STORE)
    output reg o_EX_alu_src,  // si 1 la segunda entrada de la ALU es el inmediato sino RB
    output reg o_EX_reg_dst,  // si 1 el destino (el registro que se escribe) rd sino rt
    output reg [1:0] o_EX_alu_op,  // indica el tipo de operacion (LOAD, STORE, R)
    output reg o_MEM_unsigned,  // 1 unsigned 0 signed
    output reg [1:0] o_MEM_byte_half_word,  // 00 byte, 01 half word, 11 word

    // resultados de saltos y branches
    output reg [31:0] o_jump_addr,
    output reg o_jump,
    output reg [1:0] o_salto_con_registro,  // 00 no salto, 01 salto usando rs y rt (BEQ, BNE),
                                            // 10 salto usando rs (JR, JALR)

    output wire o_halt,
    // para debug unit
    input wire [4:0] i_r_addr,
    output wire [31:0] o_r_data

);

  wire [31:0] RA_wire;
  wire [31:0] RB_wire;
  wire [5:0] funct_wire;

  wire [4:0] rs;
  wire [4:0] rt;
  wire [5:0] opcode;
  wire [31:0] inmediato;

  wire [4:0] reg_rs_to_read;

  wire write_enable;
  banco_registros #(
      .NB_REGISTER(32),
      .NB_ADDR(5)
  ) banco_registros1 (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_wr_enable(write_enable),
      .i_w_addr(i_register_WB),
      .i_w_data(i_data_WB),
      .i_r_addr1(reg_rs_to_read),
      .i_r_addr2(rt),
      .o_r_data1(RA_wire),
      .o_r_data2(RB_wire)
  );

  localparam NOP = 32'h00000000;
  localparam HALT = 32'hffffffff;
  localparam OPCODE_TIPO_R = 6'b000000;
  localparam OPCODE_BEQ = 6'b000100;
  localparam OPCODE_BNE = 6'b000101;

  // jumps
  localparam OPCODE_JUMP = 6'b000010;  // pc <- {pc[31:28], addr, 2'b00}
  localparam OPCODE_JAL = 6'b000011;  // jump and link: guarda la direccion de retorno en reg 31
  localparam FUNCT_JR = 6'b001000;  // pc <- rs
  localparam FUNCT_JALR = 6'b001001;  // jump and link reg: guarda la direccion de retorno en rd

  always @(posedge i_clk) begin : senales_WB
    if (i_reset) begin
      o_WB_write <= 1'b0;
      o_WB_mem_to_reg <= 1'b0;
    end else begin
      if (!i_halt) begin  // solo avanzar si no estoy en halt
        if (i_stall || NOP == i_instruction) begin
          o_WB_write <= 1'b0;
          o_WB_mem_to_reg <= 1'b0;
        end else begin
          if (opcode == OPCODE_TIPO_R || opcode == OPCODE_JAL) begin
            // operacion tipo R
            if (funct_wire == FUNCT_JR) begin  // JR no escribe en los registros
              o_WB_write <= 1'b0;
              o_WB_mem_to_reg <= 1'b0;
            end else begin
              o_WB_write <= 1'b1;
              o_WB_mem_to_reg <= 1'b1;
            end
          end else if (opcode[5] == 1'b1 && opcode[3] == 1'b0) begin
            // operacion tipo LOAD
            o_WB_write <= 1'b1;
            o_WB_mem_to_reg <= 1'b0;
          end else if (opcode[5:3] == 3'b001) begin
            // operacion tipo inmediato
            o_WB_write <= 1'b1;
            o_WB_mem_to_reg <= 1'b1;
          end else begin
            // otras
            o_WB_write <= 1'b0;
            o_WB_mem_to_reg <= o_WB_mem_to_reg;  // no importa el valor
          end
        end
      end else begin
        o_WB_write <= 1'b0;
        o_WB_mem_to_reg <= 1'b0;
      end
    end
  end

  always @(posedge i_clk) begin : senales_MEM
    if (i_reset) begin
      o_MEM_read <= 1'b0;
      o_MEM_write <= 1'b0;
      o_MEM_unsigned <= 1'b0;  // 1 unsigned 0 signed
      o_MEM_byte_half_word <= 2'b00;  // 00 byte, 01 half word, 11 word
    end else begin
      if (!i_halt) begin
        if (i_stall) begin
          o_MEM_read <= 1'b0;
          o_MEM_write <= 1'b0;
          o_MEM_unsigned <= 1'b0;  // 1 unsigned 0 signed
          o_MEM_byte_half_word <= 2'b00;  // 00 byte, 01 half word, 11 word
        end else begin
          if (opcode[5] == 1'b1) begin
            // operacion tipo LOAD o STORE
            o_MEM_unsigned <= opcode[2];  // 1 unsigned 0 signed
            o_MEM_byte_half_word <= opcode[1:0];  // 00 byte, 01 half word, 11 word
            if (opcode[3] == 1'b1) begin
              // operacion tipo STORE
              o_MEM_read  <= 1'b0;
              o_MEM_write <= 1'b1;
            end else begin
              // operacion tipo LOAD
              o_MEM_read  <= 1'b1;
              o_MEM_write <= 1'b0;
            end
          end else begin
            // otras
            o_MEM_read  <= 1'b0;
            o_MEM_write <= 1'b0;
          end
        end
      end else begin
        o_MEM_read  <= 1'b0;
        o_MEM_write <= 1'b0;
      end
    end
  end

  always @(posedge i_clk) begin : senales_EX
    if (i_reset) begin
      o_EX_reg_dst <= 1'b0;
      o_EX_alu_src <= 1'b0;
      o_EX_alu_op  <= 2'b00;
    end else begin
      if (!i_halt) begin
        if (i_stall) begin
          o_EX_reg_dst <= 1'b0;
          o_EX_alu_src <= 1'b0;
          o_EX_alu_op  <= 2'b00;
        end else begin
          if (opcode == OPCODE_TIPO_R) begin
            o_EX_reg_dst <= 1'b1;  // registro destino rd
            o_EX_alu_src <= 1'b0;
          end else begin
            o_EX_reg_dst <= 1'b0;  // registro de destino rt
            o_EX_alu_src <= 1'b1;
          end

          if (opcode == OPCODE_TIPO_R) begin
            if (funct_wire == FUNCT_JALR) begin
              // operacion de JALR, 00 para que haga la suma de pc4 + 4
              o_EX_alu_op <= 2'b00;
            end else begin
              // operacion tipo R, se usa el funct
              o_EX_alu_op <= 2'b10;
            end
          end else if (opcode[5] == 1'b1) begin
            // load o store
            // se tiene que hacer una suma en la ALU para la direccion
            o_EX_alu_op <= 2'b00;
          end else if (opcode[5:3] == 3'b001) begin
            // inmediatos que se tienen que identificar con el opcode
            o_EX_alu_op <= 2'b11;
          end else if (opcode == OPCODE_JAL) begin
            // operacion de JALR, 00 para que haga la suma de pc4 + 4
            o_EX_alu_op <= 2'b00;
          end else begin
            // otro
            o_EX_alu_op <= 2'b01;
          end
        end
      end else begin
        o_EX_reg_dst <= 1'b0;
        o_EX_alu_src <= 1'b0;
        o_EX_alu_op  <= 2'b00;
      end
    end
  end

  always @(posedge i_clk) begin : instrccion
    if (i_reset) begin
      o_RA <= 0;
      o_RB <= 0;
      o_rs <= 0;
      o_rt <= 0;
      o_opcode <= 0;
      o_rd <= 0;
      o_funct <= 0;
      o_inmediato <= 0;
      o_shamt <= 0;
    end else begin
      if (!i_halt) begin
        // decoficacion de instruccion
        if (opcode == OPCODE_JAL || (opcode == OPCODE_TIPO_R && funct_wire == FUNCT_JALR)) begin
          // en RA va la direccion de retorno a la que hay que sumarle 4
          o_RA <= i_pc4;
          o_rs <= 0;  // para que no haya cortocircuito
          // en RB va 4
          o_RB <= 4;
        end else begin
          o_RA <= RA_wire;  // valores del banco de registros
          o_rs <= rs;
          o_RB <= RB_wire;  // valores del banco de registros
        end

        if (opcode == OPCODE_JAL) begin
          o_rt <= 5'b11111;  // registro 31
        end else begin
          o_rt <= rt;
        end

        o_opcode <= opcode;
        o_rd <= i_instruction[15:11];
        o_funct <= funct_wire;
        o_inmediato <= inmediato;
        o_shamt <= i_instruction[10:6];
      end
    end
  end

  always @(*) begin : jump
    o_jump_addr = 0;
    o_jump = 1'b0;
    o_salto_con_registro = 2'b00;  // no salto
    case (opcode)
      OPCODE_BEQ: begin
        if (RA_wire == RB_wire) begin
          o_jump = 1'b1;  // se cumple la condicion
          o_jump_addr = i_pc4 + (inmediato << 2);
          o_salto_con_registro = 2'b01;  // salto usando rs y rt
        end
      end
      OPCODE_BNE: begin
        if (RA_wire != RB_wire) begin
          o_jump = 1'b1;  // se cumple la condicion
          o_jump_addr = i_pc4 + (inmediato << 2);
          o_salto_con_registro = 2'b01;  // salto usando rs y rt
        end
      end
      OPCODE_JUMP: begin
        o_jump = 1'b1;
        o_jump_addr = {i_pc4[31:28], i_instruction[25:0], 2'b00};
      end
      OPCODE_JAL: begin
        o_jump = 1'b1;
        o_jump_addr = {i_pc4[31:28], i_instruction[25:0], 2'b00};
      end
      OPCODE_TIPO_R: begin
        if (funct_wire == FUNCT_JR || funct_wire == FUNCT_JALR) begin
          o_jump = 1'b1;
          o_jump_addr = RA_wire;  // PC <- RS
          o_salto_con_registro = 2'b10;  // salto usando rs
        end
      end
      default: o_jump = 1'b0;
    endcase
  end

  assign rs = i_instruction[25:21];
  assign rt = i_instruction[20:16];
  assign opcode = i_instruction[31:26];
  assign inmediato = {{16{i_instruction[15]}}, i_instruction[15:0]};  // extension de signo
  assign o_halt = (i_instruction == HALT);
  assign funct_wire = i_instruction[5:0];

  assign o_r_data = RA_wire;
  assign reg_rs_to_read = i_halt ? i_r_addr : rs;
  assign write_enable = i_write_enable_WB & ~i_halt;

endmodule
