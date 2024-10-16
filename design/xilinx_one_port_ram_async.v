module xilinx_one_port_ram_async #(
    parameter ADDR_WIDTH = 12,  // 4K direcciones
    parameter DATA_WIDTH = 32   // 32 bit data
) (
    input wire i_clk,
    input wire i_write_enable,
    input wire [ADDR_WIDTH-1:0] i_addr,
    input wire [DATA_WIDTH-1:0] i_data,
    output wire [DATA_WIDTH-1:0] o_data
);

  // memoria de 2**ADDR_WIDTH x DATA_WITH bits
  reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

  always @(posedge i_clk) begin
    if (i_write_enable) begin
      ram[i_addr] <= i_data;
    end
  end

  assign o_data = ram[i_addr];

endmodule
