module pc_control (
    input wire i_clk,
    input wire i_reset,
    input wire [31:0] i_jump_addr,
    input wire i_jump,
    input wire i_stall,
    input wire i_halt,
    output reg [31:0] o_pc,
    output reg [31:0] o_pc4
);

  always @(posedge i_clk) begin
    if (i_reset) begin
      o_pc  <= 32'h00000000;
      o_pc4 <= 32'h00000004;
    end else if (!i_stall && !i_halt) begin
      if (i_jump) begin
        // usar direccion de salto como proximo PC
        o_pc  <= i_jump_addr;
        o_pc4 <= i_jump_addr + 4;
      end else begin
        o_pc  <= o_pc + 4;
        o_pc4 <= o_pc4 + 4;
      end
    end
  end

endmodule
