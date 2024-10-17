module instruction_decode #(
) (
    input wire i_clk,
    input wire i_reset,
    input wire [31:0] i_pc4,
    input wire [31:0] i_instruction,

    input wire i_write_enable_WB,
    input wire [4:0] i_register_WB,
    input wire [31:0] i_data_WB,

    output reg [31:0] o_RA,
    output reg [31:0] o_RB,
    output reg [4:0] o_rs,
    output reg [4:0] o_rt,
    output reg [4:0] o_rd,
    output reg [5:0] o_funct,
    output reg [15:0] o_inmediato,
    output reg [5:0] o_opcode,
    output reg [25:0] o_addr,  // direccion de jump
    output reg [4:0] o_shamt,

    // senales de control
    output reg o_WB_write,  // si 1 la instruccion escribe en el banco de registros
    output reg o_WB_mem_to_reg,  // si 0 guardo el valor de ALU sino el valor de MEM (store)
    output reg o_MEM_read,  // si 1 leo la memoria de datos (LOAD)
    output reg o_MEM_write,  // si 1 escribo en la memoria de datos (STORE)
    output reg o_EX_alu_src,  // si 1 la segunda entrada de la ALU es el inmediato sino RB
    output reg o_EX_reg_dst,  // si 1 el destino (el registro que se escribe) rt sino rd
    output reg o_EX_alu_op
);

  wire [31:0] RA_wire;
  wire [31:0] RB_wire;

  wire [ 4:0] rs;
  wire [ 4:0] rt;

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

  // TODO: MANEJAR SENALES DE CONTROL
  // TODO: MANEJAR SENALES DE CONTROL
  // TODO: MANEJAR SENALES DE CONTROL
  // TODO: MANEJAR SENALES DE CONTROL

  always @(posedge i_clk) begin
    o_RA_reg <= RA_wire;
    o_RB_reg <= RB_wire;
    o_rs <= rs;
    o_rt <= rt;
    o_rd <= i_instruction[15:11];
    o_funct <= i_instruction[5:0];
    o_inmediato <= i_instruction[15:0];
    o_opcode <= i_instruction[31:26];
    o_addr <= i_instruction[25:0];
    o_shamt <= i_instruction[10:6];
  end

  assign rs = i_instruction[25:21];
  assign rt = i_instruction[20:16];

endmodule
