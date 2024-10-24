module instruction_fetch (
    input wire i_clk,
    input wire i_reset,
    input wire i_write_instruction_mem,
    input wire [31:0] i_instruction_mem_addr,
    input wire [31:0] i_instruction_mem_data,
    input wire i_jump,
    input wire [31:0] i_jump_addr,
    input wire i_stall,
    input wire i_halt,
    output wire [31:0] o_instruction,
    output wire [31:0] o_pc4
);

  wire [31:0] pc;
  reg  [31:0] instruction;
  wire [31:0] instruction_from_mem;
  wire [31:0] instruction_addr;

  pc_control #() pc_control1 (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_jump_addr(i_jump_addr),  // pendiente revisar
      .i_jump(i_jump),  // pendiente revisar
      .i_stall(i_stall),  // pendiente revisar
      .i_halt(i_halt),  // pendiente revisar
      .o_pc(pc),
      .o_pc4(o_pc4)
  );

  xilinx_one_port_ram_async #(
      .ADDR_WIDTH(12),  // 4K direcciones
      .DATA_WIDTH(8)    // 8 bit data
  ) instruction_mem (
      .i_clk(i_clk),
      .i_write_enable(i_write_instruction_mem),
      .i_addr(instruction_addr),
      .i_data(i_instruction_mem_data),
      .o_data(instruction_from_mem)
  );

  always @(posedge i_clk) begin
    if (i_reset) begin
      instruction <= 32'h00000000;
    end else begin
      if (!i_stall) begin
        instruction <= instruction_from_mem;
      end
    end
  end

  assign instruction_addr = i_write_instruction_mem ? i_instruction_mem_addr : pc;

endmodule
