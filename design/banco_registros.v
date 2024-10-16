module banco_registros #(
    parameter NB_REGISTER = 32,
    parameter NB_ADDR = 5
) (
    input wire i_clk,
    input wire i_wr_enable,
    input wire [NB_ADDR-1:0] i_w_addr,
    input wire [NB_REGISTER-1:0] i_w_data,
    input wire [NB_ADDR-1:0] i_r_addr1,
    input wire [NB_ADDR-1:0] i_r_addr2,
    output wire [NB_REGISTER-1:0] o_r_data1,
    output wire [NB_REGISTER-1:0] o_r_data2
);

  // banco de registros (2**NB_ADDR registros de NB_REGISTER bits cada uno)
  reg [NB_REGISTER-1:0] registers[2**NB_ADDR-1:0];

  // escribo en flanco de bajada del clock
  always @(negedge i_clk) begin
    if (i_wr_enable) begin
      registers[i_w_addr] <= i_w_data;
    end
  end

  // asignacion de salidas
  assign o_r_data1 = registers[i_r_addr1];
  assign o_r_data2 = registers[i_r_addr2];

endmodule
