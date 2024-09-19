`timescale 1ns / 1ps

module baudRateGen_tb;

  // Parametros
  localparam NCYCLES_PER_TICK = 163;

  integer i;  // Contador de iteraciones
  integer j;

  wire o_tick;
  reg i_clk;
  reg i_reset;

  baudRateGen #(
      .NCYCLES_PER_TICK(NCYCLES_PER_TICK)
  ) baudRateGen1 (
      .i_reset(i_reset),
      .i_clk  (i_clk),
      .o_tick (o_tick)
  );

  always #10 i_clk = ~i_clk;  // Reloj de 20ns -> 50MHz

  // Testbench
  initial begin

    i_clk   = 0;
    i_reset = 0;

    #100 i_reset = 1;
    #100 i_reset = 0;

    // Tests
    for (j = 0; j < 20; j = j + 1) begin  // contamos 20 ticks
      for (i = 0; i < NCYCLES_PER_TICK - 1; i = i + 1) begin
        #20;  // un ciclo
      end

      if (!o_tick) begin
        $fatal("Failed BAUDRAYEGEN Test Bench, expected o_tick to be 1");
      end

      #20;  // un ciclo mas y el contador pasa a 0

      if (o_tick) begin
        $fatal("Failed BAUDRAYEGEN Test Bench, expected o_tick to be 0");
      end
    end

    $display("Passed BAUDRAYEGEN Test Bench");

    $finish;
  end
endmodule
