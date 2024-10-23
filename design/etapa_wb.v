module etapa_wb (
    input wire [ 4:0] i_write_reg,   // registro de destino donde se escriben los resultados en WB
    input wire [31:0] i_ALU_result,
    input wire [31:0] i_read_data,   // data leida de memoria

    // senales de control (input)
    input wire i_WB_write,  // si 1 la instruccion escribe en el banco de registros
    input wire i_WB_mem_to_reg,  // si 0 guardo el valor de MEM (load) sino el valor de ALU (tipo R)

    // salidas de la etapa
    output wire [4:0] o_write_reg,  // registro de destino donde se escriben los resultados en WB
    output wire [31:0] o_WB_data,  // data que se escribe en el banco de registros
    output wire o_WB_write  // si 1 la instruccion escribe en el banco de registros
);

  assign o_write_reg = i_write_reg;
  assign o_WB_data   = i_WB_mem_to_reg ? i_ALU_result : i_read_data;
  assign o_WB_write  = i_WB_write;

endmodule
