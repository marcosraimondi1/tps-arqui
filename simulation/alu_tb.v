`timescale 1ns / 1ps

module alu_tb;

  // Parametros
  localparam NB_OP = 6;
  localparam NB_DATA = 8;
  // Operadores
  localparam ADD_OP = 6'b100000;
  localparam SUB_OP = 6'b100010;
  localparam AND_OP = 6'b100100;
  localparam OR_OP  = 6'b100101;
  localparam XOR_OP = 6'b100110;
  localparam SRA_OP = 6'b000011;
  localparam SRL_OP = 6'b000010;
  localparam NOR_OP = 6'b100111;

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
    i_data_A = 8'd10;
    i_data_B = 8'd5;
    i_op = ADD_OP;
    #10;
    if(o_data !== (i_data_A + i_data_B)) begin
      $fatal("Test Failed: OP = ADD_OP, Result = %d, Expected = %d", o_data, i_data_A + i_data_B);
    end else begin
      $display("Test Passed: OP = ADD_OP");
    end

    // Test de resta
    i_data_A = 8'd15;
    i_data_B = 8'd5;
    i_op = SUB_OP;
    #10;
    if(o_data !== (i_data_A - i_data_B)) begin
     $fatal("Test Failed: OP = SUB_OP, Result = %d, Expected = %d", o_data, i_data_A - i_data_B);
    end else begin
      $display("Test Passed: OP = SUB_OP");
    end

    // Test de AND
    i_data_A = 8'b11001100;
    i_data_B = 8'b10101010;
    i_op = AND_OP;
    #10;
    if(o_data !== (i_data_A & i_data_B)) begin
      $fatal("Test Failed: OP = AND_OP, Result = %d, Expected = %d", o_data, i_data_A & i_data_B);
    end else begin
      $display("Test Passed: OP = AND_OP");
    end

    // Test de OR
    i_data_A = 8'b11001100;
    i_data_B = 8'b10101010;
    i_op = OR_OP;
    #10;
    if(o_data !== (i_data_A | i_data_B)) begin
      $fatal("Test Failed: OP = OR_OP, Result = %d, Expected = %d", o_data, i_data_A | i_data_B);
    end else begin
      $display("Test Passed: OP = OR_OP");
    end

    // Test de XOR
    i_data_A = 8'b11001100;
    i_data_B = 8'b10101010;
    i_op = XOR_OP;
    #10;
    if(o_data !== (i_data_A ^ i_data_B)) begin
      $fatal("Test Failed: OP = XOR_OP, Result = %d, Expected = %d", o_data, i_data_A ^ i_data_B);
    end else begin
      $display("Test Passed: OP = XOR_OP");
    end

    // Test de Shift Right Arithmetic (SRA)
    i_data_A = -8'd16;  // -16 en complemento a dos
    i_data_B = 8'd2;
    i_op = SRA_OP;
    #10;
    if(o_data !== (i_data_A >>> i_data_B)) begin
      $fatal("Test Failed: OP = SRA_OP, Result = %d, Expected = %d",o_data, i_data_A >>> i_data_B);
    end else begin
      $display("Test Passed: OP = SRA_OP");
    end

    // Test de Shift Right Logical (SRL)
    i_data_A = 8'd16;
    i_data_B = 8'd2;
    i_op = SRL_OP;
    #10;
    if(o_data !== (i_data_A >> i_data_B)) begin
      $fatal("Test Failed: OP = SRL_OP, Result = %d, Expected = %d", o_data, i_data_A >> i_data_B);
    end else begin
      $display("Test Passed: OP = SRL_OP");
    end

    // Test de NOR
    i_data_A = 8'b11001100;
    i_data_B = 8'b10101010;
    i_op = NOR_OP;
    #10;
    if(o_data !== (~(i_data_A | i_data_B))) begin
      $fatal("Test Failed: OP = NOR_OP, Result = %d, Expected = %d",o_data,~(i_data_A | i_data_B));
    end else begin
      $display("Test Passed: OP = NOR_OP");
    end

    $finish;
  end
endmodule
