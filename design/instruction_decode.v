module instruction_decode #(
) (
    input wire i_clk,
    input wire i_reset,
    input wire [31:0] i_pc4,
    input wire [31:0] i_instruction,

    input wire i_write_enable_WB,
    input wire [4:0] i_register_WB,
    input wire [31:0] i_data_WB,

    // senal de stall del detector de riesgos
    input wire i_stall,

    output reg [31:0] o_RA,
    output reg [31:0] o_RB,
    output reg [4:0] o_rs,
    output reg [4:0] o_rt,
    output reg [4:0] o_rd,
    output reg [5:0] o_funct,
    output reg [31:0] o_inmediato,
    output reg [5:0] o_opcode,
    output reg [25:0] o_addr,  // direccion de jump
    output reg [4:0] o_shamt,

    // senales de control
    output reg o_WB_write,  // si 1 la instruccion escribe en el banco de registros
    output reg o_WB_mem_to_reg,  // si 0 guardo el valor de MEM (load) sino el valor de ALU (tipo R)
    output reg o_MEM_read,  // si 1 leo la memoria de datos (LOAD)
    output reg o_MEM_write,  // si 1 escribo en la memoria de datos (STORE)
    output reg o_EX_alu_src,  // si 1 la segunda entrada de la ALU es el inmediato sino RB
    output reg o_EX_reg_dst,  // si 1 el destino (el registro que se escribe) rd sino rt
    output reg [1:0] o_EX_alu_op,  // indica el tipo de operacion (LOAD, STORE, R)

    // resultados de saltos y branches
    output wire [31:0] o_jump_addr,
    output reg o_jump
);

  wire [31:0] RA_wire;
  wire [31:0] RB_wire;

  wire [ 4:0] rs;
  wire [ 4:0] rt;
  wire [ 5:0] opcode;
  wire [31:0] inmediato;

  banco_registros #(
      .NB_REGISTER(32),
      .NB_ADDR(5)
  ) banco_registros1 (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_wr_enable(i_write_enable_WB),
      .i_w_addr(i_register_WB),
      .i_w_data(i_data_WB),
      .i_r_addr1(rs),
      .i_r_addr2(rt),
      .o_r_data1(RA_wire),
      .o_r_data2(RB_wire)
  );

  localparam OPCODE_TIPO_R = 6'b000000;
  localparam OPCODE_BEQ = 6'b000100;
  localparam OPCODE_BNE = 6'b000101;

  always @(posedge i_clk) begin : senales_WB
    if (i_stall) begin
      o_WB_write <= 1'b0;
      o_WB_mem_to_reg <= 1'b0;
    end else begin
      if (opcode == OPCODE_TIPO_R) begin
        // operacion tipo R
        o_WB_write <= 1'b1;
        o_WB_mem_to_reg <= 1'b1;
      end else if (opcode[5] == 1'b1 && opcode[3] == 1'b0) begin
        // operacion tipo LOAD
        o_WB_write <= 1'b1;
        o_WB_mem_to_reg <= 1'b0;
      end else begin
        // otras
        o_WB_write <= 1'b0;
        o_WB_mem_to_reg <= o_WB_mem_to_reg;  // no importa el valor
      end
    end
  end

  always @(posedge i_clk) begin : senales_MEM
    if (i_stall) begin
      o_MEM_read  <= 1'b0;
      o_MEM_write <= 1'b0;
    end else begin
      if (opcode[5] == 1'b1) begin
        // operacion tipo LOAD o STORE
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
  end

  always @(posedge i_clk) begin : senales_EX
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
        // operacion tipo R, se usa el funct
        o_EX_alu_op <= 2'b10;
      end else if (opcode[5] == 1'b1) begin
        // load o store
        // se tiene que hacer una suma en la ALU para la direccion
        o_EX_alu_op <= 2'b00;
      end else if (opcode[5:3] == 3'b001) begin
        // inmediatos que se tienen que identificar con el opcode
        o_EX_alu_op <= 2'b11;
      end else begin
        // otro
        o_EX_alu_op <= 2'b01;
      end
    end
  end

  always @(posedge i_clk) begin : instrccion
    // decoficacion de instruccion
    o_RA_reg <= RA_wire;  // valores del banco de registros
    o_RB_reg <= RB_wire;  // valores del banco de registros
    o_rs <= rs;
    o_rt <= rt;
    o_opcode <= opcode;
    o_rd <= i_instruction[15:11];
    o_funct <= i_instruction[5:0];
    o_inmediato <= inmediato;
    o_addr <= i_instruction[25:0];
    o_shamt <= i_instruction[10:6];
  end

  always @(*) begin : jump_condition
    case (opcode)
      OPCODE_BEQ: begin
        if (RA_wire == RB_wire) begin
          // se cumple la condicion
          o_jump = 1'b1;
        end else begin
          o_jump = 1'b0;
        end
      end
      OPCODE_BNE: begin
        if (RA_wire != RB_wire) begin
          // se cumple la condicion
          o_jump = 1'b1;
        end else begin
          o_jump = 1'b0;
        end
      end
      default: o_jump = 1'b0;
    endcase
  end

  assign rs = i_instruction[25:21];
  assign rt = i_instruction[20:16];
  assign opcode = i_instruction[31:26];
  assign inmediato = {{16{i_instruction[15]}}, i_instruction[15:0]};  // extension de signo
  assign o_jump_addr = i_pc4 + (inmediato << 2);

endmodule
