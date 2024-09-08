`timescale 1ns / 1ps

module top_tb;

  // Parámetros
  localparam NB_SW = 8;
  localparam NB_BTN = 3;
  localparam NB_LEDS = 8;
  localparam NB_DATA = 8;
  localparam NB_OP = 6;

  // Señales de entrada
  reg [NB_SW-1:0] i_sw;
  reg [NB_BTN-1:0] i_btn;
  reg i_clk;
  reg i_reset;

  // Señales de salida
  wire [NB_LEDS-1:0] o_led;

  // Instanciación del módulo top
  top #(
      .NB_SW  (NB_SW),
      .NB_BTN (NB_BTN),
      .NB_LEDS(NB_LEDS),
      .NB_DATA(NB_DATA),
      .NB_OP  (NB_OP)
  ) dut (
      .i_sw(i_sw),
      .i_btn(i_btn),
      .i_clk(i_clk),
      .i_reset(i_reset),
      .o_led(o_led)
  );

  // Generador de reloj
  always #5 i_clk = ~i_clk;  // Reloj de 10ns

  // Procedimiento para inicializar y probar
  initial begin
    // Inicialización de señales
    i_clk = 0;
    i_reset = 1;
    i_sw = 0;
    i_btn = 0;

    // Prueba de reset
    #10 i_reset = 0;  // Activar reset
    #10 i_reset = 1;  // Desactivar reset

    // Configuración de operación de suma (ADD)
    i_sw  = 8'b00001010;  // Operando A = 10
    i_btn = 3'b001;  // Botón para cargar operando A
    #10;
    i_btn = 3'b000;  // Liberar botón

    i_sw  = 8'b00000101;  // Operando B = 5
    i_btn = 3'b010;  // Botón para cargar operando B
    #10;
    i_btn = 3'b000;  // Liberar botón

    i_sw  = 6'b100000;  // Código de operación ADD
    i_btn = 3'b100;  // Botón para cargar operación
    #10;
    i_btn = 3'b000;  // Liberar botón

    #10;  // Esperar para asegurar la operación

    // Verificar resultado de suma
    if (o_led === 8'd15) begin
      $display("Test Passed: ADD operation, Result = %d", o_led);
    end else begin
      $display("Test Failed: ADD operation, Result = %d, Expected = 15", o_led);
    end

    // Otras pruebas similares para SUB, AND, OR, etc.
    // Ejemplo para operación de resta (SUB)
    i_sw  = 8'b00001111;  // Operando A = 15
    i_btn = 3'b001;  // Botón para cargar operando A
    #10;
    i_btn = 3'b000;  // Liberar botón

    i_sw  = 8'b00000101;  // Operando B = 5
    i_btn = 3'b010;  // Botón para cargar operando B
    #10;
    i_btn = 3'b000;  // Liberar botón

    i_sw  = 6'b100010;  // Código de operación SUB
    i_btn = 3'b100;  // Botón para cargar operación
    #10;
    i_btn = 3'b000;  // Liberar botón

    #10;  // Esperar para asegurar la operación

    // Verificar resultado de resta
    if (o_led === 8'd10) begin
      $display("Test Passed: SUB operation, Result = %d", o_led);
    end else begin
      $display("Test Failed: SUB operation, Result = %d, Expected = 10", o_led);
    end

    // Terminar simulación
    $finish;
  end

endmodule
