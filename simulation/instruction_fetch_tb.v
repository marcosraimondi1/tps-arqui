module instruction_fetch_tb ();

  reg i_clk;
  reg i_reset;

  reg write_instruction_mem;  // flag para escribir memoria
  reg [31:0] instruction_mem_addr;
  reg [31:0] instruction_mem_data;
  reg halt;

  reg jump_flag;
  reg [31:0] jump_addr;
  reg stall;

  wire [31:0] instruction;
  wire [31:0] pc4;

  instruction_fetch #() instruction_fetch1 (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_write_instruction_mem(write_instruction_mem),
      .i_instruction_mem_addr(instruction_mem_addr),
      .i_instruction_mem_data(instruction_mem_data),
      .i_jump(jump_flag),
      .i_jump_addr(jump_addr),
      .i_stall(stall),
      .i_halt(halt),
      .o_instruction(instruction),
      .o_pc4(pc4)
  );

  always #10 i_clk = ~i_clk;  // Reloj de 20ns -> 50MHz
  integer i;

  initial begin
    i_clk = 0;
    i_reset = 1;
    jump_flag = 0;
    jump_addr = 0;
    stall = 0;
    i = 0;
    write_instruction_mem = 0;
    instruction_mem_addr = 0;
    instruction_mem_data = 0;
    halt = 0;

    #20;
    if (instruction != 32'h00000000) $fatal("Error: instruction != 32'h00000000");
    if (pc4 != 32'h00000004) $fatal("Error: pc4 != 32'h00000004");
    i_reset = 0;
    halt = 1;  // detiene el contaodor de pc

    #20;
    if (pc4 != 32'h00000004) $fatal("Error: pc4 != 32'h00000004");
    // escribir instrucciones en memoria
    write_instruction_mem = 1;
    instruction_mem_addr  = 0;
    for (i = 0; i < 100; i = i + 1) begin
      instruction_mem_data = i;
      #20;
      instruction_mem_addr = instruction_mem_addr + 4;
    end

    // leer instrucciones de memoria
    write_instruction_mem = 0;
    #20;
    halt = 0;
    for (i = 0; i < 50; i = i + 1) begin
      #20;
      if (instruction != i) $fatal("Error: instruction != %d", i);
      if (pc4 != (i * 4 + 8)) $fatal("Error: pc4 != %d", (i * 4 + 4));
    end

    // test stall
    stall = 1;
    #20;
    for (i = 0; i < 10; i = i + 1) begin
      #20;
      if (instruction != 49) $fatal("Error: instruction != 49");
      if (pc4 != (50 * 4 + 4)) $fatal("Error: pc4 != 204");
    end

    // test jump
    stall = 0;
    #20;
    jump_flag = 1;
    jump_addr = 0;
    #20;
    // esta es la instruccion siguiente al jump
    if (instruction != 51) $fatal("Error: instruction != 51");
    if (pc4 != 4) $fatal("Error: pc4 != 4");
    #20;
    if (instruction != 0) $fatal("Error: instruction != 0");

    $display("Passed Instruction Fetch Test Bench");
    $finish;
  end
endmodule
