`timescale 1ns / 1ps

module alu_tb;

  // Parámetros
  localparam NB_OP = 6;
  localparam NB_DATA = 8;

  // Senales
  reg [NB_OP-1:0] i_op;
  reg signed [NB_DATA-1:0] i_data_A, i_data_B;
  wire signed [NB_DATA-1:0] o_data;

  // Instanciación del módulo ALU
  alu #(
      .NB_OP  (NB_OP),
      .NB_DATA(NB_DATA)
  ) alu1 (
      .i_op(i_op),
      .i_data_A(i_data_A),
      .i_data_B(i_data_B),
      .o_data(o_data)
  );

  // Procedimiento para imprimir resultados del test
  task static print_result;
    input [NB_OP-1:0] operation;
    input signed [NB_DATA-1:0] expected;
    input signed [NB_DATA-1:0] result;
    begin
      if (expected === result) begin
        $display("Test Passed: OP = %b, Result = %d, Expected = %d", operation, result, expected);
      end else begin
        $display("Test Failed: OP = %b, Result = %d, Expected = %d", operation, result, expected);
      end
    end
  endtask

  // Testbench
  initial begin
    // Test de suma
    i_data_A = 8'd10;
    i_data_B = 8'd5;
    i_op = 6'b100000;  // ADD_OP
    #10;
    print_result(i_op, i_data_A + i_data_B, o_data);

    // Test de resta
    i_data_A = 8'd15;
    i_data_B = 8'd5;
    i_op = 6'b100010;  // SUB_OP
    #10;
    print_result(i_op, i_data_A - i_data_B, o_data);

    // Test de AND
    i_data_A = 8'b11001100;
    i_data_B = 8'b10101010;
    i_op = 6'b100100;  // AND_OP
    #10;
    print_result(i_op, i_data_A & i_data_B, o_data);

    // Test de OR
    i_data_A = 8'b11001100;
    i_data_B = 8'b10101010;
    i_op = 6'b100101;  // OR_OP
    #10;
    print_result(i_op, i_data_A | i_data_B, o_data);

    // Test de XOR
    i_data_A = 8'b11001100;
    i_data_B = 8'b10101010;
    i_op = 6'b100110;  // XOR_OP
    #10;
    print_result(i_op, i_data_A ^ i_data_B, o_data);

    // Test de Shift Right Arithmetic (SRA)
    i_data_A = -8'd16;  // -16 en complemento a dos
    i_data_B = 8'd2;
    i_op = 6'b000011;  // SRA_OP
    #10;
    print_result(i_op, i_data_A >>> i_data_B, o_data);

    // Test de Shift Right Logical (SRL)
    i_data_A = 8'd16;
    i_data_B = 8'd2;
    i_op = 6'b000010;  // SRL_OP
    #10;
    print_result(i_op, i_data_A >> i_data_B, o_data);

    // Test de NOR
    i_data_A = 8'b11001100;
    i_data_B = 8'b10101010;
    i_op = 6'b100111;  // NOR_OP
    #10;
    print_result(i_op, ~(i_data_A | i_data_B), o_data);

    $finish;
  end
endmodule
