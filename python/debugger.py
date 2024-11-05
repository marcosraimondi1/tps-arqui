import time
import serial
import compiler as cp

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

    # enviar instrucciones
    # ser.open()

    while True:
        print("1. Cargar instrucciones")
        print("2. Iniciar ejecución continua")
        print("3. Iniciar ejecución paso a paso")
        print("4. Salir")
        print("5. Test Uart")
        option = int(input("Ingrese la opción: "))

        if option == 1:
            path = input("Seleccione el archivo a cargar (path): ")
            asm = cp.Assembler(path, "output.hex", True)
            asm.compile()
            send_instructions(asm.byte_code)
        elif option == 2:
            run_continuous()
        elif option == 3:
            run_debug()
        elif option == 4:
            break
        elif option == 5:
            while True:
                tosend = input("Ingrese un entero a enviar: ")
                if tosend == "exit":
                    break
                value = int(tosend)
                tosend = value.to_bytes(1, byteorder='big')
                ser.write(tosend)

                print(f"Enviado: {tosend}, Recibido: {ser.read(1)}")
        else:
            print("Opción inválida")

    ser.close()

def run_debug():
    send_opcode(START_DEBUG_OP)

    while True:
        print("1. Step")
        print("2. Salir")
        option = int(input("Ingrese la opción: "))

        if option == 1:
            send_opcode(STEP_OP)
            data = get_data()
            print_data(data)
        elif option == 2:
            send_opcode(END_DEBUG_OP)
            break
        else:
            print("Opción inválida")

def run_continuous():
    send_opcode(START_CONT_OP)
    data = get_data()
    print_data(data)

def print_data(data):
    print(data)


def get_data():

    # print("waiting for registers")
    reg_data = receive_registers()
    # print(reg_data)
    # print("waiting for IF_ID")
    latch1_data = receive_latch("IF_ID")
    # print(latch1_data)
    # print("waiting for ID_EX")
    latch2_data = receive_latch("ID_EX")
    # print(latch2_data)
    # print("waiting for EX_MEM")
    latch3_data = receive_latch("EX_MEM")
    # print(latch3_data)
    # print("waiting for MEM_WB")
    latch4_data = receive_latch("MEM_WB")
    # print(latch4_data)
    # print("waiting for mem")
    mem_data = receive_mem()
    # print(mem_data)

    registers = decode_registers(reg_data)
    latch1 = decode_latch("IF_ID", latch1_data)
    latch2 = decode_latch("ID_EX", latch2_data)
    latch3 = decode_latch("EX_MEM", latch3_data)    
    latch4 = decode_latch("MEM_WB", latch4_data)
    mem = decode_mem(mem_data)

    data = dict(
        registers = registers,
        if_id = latch1,
        id_ex = latch2,
        ex_mem = latch3,
        mem_wb = latch4,
        mem = mem
    )

    return data


def send_instructions(instructions):
    send_opcode(LOAD_INSTR_OP)
    for instr in instructions:
        instr = instr.to_bytes(1, byteorder='big')
        print("Sending instruction byte: ", instr)
        ser.write(instr)
        recv = ser.read(1)
        print("Received: ", recv)
        if recv != instr:
            print("---------------------------------")
            print("Error sending instruction", instr)
            print("---------------------------------")


def send_opcode(a):
    if (a not in [LOAD_INSTR_OP, START_CONT_OP, START_DEBUG_OP, STEP_OP, END_DEBUG_OP]):
        print("Invalid opcode")
        exit(1)

    # Set operator
    print("Sending opcode: ", a)
    ser.write(a)
    recv = ser.read(1)
    print("Received: ", recv)
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


    data_address = []
    i = 0
    for used in used_mem:
        if used:
            data_address.append(dict(
                data = mem_data[i], 
                address = i*4
            ))
            i += 1

    return data_address

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
                rs=data[8],
                rt=data[9],
                rd=data[10],
                funct=data[11],
                inmediato=int.from_bytes(data[12:16], byteorder='big'),
                opcode=data[16],
                shamt=data[17],
                WB_ctrl=data[18],
                MEM_ctrl=data[19],
                EX_ctrl=data[20]
            )
    elif latch == "EX_MEM":
        return dict(
            latch = "EX_MEM",
            write_reg=data[0],
            data_to_write=int.from_bytes(data[1:5], byteorder='big'),
            ALU_result=int.from_bytes(data[5:9], byteorder='big'),
            WB_ctrl=data[9],
            MEM_ctrl=data[10]
        )
    elif latch == "MEM_WB":
        return dict(
            latch = "MEM_WB",
            ALU_result=int.from_bytes(data[0:4], byteorder='big'),
            read_data_from_mem=int.from_bytes(data[4:8], byteorder='big'),
            write_reg=data[8],
            WB_ctrl=data[9]
        )

    return dict()

if __name__ == "__main__":
    main()

