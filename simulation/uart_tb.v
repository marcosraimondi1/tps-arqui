`timescale 1ns / 1ps

module uart_tb;

  // Parametros
  localparam NB_DATA = 8;

  // Senales
  integer i;
  wire o_tick;
  wire tx_done;
  wire o_tx_i_rx;
  wire rx_done;
  wire [NB_DATA-1:0] rx_data;

  reg i_clk;
  reg i_reset;
  reg tx_start;
  reg [NB_DATA-1:0] tx_data;

  baudRateGen #(
      .BAUD_RATE(19200),
      .CLK_FREQ(50_000_000),
      .OVERSAMPLING(16)
  ) baudRateGen1 (
      .i_reset(i_reset),
      .i_clk  (i_clk),
      .o_tick (o_tick)
  );

  uart_tx #(
      .NB_DATA(NB_DATA)
  ) uart_tx1 (
      .i_reset(i_reset),
      .i_tx_data(tx_data),
      .i_tx_start(tx_start),
      .i_tick(o_tick),
      .i_clk(i_clk),
      .o_tx(o_tx_i_rx),
      .o_tx_done(tx_done)
  );

  uart_rx #(
      .NB_DATA(NB_DATA)
  ) uart_rx1 (
      .i_reset(i_reset),
      .i_tick(o_tick),
      .i_rx(o_tx_i_rx),
      .i_clk(i_clk),
      .o_rx_data(rx_data),
      .o_rx_done(rx_done)
  );

  always #10 i_clk = ~i_clk;  // Reloj de 20ns -> 50MHz

  // Testbench
  initial begin
    i_clk = 0;
    i_reset = 0;
    tx_start = 0;
    tx_data = 0;
    i = 0;

    #100 i_reset = 1;
    #100 i_reset = 0;

    // Tests
    for (i = 0; i < 100; i = i + 1) begin
      tx_data = $urandom % (2 ** NB_DATA);
      #20;
      tx_start = 1;
      #20;
      tx_start = 0;

      // esperar hasta que termine la transmision para mandar el siguiente
      // dato
      @(posedge tx_done);

      if (tx_data != rx_data) begin
        $fatal("Error: tx_data = %d, rx_data = %d", tx_data, rx_data);
      end

      #20;  // hay que esperar un ciclo de clock antes de mandar el siguiente dato
    end

    $display("Passed UART Test Bench");

    $finish;
  end
endmodule
