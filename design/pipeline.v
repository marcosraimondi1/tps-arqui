module pipeline (
    input wire i_clk,
    input wire i_reset
);

  reg write_instruction_mem;  // flag para escribir memoria
  reg [31:0] instruction_mem_addr;
  reg [31:0] instruction_mem_data;

  wire jump_flag;
  wire [31:0] jump_addr;
  wire halt;
  wire stall;
  wire [31:0] instruction;
  wire [31:0] pc4;

  instruction_fetch #() instruction_fetch1 (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_write_instruction_mem(write_instruction_mem),
      .i_instruction_mem_addr(instruction_mem_addr),
      .i_instruction_mem_data(instruction_mem_data),
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
  wire [15:0] inmediato;
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

  instruction_decode instruction_decode1 (
      .i_clk(i_clk),
      .i_reset(i_reset),
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

      .o_halt(halt)
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
      .i_MEM_unsigned(MEM_unsigned__out_execute),
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
      .o_MEM_unsigned(MEM_write__out_execute),
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

      .i_write_reg(write_reg__out_execute),
      .i_data_to_write_in_MEM(data_to_write_in_MEM),
      .i_ALU_result(ALU_result__out_execute),

      // senales de control (input)
      .i_WB_write(WB_write__out_execute),
      .i_WB_mem_to_reg(WB_mem_to_reg__out_execute),
      .i_MEM_read(MEM_read__out_execute),
      .i_MEM_write(MEM_write__out_execute),
      .i_MEM_unsigned(MEM_write__out_execute),
      .i_MEM_byte_half_word(MEM_byte_half_word__out_execute),

      // senales de control (output)
      .o_WB_write(WB_write__out_mem),
      .o_WB_mem_to_reg(WB_mem_to_reg__out_mem),

      // salidas de la etapa
      .o_ALU_result(ALU_result__out_mem),
      .o_read_data (read_data_from_mem),
      .o_write_reg (write_reg__out_mem)
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

  assign rs_ID = instruction[25:21];
  assign rt_ID = instruction[20:16];

  unidad_deteccion_riesgos unidad_deteccion_riesgos1 (
      .i_rs_ID(rs_ID),
      .i_rt_ID(rt_ID),
      .i_rt_EX(rt),
      .i_mem_read_EX(MEM_read__out_decode),
      .o_stall(stall)
  );

endmodule

