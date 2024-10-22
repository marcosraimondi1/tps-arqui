module xilinx_one_port_ram_async #(
    parameter ADDR_WIDTH = 12,  // 4K direcciones
    parameter DATA_WIDTH = 8    // 8 bit data
) (
    input wire i_clk,
    input wire i_write_enable,
    input wire [ADDR_WIDTH-1:0] i_addr,
    input wire [DATA_WIDTH*4-1:0] i_data,
    output wire [DATA_WIDTH-1:0] o_data
);

  // memoria de 2**ADDR_WIDTH x DATA_WITH bits
  reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

  always @(posedge i_clk) begin
    if (i_write_enable) begin
      ram[i_addr]   <= i_data[31:24];
      ram[i_addr+1] <= i_data[23:16];
      ram[i_addr+2] <= i_data[15:8];
      ram[i_addr+3] <= i_data[7:0];
    end
  end

  assign o_data = {ram[i_addr], ram[i_addr+1], ram[i_addr+2], ram[i_addr+3]};

endmodule
