module uart_interface #(
    parameter NB_DATA   = 8,
    parameter NB_IF_ID  = 64,
    parameter NB_ID_EX  = 168,
    parameter NB_EX_MEM = 88,
    parameter NB_MEM_WB = 80
) (
    input wire i_clk,
    input wire i_reset,
    // uart
    input wire i_rx_done,
    input wire i_tx_done,
    input wire [NB_DATA-1:0] i_rx_data,

    output wire [NB_DATA-1:0] o_tx_data,
    output wire o_tx_start,

    // pipeline
    input wire [31:0] i_r_data_registers,
    input wire [31:0] i_r_data_data_mem,
    input wire [NB_IF_ID-1:0] i_IF_ID,
    input wire [NB_ID_EX-1:0] i_ID_EX,
    input wire [NB_EX_MEM-1:0] i_EX_MEM,
    input wire [NB_MEM_WB-1:0] i_MEM_WB,
    input wire i_end,

    output wire o_reset_pipeline,
    output wire o_stop,
    output wire o_write_instruction_mem,  // flag para escribir memoria de instrucciones
    output wire [31:0] o_instruction_mem_addr,  // direccion de memoria de instrucciones
    output wire [31:0] o_instruction_mem_data,  // dato a escribir en memoria de instrucciones
    output wire [4:0] o_r_addr_registers,
    output wire [31:0] o_r_addr_data_mem
);

  // states
  localparam IDLE_STATE = 3'b000;
  localparam WAIT_INSTR_STATE = 3'b001;
  localparam CONT_MODE_STATE = 3'b010;
  localparam DEBUG_MODE_STATE = 3'b011;
  localparam SEND_DATA_MEM_STATE = 3'b100;
  localparam SEND_DATA_REGS_STATE = 3'b101;
  localparam SEND_DATA_LATCHES_STATE = 3'b110;

  // UART commands/opcodes
  localparam LOAD_INSTR_OP = 8'b00000000;
  localparam START_CONT_OP = 8'b00000001;
  localparam START_DEBUG_OP = 8'b00000010;
  localparam STEP_OP = 8'b00000011;
  localparam END_DEBUG_OP = 8'b00000100;

  // Halt instruction
  localparam HALT_INSTR = 32'hffffffff;

  // para memoria de datos
  localparam NB_MEM_ADDR = 8;
  localparam MAX_DATOS = 2 ** NB_MEM_ADDR / 4;  // 4 bytes por dato
  reg [MAX_DATOS-1:0] used_mem;  // 1 bit per mem addr

  reg tx_sending;
  reg [2:0] state, next_state;
  // variables
  reg write_instruction_mem;  // revisar
  reg debug_mode, next_debug_mode;  // 0: cont, 1: debug
  reg [NB_DATA-1:0] tx_data, next_tx_data;
  reg tx_start, next_tx_start;
  reg reset_pipeline, next_reset_pipeline;
  reg stop, next_stop;
  reg [31:0] instruction_mem_addr, next_instruction_mem_addr;
  reg [31:0] instruction_mem_data, next_instruction_mem_data;
  reg [4:0] r_addr_registers, next_r_addr_registers;
  reg [31:0] r_addr_data_mem, next_r_addr_data_mem;
  reg [1:0] sending_latches, next_sending_latches;  // 0: IF_ID, 1: ID_EX, 2: EX_MEM, 3: MEM_WB
  reg [31:0] counter, next_counter;

  // EX_MEM latches
  wire MEM_write_EX_MEM;  // si se escribio en memoria
  wire [31:0] ALU_result_EX_MEM;  // direccion que se escribio


  always @(posedge i_clk) begin : actualizacion_de_registros
    if (i_reset) begin
      state <= IDLE_STATE;
      tx_data <= 0;
      tx_start <= 0;

      reset_pipeline <= 1;
      stop <= 1;
      instruction_mem_addr <= 0;
      instruction_mem_data <= 0;
      r_addr_registers <= 0;
      r_addr_data_mem <= 0;
      counter <= 0;
      debug_mode <= 0;
      tx_sending <= 0;
      sending_latches <= 0;
    end else begin
      state <= next_state;
      tx_data <= next_tx_data;
      tx_start <= next_tx_start;

      stop <= next_stop;
      reset_pipeline <= next_reset_pipeline;
      instruction_mem_addr <= next_instruction_mem_addr;
      instruction_mem_data <= next_instruction_mem_data;
      r_addr_registers <= next_r_addr_registers;
      r_addr_data_mem <= next_r_addr_data_mem;
      counter <= next_counter;
      debug_mode <= next_debug_mode;
      sending_latches <= next_sending_latches;

      if (next_tx_start) begin
        tx_sending <= 1;
      end else if (i_tx_done) begin
        tx_sending <= 0;
      end
    end
  end

  always @(*) begin : next_state_logic
    next_state = state;

    case (state)
      IDLE_STATE: begin
        // wait for command
        if (i_rx_done) begin
          // check opcode
          case (i_rx_data)
            LOAD_INSTR_OP:  next_state = WAIT_INSTR_STATE;
            START_CONT_OP:  next_state = CONT_MODE_STATE;
            START_DEBUG_OP: next_state = DEBUG_MODE_STATE;

            // unknown or not valid command in this state
            default: next_state = IDLE_STATE;
          endcase
        end
      end

      WAIT_INSTR_STATE: begin
        // wait for halt instruction
        if (counter == 4 && instruction_mem_data == HALT_INSTR) begin
          next_state = IDLE_STATE;
        end
      end

      CONT_MODE_STATE: begin
        if (i_end) begin
          next_state = SEND_DATA_REGS_STATE;
        end
      end

      DEBUG_MODE_STATE: begin
        // wait for command
        if (i_rx_done) begin
          // check opcode
          case (i_rx_data)
            STEP_OP: next_state = SEND_DATA_REGS_STATE;
            END_DEBUG_OP: next_state = IDLE_STATE;
            default: next_state = DEBUG_MODE_STATE;
          endcase
        end
      end

      SEND_DATA_MEM_STATE: begin
        if (!tx_sending && counter == (MAX_DATOS * 4 + MAX_DATOS / 8)) begin
          if (debug_mode) begin
            next_state = DEBUG_MODE_STATE;  // finished step
          end else begin
            next_state = IDLE_STATE;  // finished program
          end
        end
      end

      SEND_DATA_REGS_STATE: begin
        if (!tx_sending && counter == (32 * 4)) begin
          next_state = SEND_DATA_LATCHES_STATE;
        end
      end

      SEND_DATA_LATCHES_STATE: begin
        if (!tx_sending && sending_latches == 2'b11 && counter == (NB_MEM_WB / 8)) begin
          // se envio el ultimo latch intermedio, finalizar envio de datos
          next_state = SEND_DATA_MEM_STATE;
        end
      end

      default: next_state = IDLE_STATE;
    endcase
  end

  always @(*) begin : output_logic
    // vuelven a cero (se ponen en 1 solo 1 ciclo)
    next_tx_start = 1'b0;
    write_instruction_mem = 0;
    // guardan el valor actual
    next_tx_data = tx_data;
    next_reset_pipeline = reset_pipeline;
    next_stop = stop;
    next_instruction_mem_addr = instruction_mem_addr;
    next_instruction_mem_data = instruction_mem_data;
    next_r_addr_registers = r_addr_registers;
    next_r_addr_data_mem = r_addr_data_mem;
    next_counter = counter;
    next_debug_mode = debug_mode;
    next_sending_latches = sending_latches;

    case (state)
      IDLE_STATE: begin
        // keep pipeline stopped
        next_reset_pipeline = 1;
        next_stop = 1;
        next_counter = 0;
        next_debug_mode = 0;
        next_sending_latches = 0;
        next_instruction_mem_addr = 0;
        next_r_addr_data_mem = 0;
        next_r_addr_registers = 0;

        if (i_rx_done) begin
          // echo back received command
          next_tx_start = 1;
          if (i_rx_data == 8'hff) begin
            next_tx_data = 8'h1d;
          end else begin
            next_tx_data = i_rx_data;
          end
        end
      end

      WAIT_INSTR_STATE: begin
        next_reset_pipeline = 0;
        next_stop = 1;
        if (i_rx_done) begin
          // recibe primero el byte MSB
          next_instruction_mem_data = {instruction_mem_data[23:0], i_rx_data};
          next_counter = counter + 1;

          next_tx_start = 1;
          next_tx_data = i_rx_data;
        end

        if (counter == 4) begin
          // write instruction to mem
          next_counter = 0;
          next_instruction_mem_addr = instruction_mem_addr + 4;
          write_instruction_mem = 1;  // se habilita escritura en este ciclo
        end

      end

      DEBUG_MODE_STATE: begin
        next_reset_pipeline = 0;
        next_debug_mode = 1;
        next_stop = 1;

        if (i_rx_done) begin
          if (i_rx_data == STEP_OP) begin
            // enable pipeline for one clock
            next_stop = 0;
          end

          // echo back received command
          next_tx_start = 1;
          if (i_rx_data == 8'hff) begin
            next_tx_data = 8'hde;
          end else begin
            next_tx_data = i_rx_data;
          end
        end
      end

      CONT_MODE_STATE: begin
        next_reset_pipeline = 0;
        next_stop = 0;
        next_debug_mode = 0;
        if (i_rx_done) begin
          // echo back received command
          next_tx_start = 1;
          if (i_rx_data == 8'hff) begin
            next_tx_data = 8'hc0;
          end else begin
            next_tx_data = i_rx_data;
          end
        end
      end

      SEND_DATA_MEM_STATE: begin
        next_stop = 1;
        if (!tx_sending) begin  // esperar que se termine de mandar lo que se estaba mandando
          if (counter == (MAX_DATOS * 4 + MAX_DATOS / 8)) begin
            // se pasaron por todas las posiciones de memoria
            next_counter = 0;
            next_r_addr_data_mem = 0;
          end else begin
            if (counter < (MAX_DATOS * 4)) begin
              if (used_mem[r_addr_data_mem[NB_MEM_ADDR:2]]) begin
                // enviar dato, primero el MSByte
                next_tx_start = 1;
                next_tx_data  = i_r_data_data_mem[(31-counter[1:0]*8)-:8];
                next_counter  = counter + 1;  // contador de bytes

                if (counter[1:0] == 2'b11) begin
                  // se enviaron todos los bytes de esta palabra, avanzar a la siguiente direccion
                  next_r_addr_data_mem = r_addr_data_mem + 4;
                end

              end else begin
                // posicion no usada, no enviar
                next_counter = counter + 4;
                next_r_addr_data_mem = r_addr_data_mem + 4;
              end
            end else begin
              // send used_mem data
              next_tx_start = 1;
              next_tx_data  = used_mem[(counter-MAX_DATOS*4)*8+:8];
              next_counter  = counter + 1;  // contador de bytes
            end
          end
        end
      end

      SEND_DATA_REGS_STATE: begin
        next_stop = 1;
        if (!tx_sending) begin
          if (counter == (32 * 4)) begin
            // se enviaron todos los registros
            next_counter = 0;
            next_r_addr_registers = 0;
          end else begin
            // enviar dato, primero el MSByte
            next_tx_start = 1;
            next_tx_data  = i_r_data_registers[(31-counter[1:0]*8)-:8];  // [31-:8] = [31:24]
            next_counter  = counter + 1;  // contador de bytes

            if (counter[1:0] == 2'b11) begin
              // se enviaron todos los bytes de esta palabra, avanzar a la siguiente direccion
              next_r_addr_registers = r_addr_registers + 1;
            end
          end
        end
      end

      SEND_DATA_LATCHES_STATE: begin
        next_stop = 1;
        if (!tx_sending) begin
          next_counter = counter + 1;

          case (sending_latches)  // que latch enviar
            2'b00: begin
              if (counter == (NB_IF_ID / 8)) begin
                next_counter = 0;
                next_sending_latches = 2'b01;
              end else begin
                next_tx_start = 1;
                next_tx_data  = i_IF_ID[(NB_IF_ID-1-counter*8)-:8];
                // instruction[31:24] (primer byte)
                // instruction[23:16] (segundo byte)
                // instruction[15:8] (tercer byte)
                // instruction[7:0] (cuarto byte)
                // pc4[31:24] (quinto byte)
                // pc4[23:16] (sexto byte)
                // pc4[15:8] (septimo byte)
                // pc4[7:0] (octavo byte)
              end
            end

            2'b01: begin
              if (counter == (NB_ID_EX / 8)) begin
                next_counter = 0;
                next_sending_latches = 2'b10;
              end else begin
                next_tx_start = 1;
                next_tx_data  = i_ID_EX[(NB_ID_EX-1-counter*8)-:8];
              end
            end

            2'b10: begin
              if (counter == (NB_EX_MEM / 8)) begin
                next_counter = 0;
                next_sending_latches = 2'b11;
              end else begin
                next_tx_start = 1;
                next_tx_data  = i_EX_MEM[(NB_EX_MEM-1-counter*8)-:8];
              end
            end

            2'b11: begin
              if (counter == (NB_MEM_WB / 8)) begin
                next_counter = 0;
                next_sending_latches = 2'b00;
              end else begin
                next_tx_start = 1;
                next_tx_data  = i_MEM_WB[(NB_MEM_WB-1-counter*8)-:8];
              end
            end

            default: begin
              next_tx_start = 1;
              next_tx_data  = 0;
            end

          endcase
        end
      end

      default: begin
        next_tx_start = 1'b0;
        next_tx_data = 0;
        next_reset_pipeline = 1;
        next_stop = 1;
        write_instruction_mem = 0;
        next_instruction_mem_addr = 0;
        next_instruction_mem_data = 0;
        next_r_addr_registers = 0;
        next_r_addr_data_mem = 0;
        next_counter = 0;
        next_debug_mode = 0;
        next_sending_latches = 0;
      end
    endcase
  end


  always @(posedge i_clk) begin : used_mem_logic
    if (i_reset || o_reset_pipeline) begin
      used_mem <= {MAX_DATOS{1'b0}};
    end else begin
      // check if mem is written
      if (MEM_write_EX_MEM) begin
        used_mem[ALU_result_EX_MEM[NB_MEM_ADDR:2]] <= 1'b1;  // :2 porque la memoria va de a 4 bytes
      end
    end

  end

  assign o_tx_data = tx_data;
  assign o_tx_start = tx_start;

  assign o_reset_pipeline = reset_pipeline;
  assign o_stop = stop;
  assign o_write_instruction_mem = write_instruction_mem;
  assign o_instruction_mem_addr = instruction_mem_addr;
  assign o_instruction_mem_data = instruction_mem_data;
  assign o_r_addr_registers = r_addr_registers;
  assign o_r_addr_data_mem = r_addr_data_mem;

  wire [4:0] write_reg_EX_MEM;
  wire [31:0] data_to_write_in_MEM;
  wire WB_write_EX_MEM;
  wire WB_mem_to_reg_EX_MEM;
  wire MEM_read_EX_MEM;
  wire MEM_unsigned_EX_MEM;
  wire [1:0] MEM_byte_half_word_EX_MEM;
  assign {
      write_reg_EX_MEM,
      data_to_write_in_MEM,
      ALU_result_EX_MEM,
      WB_write_EX_MEM,
      WB_mem_to_reg_EX_MEM,
      MEM_read_EX_MEM,
      MEM_write_EX_MEM,
      MEM_unsigned_EX_MEM,
      MEM_byte_half_word_EX_MEM
      } = i_EX_MEM;
endmodule
