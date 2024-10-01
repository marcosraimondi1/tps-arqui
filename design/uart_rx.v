module uart_rx #(
    NB_DATA = 8,
    NB_STOP = 1
) (
    input wire i_reset,
    input wire i_clk,
    input wire i_tick,
    input wire i_rx,
    output wire [NB_DATA-1:0] o_rx_data,
    output wire o_rx_done
);

  localparam IDLE_STATE = 2'b00;
  localparam START_STATE = 2'b01;
  localparam DATA_STATE = 2'b10;
  localparam STOP_STATE = 2'b11;

  reg [1:0] state, next_state;

  reg [3:0] tick_count, next_tick_count;
  reg [2:0] data_count, next_data_count;
  reg [NB_DATA-1:0] data, next_data;
  reg rx_done;

  // State manager
  always @(posedge i_clk, posedge i_reset) begin
    if (i_reset) begin
      state <= IDLE_STATE;
      tick_count <= 0;
      data_count <= 0;
      data <= {NB_DATA{1'b0}};
    end else begin
      state <= next_state;
      tick_count <= next_tick_count;
      data_count <= next_data_count;
      data <= next_data;
    end
  end

  always @(*) begin
    next_state = state;
    rx_done = 1'b0;
    next_tick_count = tick_count;
    next_data_count = data_count;
    next_data = data;
    case (state)
      IDLE_STATE: begin
        if (~i_rx) begin
          // llego bit the start
          next_state = START_STATE;
          next_tick_count = 0;
        end
      end

      START_STATE: begin
        // alinearse con la mitad del bit de start
        if (i_tick) begin
          if (tick_count < 7) begin
            next_tick_count = tick_count + 1;
          end else begin
            // estamos alineados
            next_state = DATA_STATE;
            next_tick_count = 4'b0;
            next_data_count = 3'b0;
          end
        end
      end

      DATA_STATE: begin
        // recibir datos (NB_DATA bits)
        if (i_tick) begin
          if (tick_count < 15) begin
            next_tick_count = tick_count + 1;
          end else begin
            // llego el siguiente bit de datos
            next_tick_count = 4'b0;
            // ingresar nuevo valor
            next_data = {i_rx, data[NB_DATA-1:1]};  // agregamos el bit al MSB y corremos los demas
            if (data_count == (NB_DATA - 1)) begin
              next_state = STOP_STATE;
            end else begin
              next_data_count = data_count + 1;  // aumentar contador de datos
            end
          end
        end
      end

      STOP_STATE: begin
        if (i_tick) begin
          if (tick_count < (NB_STOP * 16 - 1)) begin
            // Esperamos la cantidad de tick para los STOP bits
            next_tick_count = tick_count + 1;
          end else begin
            // LLego toda la trama de UART
            next_state = IDLE_STATE;
            rx_done = 1'b1;
          end
        end
      end

      default: next_state = IDLE_STATE;
    endcase
  end

  assign o_rx_data = data;
  assign o_rx_done = rx_done;

endmodule
