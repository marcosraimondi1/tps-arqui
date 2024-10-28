`timescale 1ns / 1ps

module instruction_execute_tb;

  // valores a usar
  localparam RS = 5'd5;
  localparam RT = 5'd6;
  localparam RD = 5'd31;
  localparam INMEDIATO = 16'd4;
  localparam SHAMT = 5'd2;
  localparam JUMP_ADDR = 26'd10;

  // tipo R
  localparam ADD = {6'b000000, RS, RT, RD, 5'b00000, 6'b100000};
  localparam SUB = {6'b000000, RS, RT, RD, 5'b00000, 6'b100010};
  localparam SLL = {6'b000000, 5'b00000, RT, RD, SHAMT, 6'b000000};
  localparam SRL = {6'b000000, 5'b00000, RT, RD, SHAMT, 6'b000010};
  localparam SRA = {6'b000000, 5'b00000, RT, RD, SHAMT, 6'b000011};
  localparam SLLV = {6'b000000, RS, RT, RD, 5'b00000, 6'b000100};
  localparam SRLV = {6'b000000, RS, RT, RD, 5'b00000, 6'b000110};
  localparam SRAV = {6'b000000, RS, RT, RD, 5'b00000, 6'b000111};
  localparam ADDU = {6'b000000, RS, RT, RD, 5'b00000, 6'b100001};
  localparam SUBU = {6'b000000, RS, RT, RD, 5'b00000, 6'b100011};
  localparam AND = {6'b000000, RS, RT, RD, 5'b00000, 6'b100100};
  localparam OR = {6'b000000, RS, RT, RD, 5'b00000, 6'b100101};
  localparam XOR = {6'b000000, RS, RT, RD, 5'b00000, 6'b100110};
  localparam NOR = {6'b000000, RS, RT, RD, 5'b00000, 6'b100111};
  localparam SLT = {6'b000000, RS, RT, RD, 5'b00000, 6'b101010};
  // tipo I
  localparam LB = {6'b100000, RS, RT, INMEDIATO};
  localparam LH = {6'b100001, RS, RT, INMEDIATO};
  localparam LW = {6'b100011, RS, RT, INMEDIATO};
  localparam LWU = {6'b100111, RS, RT, INMEDIATO};
  localparam LBU = {6'b100100, RS, RT, INMEDIATO};
  localparam LHU = {6'b100101, RS, RT, INMEDIATO};
  localparam SB = {6'b101000, RS, RT, INMEDIATO};
  localparam SH = {6'b101001, RS, RT, INMEDIATO};
  localparam SW = {6'b101011, RS, RT, INMEDIATO};
  localparam ADDI = {6'b001000, RS, RT, INMEDIATO};
  localparam ANDI = {6'b001100, RS, RT, INMEDIATO};
  localparam ORI = {6'b001101, RS, RT, INMEDIATO};
  localparam XORI = {6'b001110, RS, RT, INMEDIATO};
  localparam LUI = {6'b001111, 5'b00000, RT, INMEDIATO};
  localparam SLTI = {6'b001010, RS, RT, INMEDIATO};
  // tipo J
  localparam J = {6'b000010, JUMP_ADDR};
  localparam JAL = {6'b000011, JUMP_ADDR};
  localparam JR = {6'b000000, RS, 15'b000000000000000, 6'b001000};
  localparam JALR = {6'b000000, RS, 5'b00000, RD, 5'b00000, 6'b001001};
  localparam HALT = 32'hffffffff;

  reg i_clk;
  reg i_reset;
  reg i_halt;
  reg [31:0] RA;
  reg [31:0] RB;
  reg [4:0] rs;
  reg [4:0] rt;
  reg [4:0] rd;
  reg [5:0] funct;
  reg [31:0] inmediato;
  reg [5:0] opcode;
  reg [4:0] shamt;
  reg WB_write__out_decode;
  reg WB_mem_to_reg__out_decode;
  reg MEM_read__out_decode;
  reg MEM_write__out_decode;
  reg [1:0] MEM_byte_half_word__out_decode;
  reg MEM_unsigned__out_decode;
  reg EX_alu_src__out_decode;
  reg EX_reg_dst__out_decode;
  reg [1:0] EX_alu_op__out_decode;
  reg [1:0] corto_rs;
  reg [1:0] corto_rt;
  reg [31:0] data_WB;

  // salidas
  wire WB_write__out_execute;
  wire WB_mem_to_reg__out_execute;
  wire MEM_read__out_execute;
  wire MEM_write__out_execute;
  wire MEM_unsigned__out_execute;
  wire [1:0] MEM_byte_half_word__out_execute;
  wire [4:0] write_reg__out_execute;
  wire [31:0] data_to_write_in_MEM;
  wire [31:0] ALU_result__out_execute;

  always #10 i_clk = ~i_clk;  // Reloj de 20ns -> 50MHz

  instruction_execute intstruction_execute1 (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_halt(i_halt),
      .i_RA(RA),
      .i_RB(RB),
      .i_rs(rs),
      .i_rt(rt),
      .i_rd(rd),
      .i_funct(funct),
      .i_inmediato(inmediato),
      .i_opcode(opcode),
      .i_shamt(shamt),
      .i_WB_write(WB_write__out_decode),
      .i_WB_mem_to_reg(WB_mem_to_reg__out_decode),
      .i_MEM_read(MEM_read__out_decode),
      .i_MEM_write(MEM_write__out_decode),
      .i_MEM_unsigned(MEM_write__out_decode),
      .i_MEM_byte_half_word(MEM_byte_half_word__out_decode),
      .i_EX_alu_src(EX_alu_src__out_decode),
      .i_EX_reg_dst(EX_reg_dst__out_decode),
      .i_EX_alu_op(EX_alu_op__out_decode),
      .i_corto_rs(corto_rs),  // RS -> alu data A
      .i_corto_rt(corto_rt),  // RT -> alu data B
      .i_input_ALU_MEM(ALU_result__out_execute),  // el resultado de la instruccion anterior
      .i_output_WB(data_WB),
      .o_WB_write(WB_write__out_execute),
      .o_WB_mem_to_reg(WB_mem_to_reg__out_execute),
      .o_MEM_read(MEM_read__out_execute),
      .o_MEM_write(MEM_write__out_execute),
      .o_MEM_unsigned(MEM_unsigned__out_execute),
      .o_MEM_byte_half_word(MEM_byte_half_word__out_execute),
      .o_write_reg(write_reg__out_execute),  // <-----------------------
      .o_data_to_write_in_MEM(data_to_write_in_MEM),  // <-----------------------
      .o_ALU_result(ALU_result__out_execute)  // <-----------------------
  );

  initial begin

    i_halt = 0;
    i_clk = 0;
    i_reset = 0;
    RA = 0;
    RB = 0;
    rs = 0;
    rt = 0;
    rd = 0;
    funct = 0;
    inmediato = 0;
    opcode = 0;
    shamt = 0;
    WB_write__out_decode = 0;
    WB_mem_to_reg__out_decode = 0;
    MEM_read__out_decode = 0;
    MEM_write__out_decode = 0;
    MEM_byte_half_word__out_decode = 0;
    MEM_unsigned__out_decode = 0;
    EX_alu_src__out_decode = 0;
    EX_reg_dst__out_decode = 0;
    EX_alu_op__out_decode = 0;
    corto_rs = 0;
    corto_rt = 0;
    data_WB = 0;

    #20;
    i_reset = 1;
    #20;
    i_reset = 0;

    // operacion tipo R - sin corto
    $display("Test ADD sin corto");
    rt = RT;
    rd = RD;
    RA = 32'd0 + RS;
    RB = 32'd0 + RT;
    opcode = ADD[31:26];
    funct = ADD[5:0];
    corto_rs = 2'b00;
    corto_rt = 2'b00;
    EX_alu_src__out_decode = 0;  // uso RB no inmediato
    EX_alu_op__out_decode = 2'b10;  // tipo R
    EX_reg_dst__out_decode = 1;  // uso rd no rt

    #20;
    if (ALU_result__out_execute !== RA + RB)
      $fatal("Error: ALU_result__out_execute %d", ALU_result__out_execute);
    if (write_reg__out_execute !== RD)
      $fatal("Error: write_reg__out_execute %d", write_reg__out_execute);
    if (data_to_write_in_MEM !== RB) $fatal("Error: data_to_write_in_MEM %d", data_to_write_in_MEM);

    // operacion tipo R - con corto
    $display("Test ADD con corto");
    opcode = ADD[31:26];
    funct = ADD[5:0];
    corto_rs = 2'b01;  // corto en RS con WB
    corto_rt = 2'b10;  // corto en RT con salida de ALU
    EX_alu_src__out_decode = 0;  // uso RB no inmediato
    EX_alu_op__out_decode = 2'b10;  // tipo R
    EX_reg_dst__out_decode = 1;  // uso rd no rt
    data_WB = 32'd15;

    #20;
    if (ALU_result__out_execute !== (RA + RB) + 15)  // la salida anterior + (15)WB
      $fatal("Error: ALU_result__out_execute %d", ALU_result__out_execute);
    if (write_reg__out_execute !== RD)
      $fatal("Error: write_reg__out_execute %d", write_reg__out_execute);
    if (data_to_write_in_MEM !== (RA + RB))
      $fatal("Error: data_to_write_in_MEM %d", data_to_write_in_MEM);

    // operacion tipo R - con corto
    $display("Test AND con corto");
    opcode = AND[31:26];
    funct = AND[5:0];
    corto_rs = 2'b10;  // corto en RS con salida de ALU
    corto_rt = 2'b01;  // corto en RT con salida de WB
    EX_alu_src__out_decode = 0;  // uso RB no inmediato
    EX_alu_op__out_decode = 2'b10;  // tipo R
    EX_reg_dst__out_decode = 1;  // uso rd no rt
    data_WB = 32'd21;

    #20;
    if (ALU_result__out_execute !== (((RA + RB) + 15) & data_WB))
      $fatal("Error: ALU_result__out_execute %d", ALU_result__out_execute);
    if (write_reg__out_execute !== RD)
      $fatal("Error: write_reg__out_execute %d", write_reg__out_execute);
    if (data_to_write_in_MEM !== data_WB)
      $fatal("Error: data_to_write_in_MEM %d", data_to_write_in_MEM);

    // opracion tipo I
    $display("Test LUI sin corto");
    rt = RT;
    rd = RD;
    RA = 32'd0 + RS;
    RB = 32'd0 + RT;
    opcode = LUI[31:26];
    funct = LUI[5:0];
    inmediato = 32'd0 + LUI[15:0];
    corto_rs = 2'b00;
    corto_rt = 2'b00;
    EX_alu_src__out_decode = 1;  // uso inmediato no RB
    EX_alu_op__out_decode = 2'b11;  // tipo I
    EX_reg_dst__out_decode = 0;  // uso rt no rd

    #20;
    if (ALU_result__out_execute !== (INMEDIATO << 16))
      $fatal("Error: ALU_result__out_execute %d", ALU_result__out_execute);
    if (write_reg__out_execute !== RT)
      $fatal("Error: write_reg__out_execute %d", write_reg__out_execute);
    if (data_to_write_in_MEM !== RB) $fatal("Error: data_to_write_in_MEM %d", data_to_write_in_MEM);

    // opracion tipo J (JALR - JAL)
    $display("Test JALR");
    rt = RT;
    rd = RD - 1;
    RA = 32'd4;
    RB = 32'd4;
    opcode = JALR[31:26];
    funct = JALR[5:0];
    inmediato = 32'd0 + JALR[15:0];
    corto_rs = 2'b00;
    corto_rt = 2'b00;
    EX_alu_src__out_decode = 0;  // uso RB no inmediato
    EX_alu_op__out_decode = 2'b00;  // para que haga suma
    EX_reg_dst__out_decode = 1;  // uso rd no rt

    #20;
    if (ALU_result__out_execute !== RA + 4)
      $fatal("Error: ALU_result__out_execute %d", ALU_result__out_execute);
    if (write_reg__out_execute !== RD - 1)
      $fatal("Error: write_reg__out_execute %d", write_reg__out_execute);
    if (data_to_write_in_MEM !== RB) $fatal("Error: data_to_write_in_MEM %d", data_to_write_in_MEM);

    $display("Test JAL");
    rt = 5'b11111;
    rd = 5'd5;
    RA = 32'd8;
    RB = 32'd4;
    opcode = JAL[31:26];
    funct = JAL[5:0];
    inmediato = 32'd0 + JAL[15:0];
    corto_rs = 2'b00;
    corto_rt = 2'b00;
    EX_alu_src__out_decode = 0;  // uso RB no inmediato
    EX_alu_op__out_decode = 2'b00;  // para que haga suma
    EX_reg_dst__out_decode = 0;  // uso rt no rd

    #20;
    if (ALU_result__out_execute !== RA + 4)
      $fatal("Error: ALU_result__out_execute %d", ALU_result__out_execute);
    if (write_reg__out_execute !== 32'd31)
      $fatal("Error: write_reg__out_execute %d", write_reg__out_execute);
    if (data_to_write_in_MEM !== RB) $fatal("Error: data_to_write_in_MEM %d", data_to_write_in_MEM);

    // test halt
    $display("Test ADD sin corto 2");
    rt = RT;
    rd = RD;
    RA = 32'd0 + RS;
    RB = 32'd0 + RT;
    opcode = ADD[31:26];
    funct = ADD[5:0];
    corto_rs = 2'b00;
    corto_rt = 2'b00;
    EX_alu_src__out_decode = 0;  // uso RB no inmediato
    EX_alu_op__out_decode = 2'b10;  // tipo R
    EX_reg_dst__out_decode = 1;  // uso rd no rt

    #20;
    if (ALU_result__out_execute !== RA + RB)
      $fatal("Error: ALU_result__out_execute %d", ALU_result__out_execute);
    if (write_reg__out_execute !== RD)
      $fatal("Error: write_reg__out_execute %d", write_reg__out_execute);
    if (data_to_write_in_MEM !== RB) $fatal("Error: data_to_write_in_MEM %d", data_to_write_in_MEM);

    $display("Test HALT");
    i_halt = 1;
    rt = 5'b11111;
    rd = 5'd5;
    RA = 32'd8;
    RB = 32'd4;
    opcode = JAL[31:26];
    funct = JAL[5:0];
    inmediato = 32'd0 + JAL[15:0];
    corto_rs = 2'b00;
    corto_rt = 2'b00;
    EX_alu_src__out_decode = 0;  // uso RB no inmediato
    EX_alu_op__out_decode = 2'b00;  // para que haga suma
    EX_reg_dst__out_decode = 0;  // uso rt no rd

    #40;
    if (ALU_result__out_execute !== RS + RT + 32'd0)
      $fatal("Error: ALU_result__out_execute %d", ALU_result__out_execute);
    if (write_reg__out_execute !== RD)
      $fatal("Error: write_reg__out_execute %d", write_reg__out_execute);
    if (data_to_write_in_MEM !== 32'd0 + RT)
      $fatal("Error: data_to_write_in_MEM %d", data_to_write_in_MEM);

    $display("Passed Instruction Execute Test Bench");
    $finish;
  end
endmodule

