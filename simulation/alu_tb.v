`timescale 1ns / 1ps

module alu_tb;

  // Parametros
  localparam NB_OP = 6;
  localparam NB_DATA = 32;
  // Operadores
  localparam IDLE_OP = 6'b111111;
  localparam ADD_OP = 6'b100000;
  localparam SUB_OP = 6'b100010;
  localparam SLL_OP = 6'b000000;
  localparam SRL_OP = 6'b000010;
  localparam SRA_OP = 6'b000011;
  localparam SLLV_OP = 6'b000100;
  localparam SRLV_OP = 6'b000110;
  localparam SRAV_OP = 6'b000111;
  localparam ADDU_OP = 6'b100001;
  localparam SUBU_OP = 6'b100011;
  localparam AND_OP = 6'b100100;
  localparam OR_OP = 6'b100101;
  localparam XOR_OP = 6'b100110;
  localparam NOR_OP = 6'b100111;
  localparam SLT_OP = 6'b101010;
  // inmediatas
  localparam ADDI_OP = 6'b001000;
  localparam ANDI_OP = 6'b001100;
  localparam ORI_OP = 6'b001101;
  localparam XORI_OP = 6'b001110;
  localparam LUI_OP = 6'b001111;
  localparam SLTI_OP = 6'b001010;

  integer i;  // Contador de iteraciones

  // Senales
  reg [NB_OP-1:0] i_op;
  reg signed [NB_DATA-1:0] i_data_A;
  reg signed [NB_DATA-1:0] i_data_B;
  wire [NB_DATA-1:0] data_A_u;
  wire [NB_DATA-1:0] data_B_u;


  reg [4:0] i_shamt;
  wire [NB_DATA-1:0] o_data;

  wire signed [NB_DATA-1:0] o_data_s;
  assign o_data_s = o_data;

  // Instanciacion del modulo ALU
  alu #(
      .NB_OP  (NB_OP),
      .NB_DATA(NB_DATA)
  ) alu1 (
      .i_op(i_op),
      .i_data_A(i_data_A),
      .i_data_B(i_data_B),
      .i_shamt(i_shamt),
      .o_data(o_data)
  );

  // Testbench
  initial begin

    i_op = IDLE_OP;
    i_data_A = 0;
    i_data_B = 0;
    i_shamt = 0;

    #10;
    // Test de IDLE
    i_data_A = $urandom;
    i_data_B = $urandom;
    #10;
    if (o_data !== 0) begin
      $fatal("Test Failed: OP = IDLE_OP, Result = %d, Expected = 0", o_data);
    end

    // Test de suma
    i_op = ADD_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (i_data_A + i_data_B)) begin
        $fatal("Test Failed: OP = ADD_OP, Result = %d, Expected = %d", o_data, i_data_A + i_data_B);
      end
    end
    i_op = ADDI_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (i_data_A + i_data_B)) begin
        $fatal("Test Failed: OP = ADDI_OP, Result = %d, Expected = %d", o_data,
               i_data_A + i_data_B);
      end
    end
    i_op = ADDU_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (data_A_u + data_B_u)) begin
        $fatal("Test Failed: OP = ADDU_OP, Result = %d, Expected = %d", o_data,
               data_A_u + data_B_u);
      end
    end

    // Test de resta
    i_op = SUB_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (i_data_A - i_data_B)) begin
        $fatal("Test Failed: OP = SUB_OP, Result = %d, Expected = %d", o_data, i_data_A - i_data_B);
      end
    end
    i_op = SUBU_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (data_A_u - data_B_u)) begin
        $fatal("Test Failed: OP = SUBU_OP, Result = %d, Expected = %d", o_data,
               data_A_u - data_B_u);
      end
    end

    // Test de AND
    i_op = AND_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (i_data_A & i_data_B)) begin
        $fatal("Test Failed: OP = AND_OP, Result = %d, Expected = %d", o_data, i_data_A & i_data_B);
      end
    end
    i_op = ANDI_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (i_data_A & i_data_B)) begin
        $fatal("Test Failed: OP = ANDI_OP, Result = %d, Expected = %d", o_data,
               i_data_A & i_data_B);
      end
    end

    // Test de OR
    i_op = OR_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (i_data_A | i_data_B)) begin
        $fatal("Test Failed: OP = OR_OP, Result = %d, Expected = %d", o_data, i_data_A | i_data_B);
      end
    end

    i_op = ORI_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (i_data_A | i_data_B)) begin
        $fatal("Test Failed: OP = ORI_OP, Result = %d, Expected = %d", o_data, i_data_A | i_data_B);
      end
    end

    // Test de XOR
    i_op = XOR_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (i_data_A ^ i_data_B)) begin
        $fatal("Test Failed: OP = XOR_OP, Result = %d, Expected = %d", o_data, i_data_A ^ i_data_B);
      end
    end

    i_op = XORI_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (i_data_A ^ i_data_B)) begin
        $fatal("Test Failed: OP = XORI_OP, Result = %d, Expected = %d", o_data,
               i_data_A ^ i_data_B);
      end
    end

    // Test de LUI (Load Upper Immediate)
    i_op = LUI_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (i_data_B << 16)) begin
        $fatal("Test Failed: OP = LUI_OP, Result = %d, Expected = %d", o_data, i_data_B << 16);
      end
    end

    // Test de SLT (Set Less Than)
    i_op = SLT_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (i_data_A < i_data_B)) begin
        $fatal("Test Failed: OP = SLT_OP, Result = %d, Expected = %d", o_data, i_data_A < i_data_B);
      end
    end
    i_op = SLTI_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (i_data_A < i_data_B)) begin
        $fatal("Test Failed: OP = SLTI_OP, Result = %d, Expected = %d", o_data,
               i_data_A < i_data_B);
      end
    end

    // Test de Shift Right Arithmetic (SRA)
    i_op = SRA_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_B = $urandom;
      i_shamt  = $urandom % (2 ** 5);
      #10;

      if (o_data_s !== (i_data_B >>> i_shamt)) begin
        $fatal("Test Failed: OP = SRA_OP, Result = %d, Expected = %d", o_data,
               i_data_B >>> i_shamt);
      end
    end

    // Test de Shift Right Arithmetic Variable (SRAV)
    i_op = SRAV_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data_s !== (i_data_B >>> i_data_A)) begin
        $fatal("Test Failed: OP = SRAV_OP, Result = %d, Expected = %d", o_data,
               i_data_B >>> i_data_A);
      end
    end

    // Test de Shift Right Logical Variable (SRLV)
    i_op = SRLV_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (i_data_B >> i_data_A)) begin
        $fatal("Test Failed: OP = SRLV_OP, Result = %d, Expected = %d", o_data,
               i_data_B >> i_data_A);
      end
    end

    // Test de Shift Left Logical Variable (SLLV)
    i_op = SLLV_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (i_data_B << i_data_A)) begin
        $fatal("Test Failed: OP = SLLV, Result = %d, Expected = %d", o_data, i_data_B << i_data_A);
      end
    end

    // Test de Shift Right Logical (SRL)
    i_op = SRL_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_B = $urandom;
      i_shamt  = $urandom % (2 ** 5);
      #10;
      if (o_data !== (i_data_B >> i_shamt)) begin
        $fatal("Test Failed: OP = SRL_OP, Result = %d, Expected = %d", o_data, i_data_B >> i_shamt);
      end
    end

    // Test de Shift Left Logical (SLL)
    i_op = SLL_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      i_shamt  = $urandom % (2 ** 5);
      #10;
      if (o_data !== (i_data_B << i_shamt)) begin
        $fatal("Test Failed: OP = SLL_OP, Result = %d, Expected = %d", o_data, i_data_B << i_shamt);
      end
    end

    // Test de NOR
    i_op = NOR_OP;
    for (i = 0; i < 10; i = i + 1) begin
      i_data_A = $urandom;
      i_data_B = $urandom;
      #10;
      if (o_data !== (~(i_data_A | i_data_B))) begin
        $fatal("Test Failed: OP = NOR_OP, Result = %d, Expected = %d", o_data,
               ~(i_data_A | i_data_B));
      end
    end

    $display("Passed ALU Test Bench");

    $finish;
  end

  assign data_A_u = i_data_A;
  assign data_B_u = i_data_B;
endmodule

