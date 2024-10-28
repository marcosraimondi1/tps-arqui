module etapa_mem (
    input wire i_clk,
    input wire i_reset,
    input wire i_halt,

    input wire [4:0] i_write_reg,  // registro de destino donde se escriben los resultados en WB
    input wire [31:0] i_data_to_write_in_MEM,  // data a escribir en memoria
    input wire [31:0] i_ALU_result,

    // senales de control (input)
    input wire i_WB_write,  // si 1 la instruccion escribe en el banco de registros
    input wire i_WB_mem_to_reg,  // si 0 guardo el valor de MEM (load) sino el valor de ALU (tipo R)
    input wire i_MEM_read,  // si 1 leo la memoria de datos (LOAD)
    input wire i_MEM_write,  // si 1 escribo en la memoria de datos (STORE)
    input wire i_MEM_unsigned,  // 1 unsigned 0 signed
    input wire [1:0] i_MEM_byte_half_word,  // 00 byte, 01 half word, 11 word

    // senales de control (output)
    output reg o_WB_write,  // si 1 la instruccion escribe en el banco de registros
    output reg o_WB_mem_to_reg,  // si 0 guardo el valor de MEM (load) sino el valor de ALU (tipo R)

    // salidas de la etapa
    output reg [31:0] o_ALU_result,  // resultado de la ALU
    output reg [31:0] o_read_data,   // data leida de memoria
    output reg [ 4:0] o_write_reg,   // registro de destino donde se escriben los resultados en WB

    // debug unit
    input  wire [31:0] i_r_addr,
    output wire [31:0] o_r_data
);

  wire [31:0] read_data_wire;
  reg  [31:0] data_to_MEM;

  localparam BYTE = 2'b00;
  localparam HALF_WORD = 2'b01;
  localparam WORD = 2'b11;

  always @(posedge i_clk) begin : outputs
    if (i_reset) begin
      o_ALU_result <= 0;
      o_read_data  <= 0;
      o_write_reg  <= 0;
    end else begin
      if (!i_halt) begin
        o_ALU_result <= i_ALU_result;
        o_write_reg  <= i_write_reg;

        case (i_MEM_byte_half_word)
          BYTE: begin
            if (i_MEM_unsigned) begin
              o_read_data <= {24'h000000, read_data_wire[7:0]};
            end else begin
              o_read_data <= {{24{read_data_wire[7]}}, read_data_wire[7:0]};  // extension de signo
            end
          end
          HALF_WORD: begin
            if (i_MEM_unsigned) begin
              o_read_data <= {16'h0000, read_data_wire[15:0]};
            end else begin
              o_read_data <= {
                {16{read_data_wire[15]}}, read_data_wire[15:0]
              };  // extension de signo
            end
          end
          WORD: o_read_data <= read_data_wire[31:0];
          default: o_read_data <= read_data_wire[31:0];
        endcase
      end
    end
  end

  always @(posedge i_clk) begin : senales_de_control
    if (i_reset) begin
      o_WB_write <= 0;
      o_WB_mem_to_reg <= 0;
    end else begin
      if (!i_halt) begin
        o_WB_write <= i_WB_write;
        o_WB_mem_to_reg <= i_WB_mem_to_reg;
      end
    end
  end

  wire [31:0] mem_addr;

  xilinx_one_port_ram_async #(
      .ADDR_WIDTH(12),  // 4K direcciones
      .DATA_WIDTH(8)    // 8 bit data en ram
  ) mem (
      .i_clk(i_clk),
      .i_write_enable(i_MEM_write),
      .i_addr(mem_addr),
      .i_data(data_to_MEM),
      .o_data(read_data_wire)
  );


  always @(*) begin : data_to_mem_mask
    case (i_MEM_byte_half_word)
      BYTE: begin
        if (i_MEM_unsigned) begin
          data_to_MEM = {24'h000000, i_data_to_write_in_MEM[7:0]};
        end else begin
          data_to_MEM = {{24{i_data_to_write_in_MEM[7]}}, i_data_to_write_in_MEM[7:0]};
        end
      end
      HALF_WORD: begin
        if (i_MEM_unsigned) begin
          data_to_MEM = {16'h0000, i_data_to_write_in_MEM[15:0]};
        end else begin
          data_to_MEM = {{16{i_data_to_write_in_MEM[15]}}, i_data_to_write_in_MEM[15:0]};
        end
      end
      WORD: data_to_MEM = i_data_to_write_in_MEM[31:0];
      default: data_to_MEM = i_data_to_write_in_MEM[31:0];
    endcase
  end


  assign mem_addr = i_halt ? i_r_addr : i_ALU_result[11:0];
  assign o_r_data = read_data_wire;

endmodule
