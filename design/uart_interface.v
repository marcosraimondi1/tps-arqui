module uart_interface #(
    parameter NB_DATA   = 8,
    parameter NB_ALU_OP = 6
) (
    input wire i_clk,
    input wire i_reset,
    input wire i_rx_done,
    input wire i_tx_done,
    input wire [NB_DATA-1:0] i_rx_data,
    input wire [NB_DATA-1:0] i_alu_data_out,
    output wire [NB_DATA-1:0] o_tx_data,
    output wire [5:0] o_alu_op,
    output wire [NB_DATA-1:0] o_alu_data_A,
    output wire [NB_DATA-1:0] o_alu_data_B,
    output wire o_tx_start
);

  // states
  localparam IDLE_STATE = 2'b00;
  localparam LOAD_STATE = 2'b01;
  localparam SEND_STATE = 2'b10;
  localparam WAIT_SEND_STATE = 2'b11;

  // opcodes
  localparam ALU_DATA_A_OP = 8'b00000000;
  localparam ALU_DATA_B_OP = 8'b00000001;
  localparam GET_RESULT_OP = 8'b00000010;
  localparam ALU_OPERATOR_OP = 8'b00000011;

  reg [1:0] state, next_state;
  reg [7:0] opcode, next_opcode;
  reg [NB_DATA-1:0] alu_data_A, next_alu_data_A;
  reg [NB_DATA-1:0] alu_data_B, next_alu_data_B;
  reg [NB_ALU_OP-1:0] alu_op, next_alu_op;
  reg [NB_DATA-1:0] tx_data, next_tx_data;
  reg tx_start, next_tx_start;
  reg opcode_error_flag, next_opcode_error_flag;

  always @(posedge i_clk or posedge i_reset) begin
    if (i_reset) begin
      state <= IDLE_STATE;
      opcode <= 2'b00;
      alu_data_A <= 0;
      alu_data_B <= 0;
      alu_op <= 0;
      tx_data <= 0;
      tx_start <= 0;
      opcode_error_flag <= 0;
    end else begin
      state <= next_state;
      opcode <= next_opcode;
      alu_data_A <= next_alu_data_A;
      alu_data_B <= next_alu_data_B;
      alu_op <= next_alu_op;
      tx_data <= next_tx_data;
      tx_start <= next_tx_start;
      opcode_error_flag <= next_opcode_error_flag;
    end
  end

  always @(*) begin
    next_state = state;
    next_opcode = opcode;

    next_alu_data_A = alu_data_A;
    next_alu_data_B = alu_data_B;
    next_alu_op = alu_op;
    next_tx_data = tx_data;
    next_tx_start = 1'b0;
    next_opcode_error_flag = opcode_error_flag;

    case (state)
      IDLE_STATE: begin
        if (i_rx_done) begin
          // check opcode
          next_opcode = i_rx_data;
          case (i_rx_data)
            GET_RESULT_OP: begin
              next_state = SEND_STATE;
            end

            ALU_DATA_A_OP: begin
              next_state = LOAD_STATE;
            end

            ALU_DATA_B_OP: begin
              next_state = LOAD_STATE;
            end

            ALU_OPERATOR_OP: begin
              next_state = LOAD_STATE;
            end

            default: begin
              next_opcode_error_flag = 1'b1;
              next_state = SEND_STATE;
            end
          endcase

        end
      end

      LOAD_STATE: begin
        // wait for value
        if (i_rx_done) begin
          case (opcode)
            ALU_DATA_A_OP: begin
              next_alu_data_A = i_rx_data;
            end
            ALU_DATA_B_OP: begin
              next_alu_data_B = i_rx_data;
            end
            ALU_OPERATOR_OP: begin
              next_alu_op = i_rx_data[NB_ALU_OP-1:0];
            end
            default: begin
              // do nothing
            end
          endcase

          next_state = IDLE_STATE;
        end
      end

      SEND_STATE: begin
        // send alu result
        if (opcode_error_flag) begin
          next_opcode_error_flag = 1'b0;
          next_tx_data = 8'b11111111;
        end else begin
          next_tx_data = i_alu_data_out;
        end
        next_tx_start = 1'b1;
        next_state = IDLE_STATE;
      end

      default: next_state = IDLE_STATE;
    endcase
  end

  assign o_tx_data = tx_data;
  assign o_alu_op = alu_op;
  assign o_alu_data_A = alu_data_A;
  assign o_alu_data_B = alu_data_B;
  assign o_tx_start = tx_start;

endmodule
