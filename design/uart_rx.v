module uart_rx #(
    NB_DATA = 8
) (
    input wire i_reset,
    input wire i_tick,
    input wire i_rx,
    output wire [NB_DATA-1:0] o_rx_data,
    output wire o_rx_done
);

  reg [3:0] tick_count;
  reg [clogb2(NB_DATA - 1)-1:0] data_count;
  reg [NB_DATA-1:0] data;
  reg start;
  reg is_start_bit;
  reg rx_done;

  always @(posedge i_tick) begin
    if (i_reset) begin
      start <= 0;
      is_start_bit <= 0;
    end else begin
      if (start == 0 && i_rx == 0) begin
        // llego bit the start
        start <= 1;
        is_start_bit <= 1;
        rx_done <= 0;
      end
    end
  end

  always @(posedge i_tick) begin
    if (i_reset) begin
      tick_count <= 4'b0;
      data <= {NB_DATA{1'b0}};
      data_count <= 0;
      rx_done <= 0;
    end else if (start) begin
      if (is_start_bit == 1 && tick_count == 7) begin
        // llego bit the start
        tick_count   <= 4'b0;
        is_start_bit <= 0;
      end else if (tick_count == 15 && data_count < NB_DATA) begin
        // llego el siguiente bit de datos
        tick_count <= 4'b0;

        // ingresar nuevo valor
        data <= {i_rx, data[NB_DATA-1:1]};  // agregamos el bit al MSB y corremos los demas

        // aumentar contador de datos
        data_count <= data_count + 1;

      end else if (tick_count == 15) begin
        // reiniciar para volver a recibir nueva trama
        start <= 0;
        tick_count <= 4'b0;

        if (i_rx == 1) begin
          // llego bit the stop
          rx_done <= 1;
        end

      end
      begin
        tick_count <= tick_count + 1;
      end
    end
  end

  assign o_rx_data = data;
  assign o_rx_done = rx_done;  // va a estar en 1 muchos ciclos (hay que ver el ciclo cuando cambia
                               // de 0 a 1)


  function integer clogb2;
    input integer value;
    for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
      // divide por dos
      value = value >> 1;
    end
  endfunction

endmodule
