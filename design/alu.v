module alu #(
    parameter NB_OP   = 6,
    parameter NB_DATA = 8
) (
    input wire [NB_OP-1 : 0] i_op,
    input wire signed [NB_DATA-1:0] i_data_A,
    input wire signed [NB_DATA-1:0] i_data_B,
    output wire signed [NB_DATA-1:0] o_data
);

  localparam ADD_OP = 6'b100000;
  localparam SUB_OP = 6'b100010;
  localparam AND_OP = 6'b100100;
  localparam OR_OP = 6'b100101;
  localparam XOR_OP = 6'b100110;
  localparam SRA_OP = 6'b000011;
  localparam SRL_OP = 6'b000010;
  localparam NOR_OP = 6'b100111;

  reg signed [NB_DATA-1:0] res;

  always @(*) begin : alu
    case (i_op)
      ADD_OP:  res = i_data_A + i_data_B;
      SUB_OP:  res = i_data_A - i_data_B;
      AND_OP:  res = i_data_A & i_data_B;
      OR_OP:   res = i_data_A | i_data_B;
      XOR_OP:  res = i_data_A ^ i_data_B;
      SRA_OP:  res = i_data_A >>> i_data_B;  // aritmetico: el nuevo bit mantiene el signo
      SRL_OP:  res = i_data_A >> i_data_B;  // logico: el nuevo bit es 0
      NOR_OP:  res = ~(i_data_A | i_data_B);
      default: res = 8'ha1;
    endcase
  end

  assign o_data = res;

endmodule
