import re
import argparse

class Assembler:
    def __init__(self, file_path="source.asm", output_path="output.hex", debug=False):
        self.file_path = file_path
        self.output_path = output_path
        self.debug = debug
        self.asm_tokens = []
        self.binary_code = ""
        self.byte_code = []

    def compile(self):
        try:
            file = open(self.file_path, encoding='utf-8')
            self.tokenizer(file)
            file.close()
        except FileNotFoundError:
            print(f'No se encontro el archivo {self.file_path}')
            exit(1)

        for inst in self.asm_tokens:
            self.binary_code += (self.instruction_generator(inst))

        self.write_output()


    def write_output(self):
        for i in range(int(len(self.binary_code)/8)):
            num =   int(self.binary_code[i*8:(i+1)*8],2)
            self.byte_code.append(num)

        try:
            out_file = open(self.output_path, "wb")
            out_file.write((''.join(chr(i) for i in self.byte_code)).encode('charmap'))
            out_file.close()
        except Exception as e:
            print(f'Error al escribir el archivo de salida: {e}')
            exit(1)

    # Retorna una lista con los tokens para cada instrucción
    def tokenizer(self, asm_file):
        lines = asm_file.readlines()
        gramatical_rules = (r'(\w+)\s+(-{0,1}\w+)\s*,\s*(-{0,1}\w+)\s*,\s*(-{0,1}\w+)\s*$'          # sub r2, r4, r1
                            # lw r4, 176(r0)
                            + r'|(\w+)\s+(-{0,1}\w+)\s*,\s*(-{0,1}\w+)\s*\(\s*(-{0,1}\w+)\)\s*$'
                            # bez r2, 8
                            + r'|(\w+)\s+(-{0,1}\w+)\s*,\s*(-{0,1}\w+)\s*$'
                            + r'|(\w+)\s+(-{0,1}\w+)\s*$')                                          # J r1

        for line in lines:
            line = line.upper()
            formated_line = line.replace('\n', '')
            if not formated_line == 'HALT':
                self.asm_tokens.append(
                    list(filter(None, re.split(string=formated_line, pattern=gramatical_rules))))
            else:
                self.asm_tokens.append(['HALT'])


    # Toma uno de los números de la instrucción o el número de registro y lo pasa a un string binario
    # SLL r1, 2, -3, por ejemplo acá si pedimos sa = "11101"
    def str_to_bin_str(self, string, n_bits):
        bin_str = ''
        matches = re.search('R{0,1}(-{0,1}\\d+)', string)
        if matches == None:
            print(f'No se pudo matchear ningun valor para el str = {string}')
            exit(1)

        num = int(matches[1])

        if num < 0:
            bin_str = format(num & 0xffffffff, '32b')
        else:
            bin_str = '{:032b}'.format(num)

        return bin_str[32-n_bits:]

    def instruction_generator(self, token):
        inst_bin = "00000000000000000000000000000000"
        i_name = token[0]
        if i_name == "SLL":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_shamt(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "000000")
        elif i_name == "SRL":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_shamt(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "000010")
        elif i_name == "SRA":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_shamt(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "000011")
        elif i_name == "SLLV":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "000100")
        elif i_name == "SRLV":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "000110")
        elif i_name == "SRAV":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "000111")
        elif i_name == "ADD":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
            inst_bin = self.set_func(inst_bin, "100000")
        elif i_name == "SUB":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
            inst_bin = self.set_func(inst_bin, "100010")
        elif i_name == "ADDU":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
            inst_bin = self.set_func(inst_bin, "100001")
        elif i_name == "SUBU":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
            inst_bin = self.set_func(inst_bin, "100011")
        elif i_name == "AND":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "100100")
        elif i_name == "OR":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
            inst_bin = self.set_func(inst_bin, "100101")
        elif i_name == "XOR":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
            inst_bin = self.set_func(inst_bin, "100110")
        elif i_name == "NOR":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
            inst_bin = self.set_func(inst_bin, "100111")
        elif i_name == "SLT":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
            inst_bin = self.set_func(inst_bin, "101010")
        elif i_name == "SLTU":
            inst_bin = self.set_rd(inst_bin, token[1])
            inst_bin = self.set_rt(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
            inst_bin = self.set_func(inst_bin, "101011")
        elif i_name == "LB":
            inst_bin = self.set_op_code(inst_bin, "100000")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "LH":
            inst_bin = self.set_op_code(inst_bin, "100001")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "LW":
            inst_bin = self.set_op_code(inst_bin, "100011")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "LWU":
            inst_bin = self.set_op_code(inst_bin, "100111")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "LHU":
            inst_bin = self.set_op_code(inst_bin, "100101")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "LBU":
            inst_bin = self.set_op_code(inst_bin, "100100")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "SB":
            inst_bin = self.set_op_code(inst_bin, "101000")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "SH":
            inst_bin = self.set_op_code(inst_bin, "101001")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])
        elif i_name == "SW":
            inst_bin = self.set_op_code(inst_bin, "101011")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
            inst_bin = self.set_rs(inst_bin, token[3])

        elif i_name == "ADDI":
            inst_bin = self.set_op_code(inst_bin, "001000")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
        elif i_name == "ADDIU":
            inst_bin = self.set_op_code(inst_bin, "001001")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
        elif i_name == "ANDI":
            inst_bin = self.set_op_code(inst_bin, "001100")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
        elif i_name == "ORI":
            inst_bin = self.set_op_code(inst_bin, "001101")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
        elif i_name == "XORI":
            inst_bin = self.set_op_code(inst_bin, "001110")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
        elif i_name == "LUI":
            inst_bin = self.set_op_code(inst_bin, "001111")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[2])
        elif i_name == "SLTI":
            inst_bin = self.set_op_code(inst_bin, "001010")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
        elif i_name == "SLTIU":
            inst_bin = self.set_op_code(inst_bin, "001011")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
        elif i_name == "BEQ":
            inst_bin = self.set_op_code(inst_bin, "000100")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
        elif i_name == "BNE":
            inst_bin = self.set_op_code(inst_bin, "000101")
            inst_bin = self.set_rt(inst_bin, token[1])
            inst_bin = self.set_offset_immed(inst_bin, token[3])
            inst_bin = self.set_rs(inst_bin, token[2])
        elif i_name == "J":
            inst_bin = self.set_op_code(inst_bin, "000010")
            inst_bin = self.set_target(inst_bin, token[1])
        elif i_name == "JAL":
            inst_bin = self.set_op_code(inst_bin, "000011")
            inst_bin = self.set_target(inst_bin, token[1])
        elif i_name == "JR":
            inst_bin = self.set_func(inst_bin, "001000")
            inst_bin = self.set_rs(inst_bin, token[1])
        elif i_name == "JALR":
            inst_bin = self.set_func(inst_bin, "001001")
            if len(token) > 1:
                inst_bin = self.set_rs(inst_bin, token[2])
                inst_bin = self.set_rd(inst_bin, token[1])
            else:
                inst_bin = self.set_rs(inst_bin, token[1])
                inst_bin = self.set_rd(inst_bin, "31")

        elif i_name == "HALT":
            inst_bin = "11111111111111111111111111111111"
        elif i_name == "NOP":
            inst_bin = "00000000000000000000000000000000"
        else:
            print(i_name)
            print(f'Instruccion no reconocida {i_name}')
            exit(1)

        if self.debug:
            print(f"{i_name}: {inst_bin}")

        return inst_bin

    def set_op_code(self, inst, opcode):
        return opcode + inst[6:]

    def set_rs(self, inst, rs):
        rs = self.str_to_bin_str(rs, 5)
        return inst[0:6] + rs + inst[11:]

    def set_rt(self, inst, rt):
        rt = self.str_to_bin_str(rt, 5)
        return inst[0:11] + rt + inst[16:]

    def set_rd(self, inst, rd):
        rd = self.str_to_bin_str(rd, 5)
        return inst[0:16] + rd + inst[21:]

    def set_shamt(self, inst, shamt):
        shamt = self.str_to_bin_str(shamt, 5)
        return inst[0:21] + shamt + inst[26:]

    def set_func(self, inst, aluFunc):
        return inst[0:26] + aluFunc

    def set_offset_immed(self, inst, offset):
        offset = self.str_to_bin_str(offset, 16)
        return inst[0:16] + offset

    def set_target(self, inst, target):
        target = self.str_to_bin_str(target, 26)
        return inst[0:6] + target


