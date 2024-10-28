module instruction_decode_tb ();

  // valores a usar
  localparam RS = 5'd5;
  localparam RT = 5'd6;
  localparam RD = 5'd31;
  localparam INMEDIATO = 16'd4;
  localparam JUMP_ADDR = 26'd10;
  localparam SHAMT = 5'd2;

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
  localparam BEQ = {6'b000100, RS, RT, INMEDIATO};
  localparam BNE = {6'b000101, RS, RT, INMEDIATO};
  localparam J = {6'b000010, JUMP_ADDR};
  localparam JAL = {6'b000011, JUMP_ADDR};
  // tipo J
  localparam JR = {6'b000000, RS, 15'b000000000000000, 6'b001000};
  localparam JALR = {6'b000000, RS, 5'b00000, RD, 5'b00000, 6'b001001};
  localparam HALT = 32'hffffffff;

  reg i_clk;
  reg i_reset;
  reg stall;
  reg [31:0] pc4;
  reg [31:0] instruction;

  // senales del writeback al decode
  reg write_enable_WB;
  reg [4:0] register_WB;
  reg [31:0] data_WB;

  // senales del decode para el execute
  wire [31:0] RA;
  wire [31:0] RB;
  wire [4:0] rs;
  wire [4:0] rt;
  wire [4:0] rd;
  wire [5:0] funct;
  wire [15:0] inmediato;
  wire [5:0] opcode;
  wire [4:0] shamt;
  wire [31:0] jump_addr;
  wire jump_flag;
  wire halt;
  // senales de control
  wire WB_write__out_decode;
  wire WB_mem_to_reg__out_decode;
  wire MEM_read__out_decode;
  wire MEM_write__out_decode;
  wire MEM_unsigned__out_decode;
  wire [1:0] MEM_byte_half_word__out_decode;
  wire EX_alu_src__out_decode;
  wire EX_reg_dst__out_decode;
  wire [1:0] EX_alu_op__out_decode;

  instruction_decode instruction_decode1 (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_pc4(pc4),
      .i_instruction(instruction),
      .i_write_enable_WB(write_enable_WB),
      .i_register_WB(register_WB),
      .i_data_WB(data_WB),
      .i_stall(stall),
      .o_RA(RA),  // senal de stall del detector de riesgos
      .o_RB(RB),
      .o_rs(rs),
      .o_rt(rt),
      .o_rd(rd),
      .o_funct(funct),
      .o_inmediato(inmediato),
      .o_opcode(opcode),
      .o_shamt(shamt),
      // senales de control
      .o_WB_write(WB_write__out_decode),
      .o_WB_mem_to_reg(WB_mem_to_reg__out_decode),
      .o_MEM_read(MEM_read__out_decode),
      .o_MEM_write(MEM_write__out_decode),
      .o_MEM_unsigned(MEM_unsigned__out_decode),
      .o_MEM_byte_half_word(MEM_byte_half_word__out_decode),
      .o_EX_alu_src(EX_alu_src__out_decode),
      .o_EX_reg_dst(EX_reg_dst__out_decode),
      .o_EX_alu_op(EX_alu_op__out_decode),

      // resultados de saltos y branches
      .o_jump_addr(jump_addr),
      .o_jump(jump_flag),
      .o_halt(halt)
  );

  always #10 i_clk = ~i_clk;

  initial begin
    i_clk = 0;
    i_reset = 1;
    stall = 0;
    pc4 = 32'h00000004;
    instruction = 0;
    write_enable_WB = 0;
    register_WB = 0;
    data_WB = 0;

    #20;
    i_reset = 0;

    // tipo R
    $display("ADD");
    instruction = ADD;
    #20;
    // check decodificacion
    if (RA !== RS) $fatal("RA = %d", RA);
    if (RB !== RT) $fatal("RB = %d", RB);
    if (rs !== RS) $fatal("rs = %d", rs);
    if (rt !== RT) $fatal("rt = %d", rt);
    if (rd !== RD) $fatal("rd = %d", rd);
    if (funct !== 6'b100000) $fatal("funct = %d", funct);
    if (opcode !== 6'b000000) $fatal("opcode = %d", opcode);
    if (jump_flag) $fatal("jump_flag = %d", jump_flag);
    // senales de control
    if (!WB_write__out_decode) $fatal("WB_write = %d", WB_write__out_decode);
    if (!WB_mem_to_reg__out_decode) $fatal("WB_mem_to_reg = %d", WB_mem_to_reg__out_decode);
    if (MEM_read__out_decode) $fatal("MEM_read = %d", MEM_read__out_decode);
    if (MEM_write__out_decode) $fatal("MEM_write = %d", MEM_write__out_decode);
    if (EX_alu_src__out_decode)
      $fatal("EX_alu_src = %d", EX_alu_src__out_decode);  // 1 -> inmediato
    if (!EX_reg_dst__out_decode) $fatal("EX_reg_dst = %d", EX_reg_dst__out_decode);  // 1 -> rd
    if (EX_alu_op__out_decode !== 2'b10)
      $fatal("EX_alu_op = %d", EX_alu_op__out_decode);  // 10 -> R


    // tipo I
    $display("XORI");
    instruction = XORI;
    i_reset = 1;
    #20;
    i_reset = 0;
    #20;
    // check decodificacion
    if (RA !== RS) $fatal("RA = %d", RA);
    if (rs !== RS) $fatal("rs = %d", rs);
    if (rt !== RT) $fatal("rt = %d", rt);
    if (inmediato !== INMEDIATO) $fatal("inmediato = %d", inmediato);
    if (opcode !== 6'b001110) $fatal("opcode = %d", opcode);
    if (jump_flag) $fatal("jump_flag = %d", jump_flag);
    // senales de control
    if (!WB_write__out_decode) $fatal("WB_write = %d", WB_write__out_decode);
    if (!WB_mem_to_reg__out_decode) $fatal("WB_mem_to_reg = %d", WB_mem_to_reg__out_decode);
    if (MEM_read__out_decode) $fatal("MEM_read = %d", MEM_read__out_decode);
    if (MEM_write__out_decode) $fatal("MEM_write = %d", MEM_write__out_decode);
    if (!EX_alu_src__out_decode)
      $fatal("EX_alu_src = %d", EX_alu_src__out_decode);  // 1 -> inmediato
    if (EX_reg_dst__out_decode) $fatal("EX_reg_dst = %d", EX_reg_dst__out_decode);  // 1 -> rd
    if (EX_alu_op__out_decode !== 2'b11)
      $fatal("EX_alu_op = %d", EX_alu_op__out_decode);  // 11 -> tipo I

    // tipo R con shamt
    $display("SLL");
    instruction = SLL;
    i_reset = 1;
    #20;
    i_reset = 0;
    #20;
    // check decodificacion
    if (RB !== RT) $fatal("RB = %d", RB);
    if (rt !== RT) $fatal("rt = %d", rt);
    if (rd !== RD) $fatal("rd = %d", rd);
    if (funct !== 6'b000000) $fatal("funct = %d", funct);
    if (opcode !== 6'b000000) $fatal("opcode = %d", opcode);
    if (jump_flag) $fatal("jump_flag = %d", jump_flag);
    if (shamt !== SHAMT) $fatal("shamt = %d", shamt);
    // senales de control
    if (!WB_write__out_decode) $fatal("WB_write = %d", WB_write__out_decode);
    if (!WB_mem_to_reg__out_decode) $fatal("WB_mem_to_reg = %d", WB_mem_to_reg__out_decode);
    if (MEM_read__out_decode) $fatal("MEM_read = %d", MEM_read__out_decode);
    if (MEM_write__out_decode) $fatal("MEM_write = %d", MEM_write__out_decode);
    if (EX_alu_src__out_decode)
      $fatal("EX_alu_src = %d", EX_alu_src__out_decode);  // 1 -> inmediato
    if (!EX_reg_dst__out_decode) $fatal("EX_reg_dst = %d", EX_reg_dst__out_decode);  // 1 -> rd
    if (EX_alu_op__out_decode !== 2'b10)
      $fatal("EX_alu_op = %d", EX_alu_op__out_decode);  // 10 -> R


    // tipo I - load halfword unsigned
    $display("LHU");
    instruction = LHU;
    i_reset = 1;
    #20;
    i_reset = 0;
    #20;
    if (RA !== RS) $fatal("RA = %d", RA);
    if (RB !== RT) $fatal("RB = %d", RB);
    if (rs !== RS) $fatal("rs = %d", rs);
    if (rt !== RT) $fatal("rt = %d", rt);
    if (opcode !== 6'b100101) $fatal("opcode = %d", opcode);
    if (jump_flag) $fatal("jump_flag = %d", jump_flag);
    if (inmediato !== INMEDIATO) $fatal("inmediato = %d", inmediato);
    // senales de control
    if (!WB_write__out_decode) $fatal("WB_write = %d", WB_write__out_decode);
    if (WB_mem_to_reg__out_decode) $fatal("WB_mem_to_reg = %d", WB_mem_to_reg__out_decode);
    if (!MEM_read__out_decode) $fatal("MEM_read = %d", MEM_read__out_decode);
    if (MEM_write__out_decode) $fatal("MEM_write = %d", MEM_write__out_decode);
    if (MEM_byte_half_word__out_decode !== 2'b01)
      $fatal("MEM_byte_half_word = %d", MEM_byte_half_word__out_decode);
    if (!MEM_unsigned__out_decode) $fatal("MEM_unsigned = %d", MEM_unsigned__out_decode);
    if (!EX_alu_src__out_decode)
      $fatal("EX_alu_src = %d", EX_alu_src__out_decode);  // 1 -> inmediato
    if (EX_reg_dst__out_decode) $fatal("EX_reg_dst = %d", EX_reg_dst__out_decode);  // 1 -> rd
    if (EX_alu_op__out_decode !== 2'b00)
      $fatal("EX_alu_op = %d", EX_alu_op__out_decode);  // 00 -> Load o Store


    // tipo I - store word
    $display("SW");
    instruction = SW;
    i_reset = 1;
    #20;
    i_reset = 0;
    #20;
    if (RA !== RS) $fatal("RA = %d", RA);
    if (RB !== RT) $fatal("RB = %d", RB);
    if (rs !== RS) $fatal("rs = %d", rs);
    if (rt !== RT) $fatal("rt = %d", rt);
    if (opcode !== 6'b101011) $fatal("opcode = %d", opcode);
    if (jump_flag) $fatal("jump_flag = %d", jump_flag);
    if (inmediato !== INMEDIATO) $fatal("inmediato = %d", inmediato);
    // senales de control
    if (WB_write__out_decode) $fatal("WB_write = %d", WB_write__out_decode);
    if (MEM_read__out_decode) $fatal("MEM_read = %d", MEM_read__out_decode);
    if (!MEM_write__out_decode) $fatal("MEM_write = %d", MEM_write__out_decode);
    if (MEM_byte_half_word__out_decode !== 2'b11)
      $fatal("MEM_byte_half_word = %d", MEM_byte_half_word__out_decode);
    if (MEM_unsigned__out_decode) $fatal("MEM_unsigned = %d", MEM_unsigned__out_decode);
    if (!EX_alu_src__out_decode)
      $fatal("EX_alu_src = %d", EX_alu_src__out_decode);  // 1 -> inmediato
    if (EX_reg_dst__out_decode) $fatal("EX_reg_dst = %d", EX_reg_dst__out_decode);  // 1 -> rd
    if (EX_alu_op__out_decode !== 2'b00)
      $fatal("EX_alu_op = %d", EX_alu_op__out_decode);  // 00 -> Load o Store

    // test stall
    $display("STALL");
    stall = 1;
    #20;
    if (WB_write__out_decode) $fatal("WB_write = %d", WB_write__out_decode);
    if (MEM_write__out_decode) $fatal("MEM_write = %d", MEM_write__out_decode);

    // test writing registers
    #20;
    instruction = ADD;
    stall = 0;
    #20;
    write_enable_WB = 1;
    register_WB = RS;
    data_WB = RS + 32'd1;
    if (RA !== RS) $fatal("RA = %d", RA);
    #20;
    if (RA !== RS + 32'd1) $fatal("RA = %d", RA);
    write_enable_WB = 0;

    // test jumps
    $display("J");
    instruction = J;
    #10;
    if (!jump_flag) $fatal("jump_flag = %d", jump_flag);
    if (jump_addr !== {pc4[31:28], JUMP_ADDR, 2'b00}) $fatal("jump_addr = %d", jump_addr);
    #10;
    // senales de control
    if (WB_write__out_decode) $fatal("WB_write = %d", WB_write__out_decode);
    if (MEM_write__out_decode) $fatal("MEM_write = %d", MEM_write__out_decode);

    $display("JR");
    instruction = JR;
    #10;
    if (!jump_flag) $fatal("jump_flag = %d", jump_flag);
    if (jump_addr !== RS + 32'd1) $fatal("jump_addr = %d", jump_addr);
    #10;
    // senales de control
    if (WB_write__out_decode) $fatal("WB_write = %d", WB_write__out_decode);
    if (MEM_write__out_decode) $fatal("MEM_write = %d", MEM_write__out_decode);

    $display("JAL");
    instruction = JAL;
    #10;
    if (!jump_flag) $fatal("jump_flag = %d", jump_flag);
    if (jump_addr !== {pc4[31:28], JUMP_ADDR, 2'b00}) $fatal("jump_addr = %d", jump_addr);
    #10;
    if (opcode !== 6'b000011) $fatal("opcode = %d", opcode);
    if (RA !== pc4) $fatal("RA = %d", RA);
    if (RB !== 32'd4) $fatal("RB = %d", RB);
    if (rt !== 5'd31) $fatal("rt = %d", rt);
    // senales de control
    if (!WB_write__out_decode) $fatal("WB_write = %d", WB_write__out_decode);
    if (!WB_mem_to_reg__out_decode) $fatal("WB_mem_to_reg = %d", WB_mem_to_reg__out_decode);
    if (MEM_write__out_decode) $fatal("MEM_write = %d", MEM_write__out_decode);
    if (EX_reg_dst__out_decode) $fatal("EX_reg_dst = %d", EX_reg_dst__out_decode);  // 1 -> rd
    if (EX_alu_op__out_decode !== 2'b00)
      $fatal("EX_alu_op = %d", EX_alu_op__out_decode);  // 00 -> Load o Store

    $display("JALR");
    instruction = JALR;
    #10;
    if (!jump_flag) $fatal("jump_flag = %d", jump_flag);
    if (jump_addr !== RS + 32'd1) $fatal("jump_addr = %d", jump_addr);
    #10;
    if (opcode !== 6'b000000) $fatal("opcode = %d", opcode);
    if (funct !== 6'b001001) $fatal("funct = %d", funct);
    if (RA !== pc4) $fatal("RA = %d", RA);
    if (RB !== 32'd4) $fatal("RB = %d", RB);
    if (rd !== RD) $fatal("rd = %d", rd);
    // senales de control
    if (!WB_write__out_decode) $fatal("WB_write = %d", WB_write__out_decode);
    if (!WB_mem_to_reg__out_decode) $fatal("WB_mem_to_reg = %d", WB_mem_to_reg__out_decode);
    if (MEM_write__out_decode) $fatal("MEM_write = %d", MEM_write__out_decode);
    if (!EX_reg_dst__out_decode) $fatal("EX_reg_dst = %d", EX_reg_dst__out_decode);  // 1 -> rd
    if (EX_alu_op__out_decode !== 2'b00)
      $fatal("EX_alu_op = %d", EX_alu_op__out_decode);  // 00 -> Load o Store

    // test saltos condicionales
    $display("BNE");  // se cumple la condicion, deberia haber salto
    i_reset = 1;
    instruction = BNE;
    #20;
    i_reset = 0;
    #10;
    if (!jump_flag) $fatal("jump_flag = %d", jump_flag);
    if (jump_addr !== (pc4 + (INMEDIATO << 2))) $fatal("jump_addr = %d", jump_addr);
    #10;
    if (WB_write__out_decode) $fatal("WB_write = %d", WB_write__out_decode);
    if (MEM_write__out_decode) $fatal("MEM_write = %d", MEM_write__out_decode);

    $display("BEQ");  // no se cumple la condicion, no deberia haber salto
    i_reset = 1;
    instruction = BEQ;
    #20;
    i_reset = 0;
    #10;
    if (jump_flag) $fatal("jump_flag = %d", jump_flag);
    #10;
    if (WB_write__out_decode) $fatal("WB_write = %d", WB_write__out_decode);
    if (MEM_write__out_decode) $fatal("MEM_write = %d", MEM_write__out_decode);

    // test halt
    $display("HALT");
    instruction = HALT;
    #10;
    if (!halt) $fatal("halt = %d", halt);
    if (WB_write__out_decode) $fatal("WB_write = %d", WB_write__out_decode);
    if (MEM_write__out_decode) $fatal("MEM_write = %d", MEM_write__out_decode);

    $display("Passed INSTRUCTION_DECODE Test Bench");
    $finish;
  end
endmodule
