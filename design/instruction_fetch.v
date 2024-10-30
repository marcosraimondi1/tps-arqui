module instruction_fetch (
    input wire i_clk,
    input wire i_reset,
    input wire i_write_instruction_mem,
    input wire [31:0] i_instruction_mem_addr,
    input wire [31:0] i_instruction_mem_data,
    input wire i_jump,
    input wire [31:0] i_jump_addr,
    input wire i_stall,  // Proviene de la unidad de deteción de riesgos
    input wire i_halt,  // Proviene de la instrucción (HALT) ó de la debug unit
    output reg [31:0] o_instruction,
    output wire [31:0] o_pc4
);

  wire [31:0] pc;
  wire [31:0] instruction_from_mem;
  wire [31:0] instruction_addr;

  pc_control #() pc_control1 (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_jump_addr(i_jump_addr),  // pendiente revisar
      .i_jump(i_jump),  // pendiente revisar
      .i_stall(i_stall),  // Proviene de la unidad de deteción de riesgos
      .i_halt(i_halt),  // Proviene de la instrucción (HALT) ó de la debug unit
      .o_pc(pc),
      .o_pc4(o_pc4)
  );

  xilinx_one_port_ram_async #(
      .ADDR_WIDTH(8),  // 256 direcciones (64 instrucciones de 32 bits cada una)
      .DATA_WIDTH(8)   // 8 bit data
  ) instruction_mem (
      .i_clk(i_clk),
      .i_write_enable(i_write_instruction_mem),
      .i_addr(instruction_addr[7:0]),
      .i_data(i_instruction_mem_data),
      .o_data(instruction_from_mem)
  );

  always @(posedge i_clk) begin
    if (i_reset) begin
      o_instruction <= 32'h00000000;
    end else begin
      if (!i_stall && !i_halt) begin
        o_instruction <= instruction_from_mem;
      end
    end
  end

  assign instruction_addr = i_write_instruction_mem ? i_instruction_mem_addr : pc;

endmodule
