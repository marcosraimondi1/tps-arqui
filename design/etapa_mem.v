module etapa_mem (
    input wire i_clk,
    input wire i_reset,

    input wire [4:0] i_write_reg,  // registro de destino donde se escriben los resultados en WB
    input wire [31:0] i_data_to_write_in_MEM,  // data a escribir en memoria
    input wire [31:0] i_ALU_result,

    // senales de control (input)
    input wire i_WB_write,  // si 1 la instruccion escribe en el banco de registros
    input wire i_WB_mem_to_reg,  // si 0 guardo el valor de MEM (load) sino el valor de ALU (tipo R)
    input wire i_MEM_read,  // si 1 leo la memoria de datos (LOAD)
    input wire i_MEM_write,  // si 1 escribo en la memoria de datos (STORE)

    // senales de control (output)
    output reg o_WB_write,  // si 1 la instruccion escribe en el banco de registros
    output reg o_WB_mem_to_reg,  // si 0 guardo el valor de MEM (load) sino el valor de ALU (tipo R)

    // salidas de la etapa
    output reg [31:0] o_ALU_result,  // resultado de la ALU
    output reg [31:0] o_read_data,   // data leida de memoria
    output reg [ 4:0] o_write_reg    // registro de destino donde se escriben los resultados en WB
);

  wire [31:0] read_data_wire;

  always @(posedge i_clk) begin : outputs
    if (i_reset) begin
      o_ALU_result <= 0;
      o_read_data  <= 0;
      o_write_reg  <= 0;
    end else begin
      o_read_data  <= read_data_wire;
      o_ALU_result <= i_ALU_result;
      o_write_reg  <= i_write_reg;
    end
  end

  always @(posedge i_clk) begin : senales_de_control
    if (i_reset) begin
      o_WB_write <= 0;
      o_WB_mem_to_reg <= 0;
    end else begin
      o_WB_write <= i_WB_write;
      o_WB_mem_to_reg <= i_WB_mem_to_reg;
    end
  end

  xilinx_one_port_ram_async #(
      .ADDR_WIDTH(12),  // 4K direcciones
      .DATA_WIDTH(8)    // 8 bit data en ram
  ) mem (
      .i_clk(i_clk),
      .i_write_enable(i_MEM_write),
      .i_addr(i_ALU_result[11:0]),
      .i_data(i_data_to_write_in_MEM),
      .o_data(read_data_wire)
  );

endmodule
