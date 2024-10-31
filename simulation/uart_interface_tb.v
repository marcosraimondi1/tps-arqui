`timescale 1ns / 1ps

module uart_interface_tb;
  // UART commands/opcodes
  localparam LOAD_INSTR_OP = 8'b00000000;
  localparam START_CONT_OP = 8'b00000001;
  localparam START_DEBUG_OP = 8'b00000010;
  localparam STEP_OP = 8'b00000011;
  localparam END_DEBUG_OP = 8'b00000100;

  // Parameters
  parameter NB_DATA = 8;
  parameter NB_IF_ID = 64;
  parameter NB_ID_EX = 139;
  parameter NB_EX_MEM = 76;
  parameter NB_MEM_WB = 71;

  // Inputs
  reg i_clk;
  reg i_reset;
  reg i_rx_done;
  reg i_tx_done;
  reg [NB_DATA-1:0] i_rx_data;
  reg [31:0] i_r_data_registers;
  reg [31:0] i_r_data_data_mem;
  reg [NB_IF_ID-1:0] i_IF_ID;
  reg [NB_ID_EX-1:0] i_ID_EX;
  wire [NB_EX_MEM-1:0] i_EX_MEM;
  reg [NB_MEM_WB-1:0] i_MEM_WB;
  reg i_end;

  // EX_MEM latches
  reg [31:0] ALU_result_EX_MEM;
  reg MEM_write_EX_MEM;

  reg [4:0] write_reg_EX_MEM;
  reg [31:0] data_to_write_in_MEM;
  reg WB_write_EX_MEM;
  reg WB_mem_to_reg_EX_MEM;
  reg MEM_read_EX_MEM;
  reg MEM_unsigned_EX_MEM;
  reg [1:0] MEM_byte_half_word_EX_MEM;

  // Outputs
  wire [NB_DATA-1:0] o_tx_data;
  wire o_tx_start;
  wire o_reset_pipeline;
  wire o_stop;
  wire o_write_instruction_mem;
  wire [31:0] o_instruction_mem_addr;
  wire [31:0] o_instruction_mem_data;
  wire [4:0] o_r_addr_registers;
  wire [4:0] o_r_addr_data_mem;

  // Instantiate the Unit Under Test (UUT)
  uart_interface #(
      .NB_DATA  (NB_DATA),
      .NB_IF_ID (NB_IF_ID),
      .NB_ID_EX (NB_ID_EX),
      .NB_EX_MEM(NB_EX_MEM),
      .NB_MEM_WB(NB_MEM_WB)
  ) uart_interface1 (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_rx_done(i_rx_done),
      .i_tx_done(i_tx_done),
      .i_rx_data(i_rx_data),
      .o_tx_data(o_tx_data),
      .o_tx_start(o_tx_start),
      .i_r_data_registers(i_r_data_registers),
      .i_r_data_data_mem(i_r_data_data_mem),
      .i_IF_ID(i_IF_ID),
      .i_ID_EX(i_ID_EX),
      .i_EX_MEM(i_EX_MEM),
      .i_MEM_WB(i_MEM_WB),
      .i_end(i_end),
      .o_reset_pipeline(o_reset_pipeline),
      .o_stop(o_stop),
      .o_write_instruction_mem(o_write_instruction_mem),
      .o_instruction_mem_addr(o_instruction_mem_addr),
      .o_instruction_mem_data(o_instruction_mem_data),
      .o_r_addr_registers(o_r_addr_registers),
      .o_r_addr_data_mem(o_r_addr_data_mem)
  );

  // Clock generation
  always #10 i_clk = ~i_clk;


  // Simulation initialization
  initial begin
    // Initialize inputs
    i_clk = 0;
    i_reset = 0;
    i_rx_done = 0;
    i_tx_done = 0;
    i_rx_data = 0;
    i_r_data_registers = 0;
    i_r_data_data_mem = 0;
    i_IF_ID = 0;
    i_ID_EX = 0;

    ALU_result_EX_MEM = 0;
    MEM_write_EX_MEM = 0;

    write_reg_EX_MEM = 0;
    data_to_write_in_MEM = 0;
    WB_write_EX_MEM = 0;
    WB_mem_to_reg_EX_MEM = 0;
    MEM_read_EX_MEM = 0;
    MEM_unsigned_EX_MEM = 0;
    MEM_byte_half_word_EX_MEM = 0;

    i_MEM_WB = 0;
    i_end = 0;

    // Reset pulse
    #20;
    i_reset = 1;

    #20;
    i_reset = 0;

    if (o_reset_pipeline !== 1)
      $fatal("Error: o_reset_pipeline = %d, expected %d", o_reset_pipeline, 1);

    if (o_stop !== 1) $fatal("Error: o_stop = %d, expected %d", o_stop, 1);

    // Test 1: LOAD_INSTR_OP
    // 1. send opcode
    i_rx_data = LOAD_INSTR_OP;
    i_rx_done = 1;
    #20;
    i_rx_done = 0;
    #60;  // recibir por uart son varios ciclos

    // 2. load instruction (h01020304)
    i_rx_data = 8'h01;
    i_rx_done = 1;
    #20;
    i_rx_done = 0;
    #60;

    i_rx_data = 8'h02;
    i_rx_done = 1;
    #20;
    i_rx_done = 0;
    #60;

    i_rx_data = 8'h03;
    i_rx_done = 1;
    #20;
    i_rx_done = 0;
    #60;

    i_rx_data = 8'h04;
    i_rx_done = 1;
    #20;
    i_rx_done = 0;

    if (o_write_instruction_mem !== 1)
      $fatal("Error: o_write_instruction_mem = %d, expected %d", o_write_instruction_mem, 1);
    if (o_instruction_mem_addr !== 32'h00000000)
      $fatal("Error: o_instruction_mem_addr = %h, exp %h", o_instruction_mem_addr, 32'h00000000);
    if (o_instruction_mem_data !== 32'h01020304)
      $fatal("Error: o_instruction_mem_data = %h, exp %h", o_instruction_mem_data, 32'h01020304);

    #60;

    if (o_reset_pipeline !== 0)
      $fatal("Error: o_reset_pipeline = %d, expected %d", o_reset_pipeline, 0);
    if (o_stop !== 1) $fatal("Error: o_stop = %d, expected %d", o_stop, 1);

    // 3. load instruction (halt hFFFFFFFF)
    i_rx_data = 8'hff;
    i_rx_done = 1;
    #20;
    i_rx_done = 0;
    #60;

    i_rx_data = 8'hff;
    i_rx_done = 1;
    #20;
    i_rx_done = 0;
    #60;

    i_rx_data = 8'hff;
    i_rx_done = 1;
    #20;
    i_rx_done = 0;
    #60;

    i_rx_data = 8'hff;
    i_rx_done = 1;
    #20;
    i_rx_done = 0;


    if (o_write_instruction_mem !== 1)
      $fatal("Error: o_write_instruction_mem = %d, expected %d", o_write_instruction_mem, 1);
    if (o_instruction_mem_addr !== 32'h00000004)
      $fatal("Error: o_instruction_mem_addr = %h, exp %h", o_instruction_mem_addr, 32'h00000004);
    if (o_instruction_mem_data !== 32'hffffffff)
      $fatal("Error: o_instruction_mem_data = %h, exp %h", o_instruction_mem_data, 32'hffffffff);

    #60;

    if (o_reset_pipeline !== 1)
      $fatal("Error: o_reset_pipeline = %d, expected %d", o_reset_pipeline, 1);
    if (o_stop !== 1) $fatal("Error: o_stop = %d, expected %d", o_stop, 1);

    // Test 2: Continuous Mode
    i_rx_data = START_CONT_OP;
    i_rx_done = 1;
    #20;
    i_rx_done = 0;
    #20;

    if (o_reset_pipeline !== 0)
      $fatal("Error: o_reset_pipeline = %d, expected %d", o_reset_pipeline, 0);
    if (o_stop !== 0) $fatal("Error: o_stop = %d, expected %d", o_stop, 0);

    #20;
    // write mem
    MEM_write_EX_MEM  = 1;
    ALU_result_EX_MEM = 32'h0000000f;  // posicion de memoria
    #20;
    ALU_result_EX_MEM = 32'h0000000f + 4;  // posicion de memoria
    #20;
    ALU_result_EX_MEM = 32'h0000000f + 8;  // posicion de memoria
    #20;
    MEM_write_EX_MEM = 0;

    #100;
    i_end = 1;  // Indicate program end
    #20;

    // state == send_state
    #20;
    if (o_stop !== 1) $fatal("Error: o_stop = %d, expected %d", o_stop, 1);

    @(posedge o_reset_pipeline);

    // Test 3: START_DEBUG_OP and STEP_OP
    i_rx_data = START_DEBUG_OP;
    i_rx_done = 1;
    #20;
    i_rx_done = 0;

    i_rx_data = STEP_OP;
    i_rx_done = 1;
    #20;
    i_rx_done = 0;

    // Test 4: END_DEBUG_OP
    i_rx_data = END_DEBUG_OP;
    i_rx_done = 1;
    #20 i_rx_done = 0;


    // Test end
    #100;
    $display("Passed UART INTERFACE Test Bench");
    $finish;
  end

  assign i_EX_MEM = {
    write_reg_EX_MEM,
    data_to_write_in_MEM,
    ALU_result_EX_MEM,
    WB_write_EX_MEM,
    WB_mem_to_reg_EX_MEM,
    MEM_read_EX_MEM,
    MEM_write_EX_MEM,
    MEM_unsigned_EX_MEM,
    MEM_byte_half_word_EX_MEM
  };
endmodule
