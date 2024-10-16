module pc_control (
    input wire i_clk,
    input wire i_reset,
    input wire [31:0] i_jump_addr,
    input wire i_jump,
    input wire i_stall,
    input wire i_halt,
    output wire [31:0] o_pc,
    output wire [31:0] o_pc4
);

  reg [31:0] pc, pc4;

  always @(posedge i_clk) begin
    if (i_reset) begin
      pc  <= 32'h00000000;
      pc4 <= 32'h00000004;
    end else if (!i_stall && !i_halt) begin
      if (i_jump) begin
        // usar direccion de salto como proximo PC
        pc  <= i_jump_addr;
        pc4 <= i_jump_addr + 4;
      end else begin
        pc  <= pc + 4;
        pc4 <= pc4 + 4;
      end
    end
  end

  assign o_pc  = pc;
  assign o_pc4 = pc4;

endmodule
