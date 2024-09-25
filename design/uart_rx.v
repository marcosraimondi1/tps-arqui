module uart_rx #(
    NB_DATA = 8
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

  reg [1:0] state;

  reg [3:0] tick_count;
  reg [NB_DATA-1:0] data;
  reg rx_done;
  integer data_count;

  always @(posedge i_clk) begin
    if (i_reset) begin
      state <= IDLE_STATE;
      data <= {NB_DATA{1'b0}};

      rx_done <= 0;
      tick_count <= 4'b0;
      data_count <= 0;

    end else begin
      case (state)
        IDLE_STATE: begin
          rx_done <= 0;
          data_count <= 0;
          tick_count <= 4'b0;
          if (i_rx == 0) begin
            // llego bit the start
            state <= START_STATE;
          end
        end

        START_STATE: begin
          // alinearse con la mitad del bit de start
          if (i_tick) begin
            if (tick_count < 7) begin
              tick_count <= tick_count + 1;
            end else begin
              // estamos alineados
              tick_count <= 4'b0;
              state <= DATA_STATE;
            end
          end
        end

        DATA_STATE: begin
          // recibir datos (NB_DATA bits)
          if (i_tick) begin
            if (tick_count < 15) begin
              tick_count <= tick_count + 1;
            end else if (data_count < NB_DATA) begin
              // llego el siguiente bit de datos
              tick_count <= 4'b0;

              // ingresar nuevo valor
              data <= {i_rx, data[NB_DATA-1:1]};  // agregamos el bit al MSB y corremos los demas

              // aumentar contador de datos
              data_count <= data_count + 1;
            end else begin
              // se tomaron todos los bits de datos, chequear bit de stop
              if (i_rx == 1) begin
                // llego bit the stop
                rx_done <= 1;
                state   <= IDLE_STATE;
              end else begin
                // reiniciar para volver a recibir nueva trama
                state <= IDLE_STATE;
              end
            end
          end
        end

        default: state <= IDLE_STATE;
      endcase

    end
  end

  assign o_rx_data = data;
  assign o_rx_done = rx_done;

endmodule
