module top #(
    parameter NB_DATA = 8,
    parameter NCYCLES_PER_TICK = 163
) (
    input  wire sys_clk100,
    input  wire i_reset,
    input  wire i_rx,
    output wire o_tx,
    output wire o_test_led
);

  wire clk_50;
  wire o_tick;
  wire [NB_DATA-1:0] rx_data;
  wire rx_done;
  wire tx_done;

  clk_wiz_0 clk_wiz (
      .CLK_50MHZ(clk_50),
      .reset(i_reset),
      .clk_in1(sys_clk100)
  );

  baudRateGen #(
      .NCYCLES_PER_TICK(NCYCLES_PER_TICK)
  ) baudRateGen1 (
      .i_reset(i_reset),
      .i_clk  (clk_50),
      .o_tick (o_tick)
  );

  uart_rx #(
      .NB_DATA(NB_DATA)
  ) uart_rx1 (
      .i_reset(i_reset),
      .i_tick(o_tick),
      .i_rx(i_rx),
      .i_clk(clk_50),
      .o_rx_data(rx_data),
      .o_rx_done(rx_done)
  );

  uart_tx #(
      .NB_DATA(NB_DATA)
  ) uart_tx1 (
      .i_reset(i_reset),
      .i_tx_data(rx_data),  // envio la misma data que recibo
      .i_tx_start(rx_done),  // cuando termino de recibir, empiezo a enviar
      .i_tick(o_tick),
      .i_clk(clk_50),
      .o_tx(o_tx),
      .o_tx_done(tx_done)
  );


  assign o_test_led = i_reset;

endmodule
