module uart_tx #(
    NB_DATA = 8
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

  reg state;
  reg [NB_DATA+2-1:0] data;
  reg [3:0] tick_count;
  reg tx_done;
  reg tx;
  integer index;

  always @(posedge i_clk) begin
    if (i_reset) begin
      // reset
      data <= {(NB_DATA + 2) {1'b0}};
      tx <= 1;
      tx_done <= 0;
      tick_count <= 4'b0;
      index <= 0;
      state <= IDLE_STATE;

    end else begin
      case (state)
        IDLE_STATE: begin
          tx_done <= 0;
          tx <= 1;
          if (i_tx_start == 1'b1) begin
            data  <= {1'b1, i_tx_data, 1'b0};
            state <= SEND_STATE;
          end
        end

        SEND_STATE: begin
          if (i_tick) begin

            if (tick_count < 15) begin
              tick_count <= tick_count + 1;
            end else begin
              // enviar siguiente bit
              if (index < NB_DATA + 2) begin
                tx    <= data[index];
                index <= index + 1;
              end else begin
                // enviar ultimo dato
                state   <= IDLE_STATE;
                index   <= 0;
                tx_done <= 1;
              end

              tick_count <= 4'b0;
            end
          end

        end

        default: begin
          state <= IDLE_STATE;
          tx_done <= 0;
          tick_count <= 4'b0;
          index <= 0;
        end
      endcase
    end
  end

  assign o_tx = tx;
  assign o_tx_done = tx_done;


endmodule
