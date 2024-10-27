`timescale 1ns / 1ps

module etapa_mem_tb;

  integer j;  // Contador de iteraciones

  //inputs
  reg clk;
  reg reset;
  reg [4:0] register;
  reg [31:0] data_to_write;
  reg [31:0] Alu_result;
  reg WB_write;
  reg WB_mem_to_reg;
  reg MEM_read;
  reg MEM_write;
  reg MEM_unsigned;
  reg [1:0] MEM_byte_half_word;

  //outputs
  wire out_WB_write;
  wire out_WB_mem_to_reg;
  wire [31:0] out_ALU_result;
  wire [31:0] out_read_data;
  wire [4:0] out_write_reg;

  etapa_mem #() etapa_mem_1 (
      .i_clk  (clk),
      .i_reset(reset),

      .i_write_reg(register),  // registro de destino donde se escriben los resultados en WB
      .i_data_to_write_in_MEM(data_to_write),  // data a escribir en memoria
      .i_ALU_result(Alu_result),

      // senales de control (input)
      .i_WB_write(WB_write),  // si 1 la instruccion escribe en el banco de registros
      .i_WB_mem_to_reg(WB_mem_to_reg),  // si 0 guardo el valor de MEM (load) sino el valor de ALU (
      .i_MEM_read(MEM_read),  // si 1 leo la memoria de datos (LOAD)
      .i_MEM_write(MEM_write),  // si 1 escribo en la memoria de datos (STORE)
      .i_MEM_unsigned(MEM_unsigned),  // 1 unsigned 0 signed
      .i_MEM_byte_half_word(MEM_byte_half_word),  // 00 byte, 01 half word, 11 word

      // senales de control (output)
      .o_WB_write(out_WB_write),  // si 1 la instruccion escribe en el banco de registros
      .o_WB_mem_to_reg(out_WB_mem_to_reg),  // si 0 guardo el valor de MEM (load) sino el valor de A

      // salidas de la etapa
      .o_ALU_result(out_ALU_result),  // resultado de la ALU
      .o_read_data (out_read_data),   // data leida de memoria
      .o_write_reg (out_write_reg)    // registro de destino donde se escriben los resultados en WB
  );

  always #10 clk = ~clk;  // Reloj de 20ns -> 50MHz

  reg [31:0] aux;

  // Testbench
  initial begin

    // Inicializar señales
    clk = 0;
    reset = 0;
    register = 5'd0;
    data_to_write = {32{1'b0}};
    Alu_result = {32{1'b0}};
    WB_write = 0;
    WB_mem_to_reg = 0;
    MEM_read = 0;
    MEM_write = 0;
    MEM_unsigned = 0;
    MEM_byte_half_word = 2'b11;
    aux = 0;

    //Aplico reseteo
    #20 reset = 1;
    #20 reset = 0;
    // ------------------------ Test con palabra completa ---------------------------- //
    // Caso 1: Escritura en memoria
    MEM_write = 1;
    MEM_read = 0;
    MEM_byte_half_word = 2'b11;  // Escritura de una palabra completa

    for (j = 0; j < 20; j = j + 1) begin
      #20;
      data_to_write = data_to_write + 1;  //  Sumo uno a la data
      Alu_result = Alu_result + 4;  // Dirección de escritura (paso a la siguiente posición)
    end

    #20;  // Esperar

    // Caso 2: Lectura de memoria
    Alu_result = {32{1'b0}};  // Empizo la l
    data_to_write = {32{1'b0}};
    MEM_write = 0;
    MEM_read = 1;
    MEM_byte_half_word = 2'b11;  // Escritura de una palabra completa
    for (j = 0; j < 20; j = j + 1) begin
      #20;
      Alu_result = Alu_result + 4;  // Dirección de escritura (paso a la siguiente posición)
      if ((j) != out_read_data) begin
        $fatal("Failed Test Bench, expected = %d, out_read_data = %d ARE NOT EQUALS.", j,
               out_read_data);
      end
    end

    #20;

    // ------------------------ Test con media palabra ---------------------------- //
    MEM_unsigned = 1;
    // Caso 1: Escritura en memoria
    Alu_result = {32{1'b0}};
    data_to_write = {32{1'b1}};
    MEM_write = 1;
    MEM_read = 0;
    MEM_byte_half_word = 2'b01;  // Escritura de una media palabra

    for (j = 0; j < 20; j = j + 1) begin
      #20;
      data_to_write = data_to_write - 1;  //  Sumo uno a la data
      Alu_result = Alu_result + 4;  // Dirección de escritura (paso a la siguiente posición)
    end

    #20;  // Esperar

    // Caso 2: Lectura de memoria
    Alu_result = {32{1'b0}};
    MEM_write = 0;
    MEM_read = 1;
    data_to_write = {32{1'b1}};
    MEM_byte_half_word = 2'b01;  // Escritura de una media palabra
    for (j = 0; j < 20; j = j + 1) begin
      #20;
      if (((32'h0000ffff) & (data_to_write - j)) != out_read_data) begin
        $fatal("Failed Test Bench, expected = %d, out_read_data = %d ARE NOT EQUALS.",
               ((32'h0000ffff) & (data_to_write - j)), out_read_data);
      end
      Alu_result = Alu_result + 4;  // Dirección de escritura (paso a la siguiente posición)

    end

    #20;

    // ------------------------ Test con un BYTE de palabra ---------------------------- //
    MEM_unsigned = 1;
    // Caso 1: Escritura en memoria
    Alu_result = {32{1'b0}};
    data_to_write = {32{1'b1}};
    MEM_write = 1;
    MEM_read = 0;
    MEM_byte_half_word = 2'b00;  // Escritura de un BYTE de palabra

    for (j = 0; j < 20; j = j + 1) begin
      #20;
      data_to_write = data_to_write - 1;  //  Sumo uno a la data
      Alu_result = Alu_result + 4;  // Dirección de escritura (paso a la siguiente posición)
    end

    #20;  // Esperar

    // Caso 2: Lectura de memoria
    Alu_result = {32{1'b0}};
    MEM_write = 0;
    MEM_read = 1;
    data_to_write = {32{1'b1}};
    MEM_byte_half_word = 2'b00;  // Escritura de un BYTE de palabra
    for (j = 0; j < 20; j = j + 1) begin
      #20;
      if (((32'h000000ff) & (data_to_write - j)) != out_read_data) begin
        $fatal("Failed Test Bench, expected = %d, out_read_data = %d ARE NOT EQUALS.",
               ((32'h0000ffff) & (data_to_write - j)), out_read_data);
      end
      Alu_result = Alu_result + 4;  // Dirección de escritura (paso a la siguiente posición)

    end

    #20;

    // ------------------------ Test con lectura signed y escritura unsigned ---------------------------- //
    $display("Test con lectura signed y escritura unsigned");
    // 1: Escritura en memoria
    MEM_unsigned = 1;
    Alu_result = {32{1'b0}};
    data_to_write = 32'h000000ff;  // byte negativo
    MEM_write = 1;
    MEM_read = 0;
    MEM_byte_half_word = 2'b11;  // Escritura de WORD

    for (j = 0; j < 20; j = j + 1) begin
      #20;
      data_to_write = data_to_write - 1;
      Alu_result = Alu_result + 4;  // Dirección de escritura (paso a la siguiente posición)
    end

    #20;  // Esperar
    MEM_unsigned = 0;

    // Caso 2: Lectura de memoria
    Alu_result = {32{1'b0}};
    MEM_write = 0;
    MEM_read = 1;
    MEM_byte_half_word = 2'b00;  // Lectura de un BYTE de palabra

    aux = 32'hffffffff;
    for (j = 0; j < 20; j = j + 1) begin
      #20;
      // se espera que se extienda el signo del dato a leer
      if ((aux - j) != out_read_data) begin
        $fatal("Failed Test Bench, expected = %d, out_read_data = %d ARE NOT EQUALS.", (aux - j),
               out_read_data);
      end
      Alu_result = Alu_result + 4;  // Dirección de escritura (paso a la siguiente posición)

    end

    #20;

    // ------------------------ Test con lectura unsigned y escritura signed ---------------------------- //
    $display("Test con lectura unsigned y escritura signed");
    // 1: Escritura en memoria
    MEM_unsigned = 0;
    Alu_result = {32{1'b0}};
    data_to_write = 32'h000000ff;  // byte negativo
    MEM_write = 1;
    MEM_read = 0;
    MEM_byte_half_word = 2'b00;  // Escritura de BYTE

    for (j = 0; j < 20; j = j + 1) begin
      #20;
      data_to_write = data_to_write - 1;
      Alu_result = Alu_result + 4;  // Dirección de escritura (paso a la siguiente posición)
    end

    #20;  // Esperar
    MEM_unsigned = 1;

    // Caso 2: Lectura de memoria
    Alu_result = {32{1'b0}};
    MEM_write = 0;
    MEM_read = 1;
    MEM_byte_half_word = 2'b11;  // Lectura de un WORD

    aux = 32'hffffffff;
    for (j = 0; j < 20; j = j + 1) begin
      #20;
      // se espera que se extienda el signo del dato cuando se escribio
      if ((aux - j) != out_read_data) begin
        $fatal("Failed Test Bench, expected = %d, out_read_data = %d ARE NOT EQUALS.", (aux - j),
               out_read_data);
      end
      Alu_result = Alu_result + 4;  // Dirección de escritura (paso a la siguiente posición)

    end

    #20;
    $display("Passed ETAPA_MEM Test Bench");

    $finish;
  end
endmodule
