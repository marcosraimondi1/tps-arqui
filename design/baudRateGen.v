module baudRateGen #(
    parameter NCYCLES_PER_TICK = 163
) (
    input  wire i_clk,
    input  wire i_reset,
    output wire o_tick
);

  integer counter;

  always @(posedge i_clk) begin
    if (i_reset) begin
      counter <= 0;
    end else if (counter == NCYCLES_PER_TICK - 1) begin
      // volver a empezar
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
    begin
    end
  end

  // se genera un tick de un ciclo de reloj cada NCYCLES_PER_TICK ciclos
  assign o_tick = (counter == NCYCLES_PER_TICK - 1);

endmodule

