module instruction_execute (
    input wire i_clk,
    input wire i_reset,
    input wire [31:0] i_RA,
    input wire [31:0] i_RB,
    input wire [4:0] i_rs,
    input wire [4:0] i_rt,
    input wire [4:0] i_rd,
    input wire [5:0] i_funct,
    input wire [31:0] i_inmediato,
    input wire [5:0] i_opcode,
    input wire [25:0] i_addr,  // direccion de jump
    input wire [4:0] i_shamt,

    // senales de control
    input wire i_WB_write,  // si 1 la instruccion escribe en el banco de registros
    input wire i_WB_mem_to_reg,  // si 0 guardo el valor de MEM (load) sino el valor de ALU (tipo R)
    input wire i_MEM_read,  // si 1 leo la memoria de datos (LOAD)
    input wire i_MEM_write,  // si 1 escribo en la memoria de datos (STORE)
    input wire i_EX_alu_src,  // si 1 la segunda entrada de la ALU es el inmediato sino RB
    input wire i_EX_reg_dst,  // si 1 el destino (el registro que se escribe) rd sino rt
    input wire [1:0] i_EX_alu_op,  // indica el tipo de operacion (LOAD, STORE, R)

    // senales de unidad de cortocircuito
    input wire [1:0] i_corto_rs,  // RS -> alu data A
    input wire [1:0] i_corto_rt,  // RT -> alu data B
    input wire [31:0] i_input_ALU_MEM,
    input wire [31:0] i_output_WB,

    // senales de control (output)
    output reg o_WB_write,  // si 1 la instruccion escribe en el banco de registros
    output reg o_WB_mem_to_reg,  // si 0 guardo el valor de MEM (load) sino el valor de ALU (tipo R)
    output reg o_MEM_read,  // si 1 leo la memoria de datos (LOAD)
    output reg o_MEM_write,  // si 1 escribo en la memoria de datos (STORE)

    // salidas
    output reg [4:0] o_write_reg,  // registro de destino donde se escriben los resultados en WB
    output reg [31:0] o_data_to_write_in_MEM,  // data a escribir en memoria
    output reg [31:0] o_ALU_result
);

  reg signed  [31:0] ALU_data_A;
  reg signed  [31:0] ALU_data_B;
  reg signed  [31:0] ALU_cortocircuito_B;
  reg signed  [ 5:0] ALU_op;  // revisar
  wire signed [31:0] ALU_result_wire;

  localparam ADD_OP = 6'b100000;
  localparam IDLE_OP = 6'b111111;

  always @(*) begin : alu_control
    case (i_EX_alu_op)
      2'b00: begin
        // load o store
        // se tiene que hacer una suma en la ALU para la direccion
        ALU_op = ADD_OP;
      end
      2'b01: begin
        // es un branch (se resuelve en decode)
        ALU_op = IDLE_OP;
      end
      2'b10: begin
        // tipo R, tomar el funct
        ALU_op = i_funct;
      end
      2'b11: begin
        // operaciones con inmediatos, se tienen que identificar con el opcode
        ALU_op = i_opcode;
      end
      default: begin
        ALU_op = IDLE_OP;
      end
    endcase
  end

  always @(*) begin : mux_cortocircuito_A
    case (i_corto_rs)
      2'b00:   ALU_data_A = i_RA;  // del banco de registros
      2'b01:   ALU_data_A = i_output_WB;  // del WB
      2'b10:   ALU_data_A = i_input_ALU_MEM;  // ALU result de la etapa de MEM
      default: ALU_data_A = 0;
    endcase
  end


  always @(*) begin : mux_cortocircuito_y_alu_src_B
    if (i_EX_alu_src) begin
      ALU_data_B = i_inmediato;
    end else begin
      case (i_corto_rs)
        2'b00:   ALU_cortocircuito_B = i_RB;  // del banco de registros
        2'b01:   ALU_cortocircuito_B = i_output_WB;  // del WB
        2'b10:   ALU_cortocircuito_B = i_input_ALU_MEM;  // ALU result de la etapa de MEM
        default: ALU_cortocircuito_B = 0;
      endcase
      ALU_data_B = ALU_cortocircuito_B;
    end
  end

  always @(posedge i_clk) begin : mux_reg_dst
    if (i_reset) begin
      o_write_reg <= 5'b0;
    end else begin
      o_write_reg <= i_EX_reg_dst ? i_rd : i_rt;
    end
  end

  always @(posedge i_clk) begin : senales_de_control
    if (i_reset) begin
      o_WB_write <= 1'b0;
      o_WB_mem_to_reg <= 1'b0;
      o_MEM_read <= 1'b0;
      o_MEM_write <= 1'b0;
    end else begin
      o_WB_write <= i_WB_write;
      o_WB_mem_to_reg <= i_WB_mem_to_reg;
      o_MEM_read <= i_MEM_read;
      o_MEM_write <= i_MEM_write;
    end
  end

  always @(posedge i_clk) begin : alu_result
    if (i_reset) begin
      o_ALU_result <= 32'b0;
      o_data_to_write_in_MEM <= 32'b0;  // data to write in MEM
    end else begin
      o_ALU_result <= ALU_result_wire;
      o_data_to_write_in_MEM <= ALU_cortocircuito_B;  // data to write in MEM
    end
  end

  alu #(
      .NB_OP  (6),
      .NB_DATA(32)
  ) alu1 (
      .i_op(ALU_op),
      .i_data_A(ALU_data_A),
      .i_data_B(ALU_data_B),
      .i_shamt(i_shamt),
      .o_data()
  );

endmodule
