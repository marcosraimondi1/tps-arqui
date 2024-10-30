`timescale 1ns / 1ps

module unidad_deteccion_riesgos_tb;

  reg [4:0] rs_ID;
  reg [4:0] rt_ID;
  reg [4:0] rt_EX;
  reg MEM_read__out_decode;
  wire stall;

  reg [1:0] salto_con_registro;
  reg [4:0] reg_dst_EX;
  reg [4:0] write_reg__out_execute;
  reg [4:0] write_reg__out_mem;
  reg WB_write__out_decode;
  reg WB_write__out_execute;
  reg WB_write__out_mem;

  unidad_deteccion_riesgos unidad_deteccion_riesgos1 (
      .i_rs_ID(rs_ID),
      .i_rt_ID(rt_ID),
      .i_rt_EX(rt_EX),
      .i_mem_read_EX(MEM_read__out_decode),

      .i_salto_con_registro(salto_con_registro),  // 00 no salto, 01 salto usando rs y rt
                                                  // , 10 salto usando rs
      .i_reg_dst_EX(reg_dst_EX),
      .i_reg_dst_MEM(write_reg__out_execute),
      .i_reg_dst_WB(write_reg__out_mem),
      .i_WB_write_EX(WB_write__out_decode),
      .i_WB_write_MEM(WB_write__out_execute),
      .i_WB_write_WB(WB_write__out_mem),
      .o_stall(stall)
  );

  initial begin
    rs_ID = 0;
    rt_ID = 0;
    rt_EX = 0;
    MEM_read__out_decode = 0;

    salto_con_registro = 0;
    reg_dst_EX = 0;
    write_reg__out_execute = 0;
    write_reg__out_mem = 0;
    WB_write__out_decode = 0;
    WB_write__out_execute = 0;
    WB_write__out_mem = 0;

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

    #10;
    $display("11.");
    MEM_read__out_decode = 0;  // no se lee de la memoria
    salto_con_registro = 2'b01;  // salto usando rs y rt
    rs_ID = 2;
    rt_ID = 1;

    reg_dst_EX = 2;
    write_reg__out_execute = 0;
    write_reg__out_mem = 0;

    WB_write__out_decode = 1;
    WB_write__out_execute = 0;
    WB_write__out_mem = 0;
    #10;
    if (stall !== 1) $fatal("Error: stall = %d, expected %d", stall, 1);

    #10;
    $display("12.");
    MEM_read__out_decode = 0;  // no se lee de la memoria
    salto_con_registro = 2'b01;  // salto usando rs y rt
    rs_ID = 2;
    rt_ID = 1;

    reg_dst_EX = 0;
    write_reg__out_execute = 2;
    write_reg__out_mem = 0;

    WB_write__out_decode = 0;
    WB_write__out_execute = 1;
    WB_write__out_mem = 0;
    #10;
    if (stall !== 1) $fatal("Error: stall = %d, expected %d", stall, 1);

    #10;
    $display("13.");
    MEM_read__out_decode = 0;  // no se lee de la memoria
    salto_con_registro = 2'b01;  // salto usando rs y rt
    rs_ID = 2;
    rt_ID = 1;

    reg_dst_EX = 0;
    write_reg__out_execute = 0;
    write_reg__out_mem = 2;

    WB_write__out_decode = 0;
    WB_write__out_execute = 0;
    WB_write__out_mem = 1;
    #10;
    if (stall !== 1) $fatal("Error: stall = %d, expected %d", stall, 1);

    #10;
    $display("14.");
    MEM_read__out_decode = 0;  // no se lee de la memoria
    salto_con_registro = 2'b01;  // salto usando rs y rt
    rs_ID = 2;
    rt_ID = 1;

    reg_dst_EX = 0;
    write_reg__out_execute = 0;
    write_reg__out_mem = 1;

    WB_write__out_decode = 0;
    WB_write__out_execute = 0;
    WB_write__out_mem = 1;
    #10;
    if (stall !== 1) $fatal("Error: stall = %d, expected %d", stall, 1);

    #10;
    $display("15.");
    MEM_read__out_decode = 0;  // no se lee de la memoria
    salto_con_registro = 2'b01;  // salto usando rs y rt
    rs_ID = 2;
    rt_ID = 1;

    reg_dst_EX = 0;
    write_reg__out_execute = 1;
    write_reg__out_mem = 0;

    WB_write__out_decode = 0;
    WB_write__out_execute = 1;
    WB_write__out_mem = 0;
    #10;
    if (stall !== 1) $fatal("Error: stall = %d, expected %d", stall, 1);

    #10;
    $display("16.");
    MEM_read__out_decode = 0;  // no se lee de la memoria
    salto_con_registro = 2'b01;  // salto usando rs y rt
    rs_ID = 2;
    rt_ID = 1;

    reg_dst_EX = 1;
    write_reg__out_execute = 0;
    write_reg__out_mem = 0;

    WB_write__out_decode = 1;
    WB_write__out_execute = 0;
    WB_write__out_mem = 0;
    #10;
    if (stall !== 1) $fatal("Error: stall = %d, expected %d", stall, 1);

    #10;
    $display("17.");
    MEM_read__out_decode = 0;  // no se lee de la memoria
    salto_con_registro = 2'b10;  // salto usando solo rs
    rs_ID = 1;
    rt_ID = 2;

    reg_dst_EX = 0;
    write_reg__out_execute = 0;
    write_reg__out_mem = 2;

    WB_write__out_decode = 0;
    WB_write__out_execute = 0;
    WB_write__out_mem = 1;
    #10;
    if (stall !== 0) $fatal("Error: stall = %d, expected %d", stall, 1);

    #10;
    $display("18.");
    MEM_read__out_decode = 0;  // no se lee de la memoria
    salto_con_registro = 2'b10;  // salto usando solo rs
    rs_ID = 1;
    rt_ID = 2;

    reg_dst_EX = 0;
    write_reg__out_execute = 1;
    write_reg__out_mem = 2;

    WB_write__out_decode = 0;
    WB_write__out_execute = 1;
    WB_write__out_mem = 1;
    #10;
    if (stall !== 1) $fatal("Error: stall = %d, expected %d", stall, 1);

    #10;
    $display("19.");
    MEM_read__out_decode = 0;  // no se lee de la memoria
    salto_con_registro = 2'b10;  // salto usando solo rs
    rs_ID = 1;
    rt_ID = 2;

    reg_dst_EX = 1;
    write_reg__out_execute = 1;
    write_reg__out_mem = 2;

    WB_write__out_decode = 1;
    WB_write__out_execute = 1;
    WB_write__out_mem = 1;
    #10;
    if (stall !== 1) $fatal("Error: stall = %d, expected %d", stall, 1);

    #10;
    $display("20.");
    MEM_read__out_decode = 0;  // no se lee de la memoria
    salto_con_registro = 2'b10;  // salto usando solo rs
    rs_ID = 1;
    rt_ID = 2;

    reg_dst_EX = 1;
    write_reg__out_execute = 0;
    write_reg__out_mem = 0;

    WB_write__out_decode = 1;
    WB_write__out_execute = 0;
    WB_write__out_mem = 0;
    #10;
    if (stall !== 1) $fatal("Error: stall = %d, expected %d", stall, 1);

    #10;
    $display("21.");
    MEM_read__out_decode = 0;  // no se lee de la memoria
    salto_con_registro = 2'b11;  // no salto
    rs_ID = 1;
    rt_ID = 2;

    reg_dst_EX = 1;
    write_reg__out_execute = 0;
    write_reg__out_mem = 0;

    WB_write__out_decode = 1;
    WB_write__out_execute = 0;
    WB_write__out_mem = 0;
    #10;
    if (stall !== 0) $fatal("Error: stall = %d, expected %d", stall, 1);

    $display("Passed Unidad de Deteccion de Riesgos Test Bench");
    $finish;
  end
endmodule
