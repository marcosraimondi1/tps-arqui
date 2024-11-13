module unidad_cortocircuito (
    input wire [4:0] i_rd_MEM,
    input wire [4:0] i_rd_WB,
    input wire [4:0] i_rs_EX,
    input wire [4:0] i_rt_EX,
    input wire i_write_reg_WB,  // si la instruccion en WB escribe un registro
    input wire i_write_reg_MEM,  // si la instruccion en MEM escribe un registro
    output reg [1:0] o_corto_rs,
    output reg [1:0] o_corto_rt
);

  localparam NO_CORTO = 2'b00;
  localparam CORTO_WB = 2'b01;
  localparam CORTO_MEM = 2'b10;

  always @(*) begin
    // ver si la instruccion de la etapa MEM o WB va a escribir alguno de los
    // registros fuente (rs), con prioridad a la instruccion mas nueva (MEM)
    if (i_write_reg_MEM && i_rd_MEM == i_rs_EX) begin
      // cortocircuito rs con el valor a la entrada de la etapa MEM (salida
      // de ALU)
      o_corto_rs = CORTO_MEM;
    end else if (i_write_reg_WB && i_rd_WB == i_rs_EX) begin
      // cortocircuito rs con el valor a la entrada de la etapa WB (salida
      // de MEM)
      o_corto_rs = CORTO_WB;
    end else begin
      // no hay cortocircuito
      o_corto_rs = NO_CORTO;
    end
  end

  always @(*) begin
    // ver si la instruccion de la etapa MEM o WB va a escribir alguno de los
    // registros fuente (rt), con prioridad a la instruccion mas nueva (MEM)
    if (i_write_reg_MEM && i_rd_MEM == i_rt_EX) begin
      // cortocircuito rt con el valor a la entrada de la etapa MEM (salida
      // de ALU)
      o_corto_rt = CORTO_MEM;
    end else if (i_write_reg_WB && i_rd_WB == i_rt_EX) begin
      // cortocircuito rt con el valor a la entrada de la etapa WB (salida
      // de MEM)
      o_corto_rt = CORTO_WB;
    end else begin
      // no hay cortocircuito
      o_corto_rt = NO_CORTO;
    end
  end

endmodule