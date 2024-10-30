module pipeline #(
    parameter NB_IF_ID  = 64,
    parameter NB_ID_EX  = 139,
    parameter NB_EX_MEM = 76,
    parameter NB_MEM_WB = 71
) (
    input wire i_clk,
    input wire i_reset,
    input wire i_stop,
    input wire i_write_instruction_mem,  // flag para escribir memoria de instrucciones
    input wire [31:0] i_instruction_mem_addr,  // direccion de memoria de instrucciones
    input wire [31:0] i_instruction_mem_data,  // dato a escribir en memoria de instrucciones

    input wire [4:0] i_r_addr_registers,
    input wire [4:0] i_r_addr_data_mem,
    output wire [31:0] o_r_data_registers,
    output wire [31:0] o_r_data_data_mem,
    output wire [NB_IF_ID-1:0] o_IF_ID,
    output wire [NB_ID_EX-1:0] o_ID_EX,
    output wire [NB_EX_MEM-1:0] o_EX_MEM,
    output wire [NB_MEM_WB-1:0] o_MEM_WB,
    output wire o_end
);

  wire jump_flag;
  wire [31:0] jump_addr;
  wire stall;
  wire [31:0] instruction;
  wire [31:0] pc4;

  wire halt;  // stop de afuera o halt de instruccion
  wire halt_from_instruction;

  instruction_fetch #() instruction_fetch1 (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_write_instruction_mem(i_write_instruction_mem),
      .i_instruction_mem_addr(i_instruction_mem_addr),
      .i_instruction_mem_data(i_instruction_mem_data),
      .i_jump(jump_flag),
      .i_jump_addr(jump_addr),
      .i_stall(stall),
      .i_halt(halt),
      .o_instruction(instruction),
      .o_pc4(pc4)
  );


  // senales del writeback al decode
  wire write_enable_WB;
  wire [4:0] register_WB;
  wire [31:0] data_WB;

  // senales del decode para el execute
  wire [31:0] RA;
  wire [31:0] RB;
  wire [4:0] rs;
  wire [4:0] rt;
  wire [4:0] rd;
  wire [5:0] funct;
  wire [31:0] inmediato;
  wire [5:0] opcode;
  wire [4:0] shamt;

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
  wire [1:0] salto_con_registro;  // 00 no salto, 01 salto usando rs y rt, 10 salto usando rs

  instruction_decode instruction_decode1 (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_halt(halt),
      .i_pc4(pc4),
      .i_instruction(instruction),
      .i_write_enable_WB(write_enable_WB),
      .i_register_WB(register_WB),
      .i_data_WB(data_WB),
      // senal de stall del detector de riesgos
      .i_stall(stall),
      .o_RA(RA),
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
      .o_salto_con_registro(salto_con_registro),

      .o_halt(halt_from_instruction),

      .i_r_addr(i_r_addr_registers),
      .o_r_data(o_r_data_registers)
  );



  // senales de control
  wire WB_write__out_execute;
  wire WB_mem_to_reg__out_execute;
  wire MEM_read__out_execute;
  wire MEM_write__out_execute;
  wire MEM_unsigned__out_execute;
  wire [1:0] MEM_byte_half_word__out_execute;

  // cortocircuito
  wire [1:0] corto_rs;
  wire [1:0] corto_rt;

  // salidas
  wire [4:0] write_reg__out_execute;
  wire [31:0] ALU_result__out_execute;
  wire [31:0] data_to_write_in_MEM;

  instruction_execute intstruction_execute1 (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_halt(i_stop),
      .i_RA(RA),
      .i_RB(RB),
      .i_rs(rs),
      .i_rt(rt),
      .i_rd(rd),
      .i_funct(funct),
      .i_inmediato(inmediato),
      .i_opcode(opcode),
      .i_shamt(shamt),

      // senales de control
      .i_WB_write(WB_write__out_decode),
      .i_WB_mem_to_reg(WB_mem_to_reg__out_decode),
      .i_MEM_read(MEM_read__out_decode),
      .i_MEM_write(MEM_write__out_decode),
      .i_MEM_unsigned(MEM_unsigned__out_decode),
      .i_MEM_byte_half_word(MEM_byte_half_word__out_decode),
      .i_EX_alu_src(EX_alu_src__out_decode),
      .i_EX_reg_dst(EX_reg_dst__out_decode),
      .i_EX_alu_op(EX_alu_op__out_decode),

      // senales de unidad de cortocircuito
      .i_corto_rs(corto_rs),  // RS -> alu data A
      .i_corto_rt(corto_rt),  // RT -> alu data B
      .i_input_ALU_MEM(ALU_result__out_execute),  // el resultado de la instruccion anterior
      .i_output_WB(data_WB),

      // senales de control (output)
      .o_WB_write(WB_write__out_execute),
      .o_WB_mem_to_reg(WB_mem_to_reg__out_execute),
      .o_MEM_read(MEM_read__out_execute),
      .o_MEM_write(MEM_write__out_execute),
      .o_MEM_unsigned(MEM_unsigned__out_execute),
      .o_MEM_byte_half_word(MEM_byte_half_word__out_execute),

      // salidas
      .o_write_reg(write_reg__out_execute),
      .o_data_to_write_in_MEM(data_to_write_in_MEM),
      .o_ALU_result(ALU_result__out_execute)
  );


  // senales de control
  wire WB_write__out_mem;
  wire WB_mem_to_reg__out_mem;

  // salidas
  wire [31:0] ALU_result__out_mem;
  wire [31:0] read_data_from_mem;
  wire [4:0] write_reg__out_mem;

  etapa_mem etapa_mem1 (
      .i_clk  (i_clk),
      .i_reset(i_reset),
      .i_halt (i_stop),

      .i_write_reg(write_reg__out_execute),
      .i_data_to_write_in_MEM(data_to_write_in_MEM),
      .i_ALU_result(ALU_result__out_execute),

      // senales de control (input)
      .i_WB_write(WB_write__out_execute),
      .i_WB_mem_to_reg(WB_mem_to_reg__out_execute),
      .i_MEM_read(MEM_read__out_execute),
      .i_MEM_write(MEM_write__out_execute),
      .i_MEM_unsigned(MEM_unsigned__out_execute),
      .i_MEM_byte_half_word(MEM_byte_half_word__out_execute),

      // senales de control (output)
      .o_WB_write(WB_write__out_mem),
      .o_WB_mem_to_reg(WB_mem_to_reg__out_mem),

      // salidas de la etapa
      .o_ALU_result(ALU_result__out_mem),
      .o_read_data (read_data_from_mem),
      .o_write_reg (write_reg__out_mem),

      // debug unit
      .i_r_addr(i_r_addr_data_mem),
      .o_r_data(o_r_data_data_mem)
  );


  etapa_wb etapa_wb1 (
      .i_write_reg (write_reg__out_mem),
      .i_ALU_result(ALU_result__out_mem),
      .i_read_data (read_data_from_mem),

      // senales de control (input)
      .i_WB_write(WB_write__out_mem),
      .i_WB_mem_to_reg(WB_mem_to_reg__out_mem),

      // salidas de la etapa
      .o_write_reg(register_WB),
      .o_WB_data  (data_WB),
      .o_WB_write (write_enable_WB)
  );

  unidad_cortocircuito unidad_cortocircuito1 (
      .i_rd_MEM(write_reg__out_execute),
      .i_rd_WB(write_reg__out_mem),
      .i_rs_EX(rs),
      .i_rt_EX(rt),
      .i_write_reg_WB(WB_write__out_mem),
      .i_write_reg_MEM(WB_write__out_execute),
      .o_corto_rs(corto_rs),
      .o_corto_rt(corto_rt)
  );

  wire [4:0] rs_ID;
  wire [4:0] rt_ID;

  wire [4:0] reg_dst_EX;
  assign reg_dst_EX = EX_reg_dst__out_decode ? rd : rt;

  unidad_deteccion_riesgos unidad_deteccion_riesgos1 (
      .i_rs_ID(rs_ID),
      .i_rt_ID(rt_ID),
      .i_rt_EX(rt),
      .i_mem_read_EX(MEM_read__out_decode),

      .i_salto_con_registro(salto_con_registro),  // 00 no salto, 01 salto usando rs y rt, 10 salto usando rs
      .i_reg_dst_EX(reg_dst_EX),
      .i_reg_dst_MEM(write_reg__out_execute),
      .i_reg_dst_WB(write_reg__out_mem),
      .i_WB_write_EX(WB_write__out_decode),
      .i_WB_write_MEM(WB_write__out_execute),
      .i_WB_write_WB(WB_write__out_mem),

      .o_stall(stall)
  );

  assign rs_ID = instruction[25:21];
  assign rt_ID = instruction[20:16];

  assign halt = i_stop || halt_from_instruction;

  // latches intermedios del pipeline
  assign o_IF_ID = {
    instruction,  // 32 bits
    pc4  // 32 bits
  };  // total 64 bits

  assign o_ID_EX = {
    RA,  // 32 bits
    RB,  // 32 bits
    rs,  // 5 bits
    rt,  // 5 bits
    rd,  // 5 bits
    funct,  // 6 bits
    inmediato,  // 32 bits
    opcode,  // 6 bits
    shamt,  // 5 bits
    WB_write__out_decode,  // 1 bit
    WB_mem_to_reg__out_decode,  // 1 bit
    MEM_read__out_decode,  // 1 bit
    MEM_write__out_decode,  // 1 bit
    MEM_unsigned__out_decode,  // 1 bit
    MEM_byte_half_word__out_decode,  // 2 bits
    EX_alu_src__out_decode,  // 1 bit
    EX_reg_dst__out_decode,  // 1 bit
    EX_alu_op__out_decode  // 2 bits
  };  // total 139 bits

  assign o_EX_MEM = {
    write_reg__out_execute,  // 5 bits
    data_to_write_in_MEM,  // 32 bits
    ALU_result__out_execute,  // 32 bits
    WB_write__out_execute,  // 1 bit
    WB_mem_to_reg__out_execute,  // 1 bit
    MEM_read__out_execute,  // 1 bit
    MEM_write__out_execute,  // 1 bit
    MEM_unsigned__out_execute,  // 1 bit
    MEM_byte_half_word__out_execute  // 2 bits
  };  // total 76 bits

  assign o_MEM_WB = {
    ALU_result__out_mem,  // 32 bits
    read_data_from_mem,  // 32 bits
    write_reg__out_mem,  // 5 bits
    WB_write__out_mem,  // 1 bit
    WB_mem_to_reg__out_mem  // 1 bit
  };  // total 71 bits

  assign o_end = halt_from_instruction;

endmodule

