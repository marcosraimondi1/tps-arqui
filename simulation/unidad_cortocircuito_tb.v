`timescale 1ns / 1ps

module unidad_cortocircuito_tb;

  localparam NO_CORTO = 2'b00;
  localparam CORTO_WB = 2'b01;
  localparam CORTO_MEM = 2'b10;

  reg [4:0] write_reg__out_execute;
  reg [4:0] write_reg__out_mem;
  reg [4:0] rs;
  reg [4:0] rt;
  reg WB_write__out_mem;
  reg WB_write__out_execute;
  wire [1:0] corto_rs;
  wire [1:0] corto_rt;

  unidad_cortocircuito unidad_cortocircuito1 (
      .i_rd_MEM(write_reg__out_execute),
      .i_rd_WB(write_reg__out_mem),
      .i_rs_EX(rs),
      .i_rt_EX(rt),
      .i_write_reg_WB(WB_write__out_mem),
      .i_write_reg_MEM(WB_write__out_execute),
      .o_corto_rs(corto_rs),
      .o_corto_rt(corto_rt)
  );

  initial begin
    rs = 0;
    rt = 0;
    WB_write__out_mem = 0;
    WB_write__out_execute = 0;
    write_reg__out_mem = 0;
    write_reg__out_execute = 0;

    #10;
    $display("1.");
    if (corto_rs !== NO_CORTO) $fatal("Error: corto_rs = %d, expected %d", corto_rs, NO_CORTO);
    if (corto_rt !== NO_CORTO) $fatal("Error: corto_rt = %d, expected %d", corto_rt, NO_CORTO);

    #10;
    $display("2.");
    WB_write__out_mem  = 1;  // se escribe en el WB
    write_reg__out_mem = 2;  // el registro 2
    #10;
    if (corto_rs !== NO_CORTO) $fatal("Error: corto_rs = %d, expected %d", corto_rs, NO_CORTO);
    if (corto_rt !== NO_CORTO) $fatal("Error: corto_rt = %d, expected %d", corto_rt, NO_CORTO);

    #10;
    $display("3.");
    WB_write__out_mem = 1;  // se escribe en el WB
    write_reg__out_mem = 2;  // el registro 2
    rs = 2;  // en execute se quiere usar el registro 2 en rs
    #10;
    if (corto_rs !== CORTO_WB) $fatal("Error: corto_rs = %d, expected %d", corto_rs, CORTO_WB);
    if (corto_rt !== NO_CORTO) $fatal("Error: corto_rt = %d, expected %d", corto_rt, NO_CORTO);

    #10;
    $display("4.");
    rt = 2;  // en execute se quiere usar el registro 2 en rt y rs
    #10;
    if (corto_rs !== CORTO_WB) $fatal("Error: corto_rs = %d, expected %d", corto_rs, CORTO_WB);
    if (corto_rt !== CORTO_WB) $fatal("Error: corto_rt = %d, expected %d", corto_rt, CORTO_WB);

    #10;
    $display("5.");
    rs = 1;
    rt = 3;
    #10;
    if (corto_rs !== NO_CORTO) $fatal("Error: corto_rs = %d, expected %d", corto_rs, NO_CORTO);
    if (corto_rt !== NO_CORTO) $fatal("Error: corto_rt = %d, expected %d", corto_rt, NO_CORTO);

    #10;
    $display("6.");
    WB_write__out_execute = 1;  // la instruccion en MEM escribe en el WB
    write_reg__out_execute = 3;  // el registro 3
    rs = 1;
    rt = 3;
    #10;
    if (corto_rs !== NO_CORTO) $fatal("Error: corto_rs = %d, expected %d", corto_rs, NO_CORTO);
    if (corto_rt !== CORTO_MEM) $fatal("Error: corto_rt = %d, expected %d", corto_rt, CORTO_MEM);

    #10;
    $display("7.");
    rs = 3;  // en execute se quiere usar el registro 3 en rt y rs
    #10;
    if (corto_rs !== CORTO_MEM) $fatal("Error: corto_rs = %d, expected %d", corto_rs, CORTO_MEM);
    if (corto_rt !== CORTO_MEM) $fatal("Error: corto_rt = %d, expected %d", corto_rt, CORTO_MEM);

    #10;
    $display("8.");
    WB_write__out_mem = 1;  // la instruccion en WB escribe en el WB
    write_reg__out_mem = 30;  // el registro 30
    WB_write__out_execute = 1;  // la instruccion en MEM escribe en el WB
    write_reg__out_execute = 8;  // el registro 8
    rs = 1;
    rt = 3;
    #10;
    if (corto_rs !== NO_CORTO) $fatal("Error: corto_rs = %d, expected %d", corto_rs, NO_CORTO);
    if (corto_rt !== NO_CORTO) $fatal("Error: corto_rt = %d, expected %d", corto_rt, NO_CORTO);

    #10;
    $display("9.");
    rs = 30;
    rt = 8;
    #10;
    if (corto_rs !== CORTO_WB) $fatal("Error: corto_rs = %d, expected %d", corto_rs, CORTO_WB);
    if (corto_rt !== CORTO_MEM) $fatal("Error: corto_rt = %d, expected %d", corto_rt, CORTO_MEM);

    #10;
    $display("10.");
    WB_write__out_mem = 1;  // la instruccion en WB escribe en el WB
    write_reg__out_mem = 27;  // el registro 27
    WB_write__out_execute = 1;  // la instruccion en MEM escribe en el WB
    write_reg__out_execute = 20;  // el registro 20
    rs = 20;
    rt = 27;
    #10;
    if (corto_rs !== CORTO_MEM) $fatal("Error: corto_rs = %d, expected %d", corto_rs, CORTO_MEM);
    if (corto_rt !== CORTO_WB) $fatal("Error: corto_rt = %d, expected %d", corto_rt, CORTO_WB);

    $display("Passed Unidad de Cortocircuito Test Bench");
    $finish;
  end
endmodule

