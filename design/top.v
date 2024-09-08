module top #(
    parameter NB_SW   = 8,
    parameter NB_BTN  = 3,
    parameter NB_LEDS = 8,
    parameter NB_DATA = 8,
    parameter NB_OP   = 6
) (
    input wire [NB_SW-1:0] i_sw,
    input wire [NB_BTN-1:0] i_btn,
    input wire i_clk,
    input wire i_reset,
    output wire [NB_LEDS-1:0] o_led
);

  reg [  NB_OP - 1 : 0] alu_op;
  reg [NB_DATA - 1 : 0] alu_data_A;
  reg [NB_DATA - 1 : 0] alu_data_B;
  reg [NB_DATA - 1 : 0] alu_o_data;

  // Instanciación del módulo ALU
  alu #(
      .NB_OP  (NB_OP),
      .NB_DATA(NB_DATA)
  ) alu1 (
      .i_op(alu_op),
      .i_data_A(alu_data_A),
      .i_data_B(alu_data_B),
      .o_data(alu_o_data)
  );


  // Carga de operacion
  always @(posedge i_clk) begin
    if (~i_reset)  // negado porque creo que es un reset activo en bajo
      alu_op <= {NB_OP - 1{1'b0}};
    else if (i_btn[2]) alu_op <= i_sw[NB_OP-1:0];
    else alu_op <= alu_op;
  end

  // Carga de operandos
  always @(posedge i_clk) begin
    if (i_reset) // negado porque creo que es un reset activo en bajo
        begin
      alu_data_A <= {NB_DATA - 1{1'b0}};
      alu_data_B <= {NB_DATA - 1{1'b0}};
    end else if (i_btn[0]) begin
      alu_data_A <= i_sw[NB_DATA-1:0];
      alu_data_B <= alu_data_B;
    end else if (i_btn[1]) begin
      alu_data_B <= i_sw[NB_DATA-1:0];
      alu_data_A <= alu_data_A;
    end else begin
      alu_data_A <= alu_data_A;
      alu_data_B <= alu_data_B;
    end
  end

endmodule
