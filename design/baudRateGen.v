module baudRateGen #(
    parameter NCYCLES_PER_TICK = 163
) (
    input  wire i_clk,
    input  wire i_reset,
    output wire o_tick
);

  // numero de bits minimos para contar hasta NCYCLES_PER_TICK
  localparam NB_COUNTER = clogb2(NCYCLES_PER_TICK - 1);

  reg [NB_COUNTER-1:0] counter;

  always @(posedge i_clk) begin
    if (i_reset) begin
      counter <= 8'b0;
    end else if (counter == NCYCLES_PER_TICK - 1) begin
      // volver a empezar
      counter <= 8'b0;
    end else begin
      counter <= counter + 1;
    end
    begin
    end
  end

  // se genera un tick de un ciclo de reloj cada NCYCLES_PER_TICK ciclos
  assign o_tick = (counter == NCYCLES_PER_TICK - 1);

  function integer clogb2;
    input integer value;
    for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
      // divide por dos
      value = value >> 1;
    end
  endfunction

endmodule

