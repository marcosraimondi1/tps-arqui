module uart_tx #(
    NB_DATA = 8,
    NB_STOP = 1
) (
    input wire i_reset,
    input wire i_tick,
    input wire i_clk,
    input wire i_tx_start,
    input wire [NB_DATA-1:0] i_tx_data,
    output wire o_tx_done,
    output wire o_tx
);

  localparam IDLE_STATE = 1'b0;
  localparam SEND_STATE = 1'b1;
  localparam FRAME_LEN = NB_DATA + 1 + (NB_STOP);

  reg state, next_state;
  reg [3:0] tick_count, next_tick_count;
  reg [3:0] data_count, next_data_count;
  reg tx, next_tx;
  reg [FRAME_LEN-1:0] data, next_data;  // Trama con bits de STOP y START
  reg tx_done;

  // State manager
  always @(posedge i_clk, posedge i_reset) begin
    if (i_reset) begin
      state <= IDLE_STATE;
      tick_count <= 0;
      data_count <= 0;
      data <= {FRAME_LEN{1'b0}};
      tx <= 1'b1;
    end else begin
      state <= next_state;
      tick_count <= next_tick_count;
      data_count <= next_data_count;
      data <= next_data;
      tx <= next_tx;
    end
  end

  always @(*) begin
    next_state = state;
    tx_done = 1'b0;
    next_tick_count = tick_count;
    next_data_count = data_count;
    next_data = data;
    next_tx = tx;
    case (state)
      IDLE_STATE: begin
        next_tx = 1'b1;
        if (i_tx_start) begin
          next_data = {{NB_STOP{1'b1}}, i_tx_data, 1'b0};
          next_state = SEND_STATE;
          next_data_count = 0;
          next_tick_count = 0;
        end
      end

      SEND_STATE: begin
        next_tx = data[0];  // enviar siguiente bit
        if (i_tick) begin
          if (tick_count < 15) begin
            next_tick_count = tick_count + 1;
          end else begin
            next_tick_count = 0;
            next_data = data >> 1;  // En data[0] esta el siguiente bit
            if (data_count < (FRAME_LEN - 1)) begin
              next_data_count = data_count + 1;
            end else begin
              // terminamos de enviar
              next_state = IDLE_STATE;
              tx_done = 1'b1;
            end
          end
        end

      end

      default: begin
        next_state = IDLE_STATE;
      end
    endcase
  end

  assign o_tx = tx;
  assign o_tx_done = tx_done;


endmodule
