`timescale 1ns / 1ps

module unidad_deteccion_riesgos_tb;

  reg [4:0] rs_ID;
  reg [4:0] rt_ID;
  reg [4:0] rt_EX;
  reg MEM_read__out_decode;
  wire stall;

  unidad_deteccion_riesgos unidad_deteccion_riesgos1 (
      .i_rs_ID(rs_ID),
      .i_rt_ID(rt_ID),
      .i_rt_EX(rt_EX),
      .i_mem_read_EX(MEM_read__out_decode),
      .o_stall(stall)
  );

  initial begin
    rs_ID = 0;
    rt_ID = 0;
    rt_EX = 0;
    MEM_read__out_decode = 0;

    #10;
    $display("1.");
    if (stall !== 0) $fatal("Error: stall = %d, expected %d", stall, 0);

    #10;
    $display("2.");
    MEM_read__out_decode = 1;  // se lee de la memoria
    rt_EX = 2;  // y se carga en el registro 2
    rs_ID = 1;
    rt_ID = 3;
    #10;
    if (stall !== 0) $fatal("Error: stall = %d, expected %d", stall, 0);

    #10;
    $display("3.");
    MEM_read__out_decode = 0;  // no se lee de la memoria
    rt_EX = 2;  // y se carga en el registro 2
    rs_ID = 2;  // se lee el registro 2
    rt_ID = 2;
    #10;
    if (stall !== 0) $fatal("Error: stall = %d, expected %d", stall, 0);

    #10;
    $display("4.");
    MEM_read__out_decode = 1;  // se lee de la memoria
    #10;
    if (stall !== 1) $fatal("Error: stall = %d, expected %d", stall, 1);

    #10;
    $display("5.");
    MEM_read__out_decode = 1;  // se lee de la memoria
    rt_EX = 25;  // y se carga en el registro 2
    rs_ID = 25;
    rt_ID = 2;
    #10;
    if (stall !== 1) $fatal("Error: stall = %d, expected %d", stall, 1);

    #10;
    $display("6.");
    MEM_read__out_decode = 1;  // se lee de la memoria
    rt_EX = 31;  // y se carga en el registro 2
    rs_ID = 25;
    rt_ID = 31;
    #10;
    if (stall !== 1) $fatal("Error: stall = %d, expected %d", stall, 1);

    #10;
    $display("7.");
    MEM_read__out_decode = 1;  // se lee de la memoria
    rt_EX = 31;  // y se carga en el registro 2
    rs_ID = 25;
    rt_ID = 20;
    #10;
    if (stall !== 0) $fatal("Error: stall = %d, expected %d", stall, 0);

    #10;
    $display("8.");
    MEM_read__out_decode = 0;  // se lee de la memoria
    rt_EX = 31;  // y se carga en el registro 2
    rs_ID = 25;
    rt_ID = 20;
    #10;
    if (stall !== 0) $fatal("Error: stall = %d, expected %d", stall, 0);

    #10;
    $display("9.");
    MEM_read__out_decode = 0;  // se lee de la memoria
    rt_EX = 25;  // y se carga en el registro 2
    rs_ID = 25;
    rt_ID = 20;
    #10;
    if (stall !== 0) $fatal("Error: stall = %d, expected %d", stall, 0);

    #10;
    $display("10.");
    MEM_read__out_decode = 1;  // se lee de la memoria
    rt_EX = 20;  // y se carga en el registro 2
    rs_ID = 25;
    rt_ID = 20;
    #10;
    if (stall !== 1) $fatal("Error: stall = %d, expected %d", stall, 1);

    $display("Passed Unidad de Deteccion de Riesgos Test Bench");
    $finish;
  end
endmodule
