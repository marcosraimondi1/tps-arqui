`timescale 1ns / 1ps

module pipeline_tb ();

  localparam NB_IF_ID = 64;
  localparam NB_ID_EX = 139;
  localparam NB_EX_MEM = 76;
  localparam NB_MEM_WB = 71;

  // ---------------------------------------------------------
  // --------------------- INSTRUCCIONES ---------------------
  // ---------------------------------------------------------
  // valores a usar
  localparam RS = 5'd5;
  localparam RT = 5'd6;
  localparam RD = 5'd17;
  localparam INMEDIATO = 16'd4;
  localparam JUMP_ADDR = 26'b00000000000000000000001001;  // salta a 100100 = 36
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
  localparam SLTU = {6'b000000, RS, RT, RD, 5'b00000, 6'b101011};
  // tipo I
  localparam LB = {6'b100000, RS, RT, INMEDIATO};
  localparam LH = {6'b100001, RS, RT, INMEDIATO};
  localparam LWU = {6'b100111, RS, RT, INMEDIATO};
  localparam LBU = {6'b100100, RS, RT, INMEDIATO};
  localparam LHU = {6'b100101, RS, RT, INMEDIATO};
  localparam SB = {6'b101000, RS, RT, INMEDIATO};
  localparam SH = {6'b101001, RS, RT, INMEDIATO};

  localparam LW = {6'b100011, 5'd0, 5'd1, INMEDIATO};  // carga la posicion 4 en el registro 1
  localparam SW = {6'b101011, 5'd0, RT, INMEDIATO};  // almacena en la posicion 4 el contenido de RT
  localparam ORI = {6'b001101, 5'd1, RT, 16'd2};  // rt <- rs | inmediato = 1 | 2 = 3

  localparam ADDI = {6'b001000, RS, RT, INMEDIATO};
  localparam ADDIU = {6'b001001, RS, RT, INMEDIATO};
  localparam ANDI = {6'b001100, RS, RT, INMEDIATO};
  localparam XORI = {6'b001110, RS, RT, INMEDIATO};
  localparam LUI = {6'b001111, 5'b00000, RT, INMEDIATO};
  localparam SLTI = {6'b001010, RS, RT, INMEDIATO};
  localparam SLTIU = {6'b001011, RS, RT, INMEDIATO};
  localparam BEQ = {6'b000100, RS, RT, INMEDIATO};
  localparam BNE = {6'b000101, RS, RT, INMEDIATO};
  localparam J = {6'b000010, JUMP_ADDR};
  localparam JAL = {6'b000011, JUMP_ADDR};
  // tipo J
  localparam JR = {6'b000000, RS, 15'b000000000000000, 6'b001000};
  localparam JALR = {6'b000000, RS, 5'b00000, RD, 5'b00000, 6'b001001};

  // especiales
  localparam HALT = 32'hffffffff;
  localparam NOP = 32'h00000000;

  // para hacer un loop
  localparam REG1 = 5'd1;
  localparam REG2 = 5'd2;
  localparam REG3 = 5'd3;

  localparam LIM = 16'd4;  // numero de iteraciones
  localparam LOOP_BACK = 16'b1111111111111100;  // direccion relativa loop (-4 instrucciones atras)

  localparam R1_INIT1 = {6'b000000, REG1, REG1, REG1, 5'b00000, 6'b100011};  // Inicializa r1 en 0
  localparam R2_INIT1 = {6'b000000, REG2, REG2, REG2, 5'b00000, 6'b100011};  // Inicializa r2 en 0
  localparam R3_INIT = {6'b000000, REG3, REG3, REG3, 5'b00000, 6'b100011};  // Inicializa r3 en 0
  localparam R2_LIM = {6'b001000, REG2, REG2, LIM};  // Inicializa r2 en LIM
  localparam R1_ACUM = {6'b001000, REG1, REG1, 16'd1};  // Acumula en r1
  localparam R3_INC = {6'b001000, REG3, REG3, 16'd1};  // Incrementa en 1 a r3
  localparam BNE_R3_R2 = {6'b000101, REG3, REG2, LOOP_BACK};  // Salta a LOOP_BACK si r2 != r3

  // ---------------------------------------------------------
  // ---------------------------------------------------------
  // ---------------------------------------------------------

  reg i_clk;
  reg i_reset;
  reg i_halt;
  reg i_write_instruction_mem;
  reg [31:0] i_instruction_mem_addr;
  reg [31:0] i_instruction_mem_data;
  reg [4:0] i_r_addr_registers;
  reg [4:0] i_r_addr_data_mem;

  wire [31:0] o_r_data_registers;
  wire [31:0] o_r_data_data_mem;
  wire [NB_IF_ID-1:0] o_IF_ID;
  wire [NB_ID_EX-1:0] o_ID_EX;
  wire [NB_EX_MEM-1:0] o_EX_MEM;
  wire [NB_MEM_WB-1:0] o_MEM_WB;
  wire o_end;

  pipeline #(
      .NB_IF_ID (NB_IF_ID),
      .NB_ID_EX (NB_ID_EX),
      .NB_EX_MEM(NB_EX_MEM),
      .NB_MEM_WB(NB_MEM_WB)
  ) pipeline1 (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_stop(i_halt),
      .i_write_instruction_mem(i_write_instruction_mem),
      .i_instruction_mem_addr(i_instruction_mem_addr),
      .i_instruction_mem_data(i_instruction_mem_data),
      .i_r_addr_registers(i_r_addr_registers),
      .i_r_addr_data_mem(i_r_addr_data_mem),

      .o_r_data_registers(o_r_data_registers),
      .o_r_data_data_mem(o_r_data_data_mem),
      .o_IF_ID(o_IF_ID),
      .o_ID_EX(o_ID_EX),
      .o_EX_MEM(o_EX_MEM),
      .o_MEM_WB(o_MEM_WB),
      .o_end(o_end)
  );

  // latches intermedios del pipeline
  // IF_ID
  wire [31:0] instruction_IF_ID;
  wire [31:0] pc4_IF_ID;

  // ID_EX
  wire [31:0] RA_ID_EX;
  wire [31:0] RB_ID_EX;
  wire [4:0] rs_ID_EX;
  wire [4:0] rt_ID_EX;
  wire [4:0] rd_ID_EX;
  wire [5:0] funct_ID_EX;
  wire [31:0] inmediato_ID_EX;
  wire [5:0] opcode_ID_EX;
  wire [4:0] shamt_ID_EX;
  wire WB_write_ID_EX;
  wire WB_mem_to_reg_ID_EX;
  wire MEM_read_ID_EX;
  wire MEM_write_ID_EX;
  wire MEM_unsigned_ID_EX;
  wire [1:0] MEM_byte_half_word_ID_EX;
  wire EX_alu_src_ID_EX;
  wire EX_reg_dst_ID_EX;
  wire [1:0] EX_alu_op_ID_EX;

  // EX_MEM
  wire [4:0] write_reg_EX_MEM;
  wire [31:0] data_to_write_in_MEM;
  wire [31:0] ALU_result_EX_MEM;
  wire WB_write_EX_MEM;
  wire WB_mem_to_reg_EX_MEM;
  wire MEM_read_EX_MEM;
  wire MEM_write_EX_MEM;
  wire MEM_unsigned_EX_MEM;
  wire [1:0] MEM_byte_half_word_EX_MEM;

  // MEM_WB
  wire [31:0] ALU_result_MEM_WB;
  wire [31:0] read_data_from_mem;
  wire [4:0] write_reg_MEM_WB;
  wire WB_write_MEM_WB;
  wire WB_mem_to_reg_MEM_WB;

  always #10 i_clk = ~i_clk;

  initial begin
    i_clk = 0;
    i_reset = 0;
    i_halt = 0;
    i_write_instruction_mem = 0;
    i_instruction_mem_addr = 0;
    i_instruction_mem_data = 0;
    i_r_addr_registers = 0;
    i_r_addr_data_mem = 0;

    #20;
    i_reset = 1;
    #20;
    i_reset = 0;
    i_halt  = 1;
    #40;

    if (pc4_IF_ID != 32'd4) $fatal("pc4_IF_ID = %d, expected 4", pc4_IF_ID);

    // escritura de las instrucciones
    i_write_instruction_mem = 1;

    i_instruction_mem_addr  = 0;
    i_instruction_mem_data  = ADDI;  // rt <- rs + inmediato = 0 + 4 = 4
    #20;
    i_instruction_mem_addr = 4;  // tiene que haber cortocircuito para que se guarde el ADDI
    i_instruction_mem_data = SW;  // mem[base+offset] <- rt = mem[0+4] <- 4
    #20;
    i_instruction_mem_addr = 8;
    i_instruction_mem_data = LW;  // rt <- mem[base+offset] = mem[0+4] = 4 (en reg 1)
    #20;
    i_instruction_mem_addr = 12;  // tiene que haber una detencion del pipeline de un ciclo
    i_instruction_mem_data = ORI;  // rt <- rs (reg 1) | inmediato = 4 | 2 = 6
    #20;
    i_instruction_mem_addr = 16;  // salta despues de ejecutar la siguiente instruccion
    i_instruction_mem_data = J;  // pc = 36
    #20;
    i_instruction_mem_addr = 20;  // delay slot
    i_instruction_mem_data = NOP;  // NOP
    #20;
    i_instruction_mem_addr = 24;
    i_instruction_mem_data = NOP;  // NOP
    #20;
    i_instruction_mem_addr = 28;
    i_instruction_mem_data = NOP;  // NOP
    #20;
    i_instruction_mem_addr = 32;
    i_instruction_mem_data = NOP;  // NOP
    #20;
    i_instruction_mem_addr = 36;  // aca se salta
    i_instruction_mem_data = R1_INIT1;
    #20;
    i_instruction_mem_addr = 40;
    i_instruction_mem_data = NOP;  // NOP
    #20;
    i_instruction_mem_addr = 44;
    i_instruction_mem_data = R2_INIT1;
    #20;
    i_instruction_mem_addr = 48;
    i_instruction_mem_data = R3_INIT;
    #20;
    i_instruction_mem_addr = 52;
    i_instruction_mem_data = R2_LIM;
    #20;
    i_instruction_mem_addr = 56;
    i_instruction_mem_data = R1_ACUM;
    #20;
    i_instruction_mem_addr = 60;
    i_instruction_mem_data = R3_INC;
    #20;
    i_instruction_mem_addr = 64;  // aca branch, usa reg r3 asique debe haber stall
    i_instruction_mem_data = BNE_R3_R2;
    #20;
    i_instruction_mem_addr = 68;  // delay slot
    i_instruction_mem_data = NOP;  // NOP
    #20;
    i_instruction_mem_addr = 72;  // despues de este halt igual se deberian terminar las ops
    i_instruction_mem_data = HALT;  // halt
    #20;
    i_write_instruction_mem = 0;

    // ejecucion de las instrucciones
    i_halt = 0;
    #20;  // avanzo un ciclo
    if (pc4_IF_ID != 32'd8) $fatal("pc4_IF_ID = %d, expected 8", pc4_IF_ID);
    if (instruction_IF_ID != ADDI) $fatal("instruction_IF_ID expected ADDI");

    @(posedge o_end);
    #60;
    i_halt = 1;
    i_r_addr_registers = REG1;
    i_r_addr_data_mem = 4;
    #10;
    if (o_r_data_registers != 32'd4)
      $fatal("o_r_data_registers = %d, expected 4", o_r_data_registers);
    if (o_r_data_data_mem != 32'd4) $fatal("o_r_data_data_mem = %d, expected 4", o_r_data_data_mem);
    i_r_addr_registers = RT;
    #10;
    if (o_r_data_registers != 32'd6)
      $fatal("o_r_data_registers = %d, expected 6", o_r_data_registers);



    $display("Pipeline testbench finished");
    $finish;
  end

  assign {instruction_IF_ID, pc4_IF_ID} = o_IF_ID;

  assign {
      RA_ID_EX,
      RB_ID_EX,
      rs_ID_EX,
      rt_ID_EX,
      rd_ID_EX,
      funct_ID_EX,
      inmediato_ID_EX,
      opcode_ID_EX,
      shamt_ID_EX,
      WB_write_ID_EX,
      WB_mem_to_reg_ID_EX,
      MEM_read_ID_EX,
      MEM_write_ID_EX,
      MEM_unsigned_ID_EX,
      MEM_byte_half_word_ID_EX,
      EX_alu_src_ID_EX,
      EX_reg_dst_ID_EX,
      EX_alu_op_ID_EX
      } = o_ID_EX;

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
      } = o_EX_MEM;

  assign {ALU_result_MEM_WB,
      read_data_from_mem,
      write_reg_MEM_WB,
      WB_write_MEM_WB,
      WB_mem_to_reg_MEM_WB
      } = o_MEM_WB;

endmodule
