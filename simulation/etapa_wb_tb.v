`timescale 1ns / 1ps

module etapa_wb_tb;

  // Declaración de registros para señales de entrada
  reg [4:0] i_write_reg;
  reg [31:0] i_ALU_result;
  reg [31:0] i_read_data;
  reg i_WB_write;
  reg i_WB_mem_to_reg;

  // Declaración de cables para las señales de salida
  wire [4:0] o_write_reg;
  wire [31:0] o_WB_data;
  wire o_WB_write;

  // Instancia del módulo etapa_wb
  etapa_wb etapa_wb1 (
      .i_write_reg(i_write_reg),
      .i_ALU_result(i_ALU_result),
      .i_read_data(i_read_data),
      .i_WB_write(i_WB_write),
      .i_WB_mem_to_reg(i_WB_mem_to_reg),
      .o_write_reg(o_write_reg),
      .o_WB_data(o_WB_data),
      .o_WB_write(o_WB_write)
  );

  // Bloque de pruebas
  initial begin
    // Inicializar señales de entrada
    i_write_reg = 5'd0;
    i_ALU_result = 32'd0;
    i_read_data = 32'd0;
    i_WB_write = 0;
    i_WB_mem_to_reg = 0;

    // Caso 1: Escritura con datos de la ALU
    #10;
    i_WB_write      = 1;
    i_WB_mem_to_reg = 1;  // Selección de datos de ALU
    i_write_reg     = 5'd15;  // Registro de destino
    i_ALU_result    = 32'hABCD1234;

    #10;
    $display("Caso 1 - ALU Data: o_WB_data = %h, o_write_reg = %d, o_WB_write = %b", o_WB_data,
             o_write_reg, o_WB_write);
    if ((o_WB_data != i_ALU_result)) begin
      $fatal("Failed Test Bench, i_ALU_result(ALU) = %h, o_WB_data = %h", i_ALU_result, o_WB_data);
    end
    if ((o_write_reg != i_write_reg)) begin
      $fatal("Failed Test Bench, expected = %d, o_write_reg = %d", i_write_reg, o_write_reg);
    end
    if ((o_WB_write != i_WB_write)) begin
      $fatal("Failed Test Bench, expected = %b, o_WB_write = %b", i_WB_write, o_WB_write);
    end
    // Caso 2: Escritura con datos de memoria
    #10;
    i_WB_mem_to_reg = 0;  // Selección de datos de memoria
    i_read_data     = 32'h1234ABCD;

    #10;
    $display("Caso 2 - MEM Data: o_WB_data = %h, o_write_reg = %d, o_WB_write = %b", o_WB_data,
             o_write_reg, o_WB_write);
    if ((o_WB_data != i_read_data)) begin
      $fatal("Failed Test Bench, i_read_data(MEM) = %h, o_WB_data = %h", i_read_data, o_WB_data);
    end
    // Caso 3: Sin escritura habilitada
    #10;
    i_WB_write      = 0;  // Deshabilitar escritura
    i_WB_mem_to_reg = 1;  // Selección de datos de ALU

    #10;
    $display("Caso 3 - No Write: o_WB_data = %h, o_write_reg = %d, o_WB_write = %b", o_WB_data,
             o_write_reg, o_WB_write);
    if ((o_WB_write != i_WB_write) | (o_WB_write != 0)) begin
      $fatal("Failed Test Bench, expected = %b, o_WB_write = %b", i_WB_write, o_WB_write);
    end

    $display("Passed ETAPA_WB Test Bench");
    // Fin de la simulación
    $finish;
  end

endmodule
