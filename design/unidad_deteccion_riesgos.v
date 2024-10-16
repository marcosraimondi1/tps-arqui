module unidad_deteccion_riesgos #(
) (
    input wire [4:0] i_rs_ID,
    input wire [4:0] i_rt_ID,
    input wire [4:0] i_rt_EX,
    input wire i_mem_read_EX,
    output wire o_stall
);

  // detener el pipeline si la instruccion de la etapa ID va a leer un dato
  // que la instruccion anterior (etapa EX) tiene que cargar (LOAD)
  assign o_stall = (i_mem_read_EX && (i_rs_ID == i_rt_EX || i_rt_ID == i_rt_EX));

endmodule
