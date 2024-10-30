module unidad_deteccion_riesgos (
    input wire [4:0] i_rs_ID,
    input wire [4:0] i_rt_ID,
    input wire [4:0] i_rt_EX,
    input wire i_mem_read_EX,


    // para detectar saltos
    input wire [1:0] i_salto_con_registro,  // 00 no salto, 01 salto usando rs y rt (BEQ, BNE),
                                            // 10 salto usando rs (JR, JALR)
    input wire [4:0] i_reg_dst_EX,
    input wire [4:0] i_reg_dst_MEM,
    input wire [4:0] i_reg_dst_WB,
    input wire i_WB_write_EX,
    input wire i_WB_write_MEM,
    input wire i_WB_write_WB,

    output reg o_stall
);

  // detener el pipeline si la instruccion de la etapa ID va a leer un dato
  // que la instruccion anterior (etapa EX) tiene que cargar (LOAD)

  always @(*) begin
    if (i_mem_read_EX && (i_rs_ID == i_rt_EX || i_rt_ID == i_rt_EX)) begin
      // instruccion que lee el resultado de un load, no alcanza con
      // cortocircuito
      o_stall = 1;
    end else if (i_salto_con_registro == 2'b01) begin
      // cheaquear rs y rt para saltos
      if (i_rs_ID == i_reg_dst_EX && i_WB_write_EX) begin
        o_stall = 1;
      end else if (i_rs_ID == i_reg_dst_MEM && i_WB_write_MEM) begin
        o_stall = 1;
      end else if (i_rs_ID == i_reg_dst_WB && i_WB_write_WB) begin
        o_stall = 1;
      end else if (i_rt_ID == i_reg_dst_EX && i_WB_write_EX) begin
        o_stall = 1;
      end else if (i_rt_ID == i_reg_dst_MEM && i_WB_write_MEM) begin
        o_stall = 1;
      end else if (i_rt_ID == i_reg_dst_WB && i_WB_write_WB) begin
        o_stall = 1;
      end else begin
        o_stall = 0;
      end
    end else if (i_salto_con_registro == 2'b10) begin
      // chequear solo rs para saltos
      if (i_rs_ID == i_reg_dst_EX && i_WB_write_EX) begin
        o_stall = 1;
      end else if (i_rs_ID == i_reg_dst_MEM && i_WB_write_MEM) begin
        o_stall = 1;
      end else if (i_rs_ID == i_reg_dst_WB && i_WB_write_WB) begin
        o_stall = 1;
      end else begin
        o_stall = 0;
      end
    end else begin
      o_stall = 0;
    end
  end

endmodule
