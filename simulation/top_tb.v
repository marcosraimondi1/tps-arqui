`timescale 1ns / 1ps

module top_tb;

  // Parametros
  localparam NB_SW = 8;
  localparam NB_BTN = 3;
  localparam NB_LEDS = 8;
  localparam NB_DATA = 8;
  localparam NB_OP = 6;

  // Operadores
  localparam ADD_OP = 6'b100000;
  localparam SUB_OP = 6'b100010;
  localparam AND_OP = 6'b100100;
  localparam OR_OP = 6'b100101;
  localparam XOR_OP = 6'b100110;
  localparam SRA_OP = 6'b000011;
  localparam SRL_OP = 6'b000010;
  localparam NOR_OP = 6'b100111;

  // Senales de entrada
  reg [NB_SW-1:0] i_sw;
  reg [NB_BTN-1:0] i_btn;
  reg i_clk;
  reg i_reset;

  // Senales de salida
  wire [NB_LEDS-1:0] o_led;

  // Instanciacion del modulo top
  top #(
      .NB_SW  (NB_SW),
      .NB_BTN (NB_BTN),
      .NB_LEDS(NB_LEDS),
      .NB_DATA(NB_DATA),
      .NB_OP  (NB_OP)
  ) top1 (
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
    // Inicializacion de senales
    i_clk = 0;
    i_reset = 0;
    i_sw = 0;
    i_btn = 0;

    // Prueba de reset
    #10 i_reset = 1;  // Activar reset
    #10 i_reset = 0;  // Desactivar reset

    // Configuracion de operacion de suma (ADD)
    i_sw  = 8'b00001010;  // Operando A = 10
    i_btn = 3'b001;  // Boton para cargar operando A
    #10;  // Espero un ciclo de clock
    i_btn = 3'b000;  // Liberar boton

    i_sw  = 8'b00000101;  // Operando B = 5
    i_btn = 3'b010;  // Boton para cargar operando B
    #10;
    i_btn = 3'b000;  // Liberar boton

    i_sw  = ADD_OP;  // Codigo de operacion ADD
    i_btn = 3'b100;  // Boton para cargar operador
    #10;
    i_btn = 3'b000;  // Liberar boton

    #10;

    // Verificar resultado de suma
    if (o_led === 8'd15) begin
      $display("Test Passed: ADD operation, Result = %d", o_led);
    end else begin
      $display("Test Failed: ADD operation, Result = %d, Expected = 15", o_led);
    end

    // Configuracion de operacion de resta (SUB)
    i_sw  = 8'b00001111;  // Operando A = 15
    i_btn = 3'b001;  // Boton para cargar operando A
    #10;
    i_btn = 3'b000;  // Liberar boton

    i_sw  = 8'b00000101;  // Operando B = 5
    i_btn = 3'b010;  // Boton para cargar operando B
    #10;
    i_btn = 3'b000;  // Liberar boton

    i_sw  = SUB_OP;  // Codigo de operacion SUB
    i_btn = 3'b100;  // Boton para cargar operacion
    #10;
    i_btn = 3'b000;  // Liberar boton

    #10;

    // Verificar resultado de resta
    if (o_led === 8'd10) begin
      $display("Test Passed: SUB operation, Result = %d", o_led);
    end else begin
      $display("Test Failed: SUB operation, Result = %d, Expected = 10", o_led);
    end

    // Terminar simulacion
    $finish;
  end

endmodule
