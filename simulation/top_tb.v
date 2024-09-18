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

  integer i;

  // Senales de entrada
  reg [NB_SW-1:0] i_sw;
  reg [NB_BTN-1:0] i_btn;
  reg i_clk;
  reg i_reset;
  reg signed [NB_DATA-1:0] i_data_A, i_data_B;

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
    i_data_A = 0;
    i_data_B = 0;

    // Prueba de reset
    #40 i_reset = 1;  // Activar reset
    #40 i_reset = 0;  // Desactivar reset

    // Configuracion de operacion de suma (ADD)
    i_sw  = ADD_OP;  // Codigo de operacion ADD
    i_btn = 3'b100;  // Boton para cargar operador
    #40;
    i_btn = 3'b000;  // Liberar boton

    for (i = 0; i < 10; i = i + 1) begin
      i_data_B = $urandom % (2 ** NB_DATA);
      i_data_A = $urandom % (2 ** NB_DATA);
      #40;

      i_sw  = i_data_A;
      i_btn = 3'b001;  // Boton para cargar operando A
      #40;  // Espero un ciclo de clock
      i_btn = 3'b000;  // Liberar boton
      #40;

      i_sw  = i_data_B;
      i_btn = 3'b010;  // Boton para cargar operando B
      #40;
      i_btn = 3'b000;  // Liberar boton

      if (o_led !== (i_data_A + i_data_B)) begin
        $fatal("Test Failed: OP = ADD_OP, Result = %d, Expected = %d", o_led, i_data_A + i_data_B);
      end
    end


    #40;

    // Configuracion de operacion de resta (SUB)
    i_sw  = SUB_OP;  // Codigo de operacion ADD
    i_btn = 3'b100;  // Boton para cargar operador
    #40;
    i_btn = 3'b000;  // Liberar boton

    for (i = 0; i < 10; i = i + 1) begin
      i_data_B = $urandom % (2 ** NB_DATA);
      i_data_A = $urandom % (2 ** NB_DATA);
      #40;

      i_sw  = i_data_A;
      i_btn = 3'b001;  // Boton para cargar operando A
      #40;  // Espero un ciclo de clock
      i_btn = 3'b000;  // Liberar boton
      #40;

      i_sw  = i_data_B;
      i_btn = 3'b010;  // Boton para cargar operando B
      #40;
      i_btn = 3'b000;  // Liberar boton

      if (o_led !== (i_data_A - i_data_B)) begin
        $fatal("Test Failed: OP = SUB_OP, Result = %d, Expected = %d", o_led, i_data_A - i_data_B);
      end
    end

    // Terminar simulacion
    $finish;
  end

endmodule
