module top #(
    parameter NB_DATA   = 8,
    parameter NB_ALU_OP = 6
) (
    input  wire sys_clk100,
    input  wire i_reset,
    input  wire i_rx,
    output wire o_tx,
    output wire o_test_led
);

  // wire clk_50;
  // UART
  wire o_tick;
  wire [NB_DATA-1:0] rx_data;
  wire [NB_DATA-1:0] tx_data;
  wire rx_done;
  wire tx_done;
  wire tx_start;

  // ALU
  wire [NB_DATA-1:0] alu_data_out;
  wire [NB_DATA-1:0] alu_data_A;
  wire [NB_DATA-1:0] alu_data_B;
  wire [NB_ALU_OP-1:0] alu_op;

  // clk_wiz_0 clk_wiz (
  //     .CLK_50MHZ(clk_50),
  //     .reset(i_reset),
  //     .clk_in1(sys_clk100)
  // );

  baudRateGen #(
      .BAUD_RATE(19200),
      .CLK_FREQ(100_000_000),
      .OVERSAMPLING(16)
  ) baudRateGen1 (
      .i_reset(i_reset),
      .i_clk  (sys_clk100),
      .o_tick (o_tick)
  );

  uart_rx #(
      .NB_DATA(NB_DATA),
      .NB_STOP(1)
  ) uart_rx1 (
      .i_reset(i_reset),
      .i_tick(o_tick),
      .i_rx(i_rx),
      .i_clk(sys_clk100),
      .o_rx_data(rx_data),
      .o_rx_done(rx_done)
  );

  uart_tx #(
      .NB_DATA(NB_DATA)
  ) uart_tx1 (
      .i_reset(i_reset),
      .i_tx_data(tx_data),  // envio la misma data que recibo
      .i_tx_start(tx_start),  // cuando termino de recibir, empiezo a enviar
      .i_tick(o_tick),
      .i_clk(sys_clk100),
      .o_tx(o_tx),
      .o_tx_done(tx_done)
  );


  uart_interface #(
      .NB_DATA  (NB_DATA),
      .NB_ALU_OP(NB_ALU_OP)
  ) uart_interface1 (
      .i_clk(sys_clk100),
      .i_reset(i_reset),
      .i_rx_done(rx_done),
      .i_tx_done(tx_done),
      .i_rx_data(rx_data),
      .i_alu_data_out(alu_data_out),
      .o_tx_data(tx_data),
      .o_alu_op(alu_op),
      .o_alu_data_A(alu_data_A),
      .o_alu_data_B(alu_data_B),
      .o_tx_start(tx_start)
  );


  alu #(
      .NB_OP  (NB_ALU_OP),
      .NB_DATA(NB_DATA)
  ) alu1 (
      .i_op(alu_op),
      .i_data_A(alu_data_A),
      .i_data_B(alu_data_B),
      .o_data(alu_data_out)
  );

  assign o_test_led = i_reset;

endmodule
