module alu #(
    parameter NB_OP   = 6,
    parameter NB_DATA = 8
) (
    input wire [NB_OP-1 : 0] i_op,
    input wire signed [NB_DATA-1:0] i_data_A,
    input wire signed [NB_DATA-1:0] i_data_B,
    input wire [4:0] i_shamt,
    output wire [NB_DATA-1:0] o_data
);

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

  reg signed [NB_DATA-1:0] res;
  reg [NB_DATA-1:0] res_u;
  wire [NB_DATA-1:0] data_A_u;
  wire [NB_DATA-1:0] data_B_u;
  wire is_unsigned;

  always @(*) begin : alu
    res   = 0;
    res_u = 0;
    case (i_op)
      IDLE_OP: res = {NB_DATA{1'b0}};
      ADD_OP:  res = i_data_A + i_data_B;
      SUB_OP:  res = i_data_A - i_data_B;
      SLL_OP:  res = i_data_B << i_shamt;
      SRL_OP:  res = i_data_B >> i_shamt;
      SRA_OP:  res = i_data_B >>> i_shamt;
      SLLV_OP: res = i_data_B << i_data_A;
      SRLV_OP: res = i_data_B >> i_data_A;
      SRAV_OP: res = i_data_B >>> i_data_A;
      ADDU_OP: res_u = data_A_u + data_B_u;
      SUBU_OP: res_u = data_A_u - data_B_u;
      AND_OP:  res = i_data_A & i_data_B;
      OR_OP:   res = i_data_A | i_data_B;
      XOR_OP:  res = i_data_A ^ i_data_B;
      NOR_OP:  res = ~(i_data_A | i_data_B);
      SLT_OP:  res = (i_data_A < i_data_B) ? 1 : 0;
      ADDI_OP: res = i_data_A + i_data_B;
      ANDI_OP: res = i_data_A & i_data_B;
      ORI_OP:  res = i_data_A | i_data_B;
      XORI_OP: res = i_data_A ^ i_data_B;
      LUI_OP:  res = i_data_B << 16;
      SLTI_OP: res = (i_data_A < i_data_B) ? 1 : 0;
      default: res = {{(NB_DATA - 8) {1'b0}}, {8'ha1}};
    endcase
  end

  assign o_data = is_unsigned ? res_u : res;
  assign data_A_u = i_data_A;
  assign data_B_u = i_data_B;
  assign is_unsigned = (i_op == ADDU_OP) || (i_op == SUBU_OP);

endmodule
