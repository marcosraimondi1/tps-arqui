module top #(
    parameter NB_DATA   = 8,
    parameter NB_IF_ID  = 64,
    parameter NB_ID_EX  = 144,  // 139,
    parameter NB_EX_MEM = 80,   // 76,
    parameter NB_MEM_WB = 72    // 71
) (
    input  wire sys_clk100,
    input  wire i_reset,
    input  wire i_rx,
    output wire o_tx,
    output wire o_test_led
);

  wire clk;
  wire clk_40;
  wire clk_45;
  wire clk_50;
  assign clk = clk_45;
  localparam CLK_FREQ = 45_000_000;

  // UART
  wire o_tick;
  wire [NB_DATA-1:0] rx_data;
  wire [NB_DATA-1:0] tx_data;
  wire rx_done;
  wire tx_done;
  wire tx_start;

  // uart interface -> pipeline
  wire reset_pipeline;
  wire stop_pipeline;
  wire write_instruction_mem;
  wire [31:0] instruction_mem_addr;
  wire [31:0] instruction_mem_data;
  wire [4:0] r_addr_registers;
  wire [31:0] r_addr_data_mem;

  // pipeline -> uart interface
  wire [31:0] r_data_registers;
  wire [31:0] r_data_data_mem;
  wire [NB_IF_ID-1:0] IF_ID;
  wire [NB_ID_EX-1:0] ID_EX;
  wire [NB_EX_MEM-1:0] EX_MEM;
  wire [NB_MEM_WB-1:0] MEM_WB;
  wire program_ended;

  clk_wiz2 clk_wiz (
      .clk_40_0(clk_40),
      .clk_45_0(clk_45),
      .clk_50_0(clk_50),
      .sys_clock(sys_clk100),
      .reset(i_reset)
  );

  baudRateGen #(
      .BAUD_RATE(19200),
      .CLK_FREQ(CLK_FREQ),
      .OVERSAMPLING(16)
  ) baudRateGen1 (
      .i_reset(i_reset),
      .i_clk  (clk),
      .o_tick (o_tick)
  );

  uart_rx #(
      .NB_DATA(NB_DATA),
      .NB_STOP(1)
  ) uart_rx1 (
      .i_reset(i_reset),
      .i_tick(o_tick),
      .i_rx(i_rx),
      .i_clk(clk),
      .o_rx_data(rx_data),
      .o_rx_done(rx_done)
  );

  uart_tx #(
      .NB_DATA(NB_DATA)
  ) uart_tx1 (
      .i_reset(i_reset),
      .i_tx_data(tx_data),
      .i_tx_start(tx_start),
      .i_tick(o_tick),
      .i_clk(clk),
      .o_tx(o_tx),
      .o_tx_done(tx_done)
  );


  uart_interface #(
      .NB_DATA  (NB_DATA),
      .NB_IF_ID (NB_IF_ID),
      .NB_ID_EX (NB_ID_EX),
      .NB_EX_MEM(NB_EX_MEM),
      .NB_MEM_WB(NB_MEM_WB)
  ) uart_interface1 (
      .i_clk(clk),
      .i_reset(i_reset),
      .i_rx_done(rx_done),
      .i_tx_done(tx_done),
      .i_rx_data(rx_data),
      .o_tx_data(tx_data),
      .o_tx_start(tx_start),
      .i_r_data_registers(r_data_registers),
      .i_r_data_data_mem(r_data_data_mem),
      .i_IF_ID(IF_ID),
      .i_ID_EX(ID_EX),
      .i_EX_MEM(EX_MEM),
      .i_MEM_WB(MEM_WB),
      .i_end(program_ended),
      .o_reset_pipeline(reset_pipeline),
      .o_stop(stop_pipeline),
      .o_write_instruction_mem(write_instruction_mem),
      .o_instruction_mem_addr(instruction_mem_addr),
      .o_instruction_mem_data(instruction_mem_data),
      .o_r_addr_registers(r_addr_registers),
      .o_r_addr_data_mem(r_addr_data_mem)
  );


  pipeline #(
      .NB_IF_ID (NB_IF_ID),
      .NB_ID_EX (NB_ID_EX),
      .NB_EX_MEM(NB_EX_MEM),
      .NB_MEM_WB(NB_MEM_WB)
  ) pipeline1 (
      .i_clk(clk),
      .i_reset(i_reset),
      .i_stop(stop_pipeline),
      .i_write_instruction_mem(write_instruction_mem),
      .i_instruction_mem_addr(instruction_mem_addr),
      .i_instruction_mem_data(instruction_mem_data),
      .i_r_addr_registers(r_addr_registers),
      .i_r_addr_data_mem(r_addr_data_mem),

      .o_r_data_registers(r_data_registers),
      .o_r_data_data_mem(r_data_data_mem),
      .o_IF_ID(IF_ID),
      .o_ID_EX(ID_EX),
      .o_EX_MEM(EX_MEM),
      .o_MEM_WB(MEM_WB),
      .o_end(program_ended)
  );

  assign o_test_led = i_reset;

endmodule
