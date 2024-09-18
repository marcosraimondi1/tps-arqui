`timescale 1ns / 1ps

module alu_tb;

  // Parametros
  localparam NB_OP = 6;
  localparam NB_DATA = 8;
  // Operadores
  localparam ADD_OP = 6'b100000;
  localparam SUB_OP = 6'b100010;
  localparam AND_OP = 6'b100100;
  localparam OR_OP = 6'b100101;
  localparam XOR_OP = 6'b100110;
  localparam SRA_OP = 6'b000011;
  localparam SRL_OP = 6'b000010;
  localparam NOR_OP = 6'b100111;

  integer i;  // Contador de iteraciones

  // Senales
  reg [NB_OP-1:0] i_op;
  reg signed [NB_DATA-1:0] i_data_A, i_data_B;
  wire signed [NB_DATA-1:0] o_data;

  // Instanciacion del modulo ALU
  alu #(
      .NB_OP  (NB_OP),
      .NB_DATA(NB_DATA)
  ) alu1 (
      .i_op(i_op),
      .i_data_A(i_data_A),
      .i_data_B(i_data_B),
      .o_data(o_data)
  );

  // Testbench
  initial begin

    // Test de suma
    i_op = ADD_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom % (2 ** NB_DATA);
      i_data_B = $urandom % (2 ** NB_DATA);
      #10;
      if (o_data !== (i_data_A + i_data_B)) begin
        $fatal("Test Failed: OP = ADD_OP, Result = %d, Expected = %d", o_data, i_data_A + i_data_B);
      end
    end

    // Test de resta
    i_op = SUB_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom % (2 ** NB_DATA);
      i_data_B = $urandom % (2 ** NB_DATA);
      #10;
      if (o_data !== (i_data_A - i_data_B)) begin
        $fatal("Test Failed: OP = SUB_OP, Result = %d, Expected = %d", o_data, i_data_A - i_data_B);
      end
    end
    // Test de AND
    i_op = AND_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom % (2 ** NB_DATA);
      i_data_B = $urandom % (2 ** NB_DATA);
      #10;
      if (o_data !== (i_data_A & i_data_B)) begin
        $fatal("Test Failed: OP = AND_OP, Result = %d, Expected = %d", o_data, i_data_A & i_data_B);
      end
    end

    // Test de OR
    i_op = OR_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom % (2 ** NB_DATA);
      i_data_B = $urandom % (2 ** NB_DATA);
      #10;
      if (o_data !== (i_data_A | i_data_B)) begin
        $fatal("Test Failed: OP = OR_OP, Result = %d, Expected = %d", o_data, i_data_A | i_data_B);
      end
    end

    // Test de XOR
    i_op = XOR_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom % (2 ** NB_DATA);
      i_data_B = $urandom % (2 ** NB_DATA);
      #10;
      if (o_data !== (i_data_A ^ i_data_B)) begin
        $fatal("Test Failed: OP = XOR_OP, Result = %d, Expected = %d", o_data, i_data_A ^ i_data_B);
      end
    end

    // Test de Shift Right Arithmetic (SRA)
    i_op = SRA_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom % (2 ** NB_DATA);
      i_data_B = $urandom % (2 ** NB_DATA);
      #10;
      if (o_data !== (i_data_A >>> i_data_B)) begin
        $fatal("Test Failed: OP = SRA_OP, Result = %d, Expected = %d", o_data,
               i_data_A >>> i_data_B);
      end
    end

    // Test de Shift Right Logical (SRL)
    i_op = SRL_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom % (2 ** NB_DATA);
      i_data_B = $urandom % (2 ** NB_DATA);
      #10;
      if (o_data !== (i_data_A >> i_data_B)) begin
        $fatal("Test Failed: OP = SRL_OP, Result = %d, Expected = %d", o_data,
               i_data_A >> i_data_B);
      end
    end

    // Test de NOR
    i_op = NOR_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom % (2 ** NB_DATA);
      i_data_B = $urandom % (2 ** NB_DATA);
      #10;
      if (o_data !== (~(i_data_A | i_data_B))) begin
        $fatal("Test Failed: OP = NOR_OP, Result = %d, Expected = %d", o_data,
               ~(i_data_A | i_data_B));
      end
    end

    $display("Passed ALU Test Bench");

    $finish;
  end
endmodule
