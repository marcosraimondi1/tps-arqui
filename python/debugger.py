import time
import serial
import compiler as cp
import argparse

BAUDRATE = 19200
PORT = '/dev/ttyUSB1'

ser = serial.Serial(
    port=PORT, 
    baudrate=BAUDRATE,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
)

LOAD_INSTR_OP = bytes([0b00000000]);
START_CONT_OP = bytes([0b00000001]);
START_DEBUG_OP = bytes([0b00000010]);
STEP_OP = bytes([0b00000011]);
END_DEBUG_OP = bytes([0b00000100]);

def main():
    parser = argparse.ArgumentParser(prog='debugger.py', description='Debugger custom')
    parser.add_argument('file_path', type=str, help='Ruta del archivo a compilar')
    parser.add_argument('-o', '--output', type=str, help='Ruta del archivo de salida, por defecto output.hex', default="output.hex")
    parser.add_argument('-v', '--verbose', action='store_true', help='Muestra información adicional')
    args = parser.parse_args()

    asm = cp.Assembler(args.file_path, args.output, args.verbose)
    asm.compile()

    # enviar instrucciones
    ser.open()

    send_opcode(LOAD_INSTR_OP)
    send_instructions(asm.byte_code)
    send_opcode(START_CONT_OP)

    reg_data = receive_registers()
    latch1_data = receive_latch("IF_ID")
    latch2_data = receive_latch("ID_EX")
    latch3_data = receive_latch("EX_MEM")
    latch4_data = receive_latch("MEM_WB")
    mem_data = receive_mem()


    ser.close()

    registers = decode_registers(reg_data)
    latch1 = decode_latch("IF_ID", latch1_data)
    latch2 = decode_latch("ID_EX", latch2_data)
    latch3 = decode_latch("EX_MEM", latch3_data)    
    latch4 = decode_latch("MEM_WB", latch4_data)
    mem = decode_mem(mem_data)

    print("Registers: ", registers)
    print("IF_ID: ", latch1)
    print("ID_EX: ", latch2)
    print("EX_MEM: ", latch3)
    print("MEM_WB: ", latch4)
    print("Mem: ", mem)

def send_instructions(instructions):
    for instr in instructions:
        ser.write(instr)
        time.sleep(0.25)

def send_opcode(a):
    if (a not in [LOAD_INSTR_OP, START_CONT_OP, START_DEBUG_OP, STEP_OP, END_DEBUG_OP]):
        print("Invalid opcode")
        exit(1)

    # Set operator
    ser.write(a)
    recv = ser.read(1)
    return recv

MEM_SIZE=256 # memoria de 256 bytes (4 bytes es un dato)
USED_MEM_ARRAY_LEN=8 # 1 bit por cada dato

def receive_mem():
    ser.timeout = 0.25
    recv = ser.read(MEM_SIZE+USED_MEM_ARRAY_LEN)
    ser.timeout = None
    return recv

def decode_mem(data):
    data_len = (len(data) - USED_MEM_ARRAY_LEN) // 4 # 4 bytes son 1 dato

    mem_data = []
    for i in range(0, data_len):
        mem_data.append(int.from_bytes(data[i*4:i*4+4], byteorder='big'))

    used_mem = []
    used_mem_data = data[len(data) - USED_MEM_ARRAY_LEN:]
    for data_byte in used_mem_data:
        for i in range(0,8):
            used_mem.append(data_byte & (0b10000000>>i) != 0)

    if (sum(used_mem) != len(mem_data)):
        print("Error: used_mem array is not consistent with the data")
        print("used_mem: ", used_mem)
        print("mem_data: ", mem_data)

    return dict(
        num_data = sum(used_mem),
        mem_data = mem_data,
        used_mem = used_mem
    )


def receive_registers():
    recv = ser.read(32*4)
    return recv

def decode_registers(data):
    registers = []
    for i in range(0, 32):
        registers.append(int.from_bytes(data[i*4:i*4+4], byteorder='big'))
    return registers
    

def receive_latch(latch):
    if latch == "IF_ID":
        recv = ser.read(8)
    elif latch == "ID_EX":
        recv = ser.read(21)
    elif latch == "EX_MEM":
        recv = ser.read(11)
    elif latch == "MEM_WB":
        recv = ser.read(10)
    else:
        return -1

    return recv

def decode_latch(latch, data):
    if latch == "IF_ID":
        return dict(
            latch = "IF_ID",
            instruction = int.from_bytes(data[0:4], byteorder='big'),
            pc4 = int.from_bytes(data[4:8], byteorder='big')
        )
    elif latch == "ID_EX":
        return dict(
                latch = "ID_EX",
                RA=int.from_bytes(data[0:4], byteorder='big'),
                RB=int.from_bytes(data[4:8], byteorder='big'),
                rs=int.from_bytes(data[8], byteorder='big'),
                rt=int.from_bytes(data[9], byteorder='big'),
                rd=int.from_bytes(data[10], byteorder='big'),
                funct=int.from_bytes(data[11], byteorder='big'),
                inmediato=int.from_bytes(data[12:16], byteorder='big'),
                opcode=int.from_bytes(data[16], byteorder='big'),
                shamt=int.from_bytes(data[17], byteorder='big'),
                WB_ctrl=int.from_bytes(data[18], byteorder='big'),
                MEM_ctrl=int.from_bytes(data[19], byteorder='big'),
                EX_ctrl=int.from_bytes(data[20], byteorder='big')
            )
    elif latch == "EX_MEM":
        return dict(
            latch = "EX_MEM",
            write_reg=int.from_bytes(data[0], byteorder='big'),
            data_to_write=int.from_bytes(data[1:5], byteorder='big'),
            ALU_result=int.from_bytes(data[5:9], byteorder='big'),
            WB_ctrl=int.from_bytes(data[9], byteorder='big'),
            MEM_ctrl=int.from_bytes(data[10], byteorder='big')
        )
    elif latch == "MEM_WB":
        return dict(
            latch = "MEM_WB",
            ALU_result=int.from_bytes(data[0:4], byteorder='big'),
            read_data_from_mem=int.from_bytes(data[4:8], byteorder='big'),
            write_reg=int.from_bytes(data[8], byteorder='big'),
            WB_ctrl=int.from_bytes(data[9], byteorder='big')
        )

    return dict()

if __name__ == "__main__":
    main()

