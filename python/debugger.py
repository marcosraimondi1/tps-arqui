import datetime
import json
import serial
import compiler as cp
import pprint

BAUDRATE = 19200
PORT = '/dev/ttyUSB1'

LOAD_INSTR_OP = bytes([0b00000000]);
START_CONT_OP = bytes([0b00000001]);
START_DEBUG_OP = bytes([0b00000010]);
STEP_OP = bytes([0b00000011]);
END_DEBUG_OP = bytes([0b00000100]);

def main():

    # enviar instrucciones
    ser = open_serial(PORT, BAUDRATE)

    try:
        while True:
            print("1. Cargar instrucciones")
            print("2. Iniciar ejecución continua")
            print("3. Iniciar ejecución paso a paso")
            print("4. Salir")
            print("5. Test Uart")
            print("6. Run Tests")
            option = int(input("Ingrese la opción: "))

            if option == 1:
                path = input("Seleccione el archivo a cargar (path): ")
                asm = cp.Assembler(path, "output.hex", True)
                asm.compile()
                send_instructions(asm.byte_code, ser)
            elif option == 2:
                run_continuous(ser)
            elif option == 3:
                run_debug(ser)
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

            elif option == 6:
                run_tests(ser)

            else:
                print("Opción inválida")

    except Exception as e:
        print("Error: ", e)
    finally:
        ser.close()

def run_tests(ser):

    print("Running tests")

    i = 1
    while True: 
        test_dir = f"tests/test{i}"
        test_instructions = test_dir + f"/test{i}.asm"
        test_expected_results = test_dir + f"/test{i}.json"

        asm = cp.Assembler(test_instructions, test_dir + f"/test{i}.hex", True)

        if not asm.compile():
            # file not found
            break
                
        send_instructions(asm.byte_code, ser)

        send_opcode(START_CONT_OP, ser)
        data = get_data(ser)
        write_data(data, test_dir + f"/test{i}_results.json")

        expected_data = dict()
        try:
            with open(test_expected_results, "r") as file:
                expected_data = json.load(file)
        except Exception as e:
            print("Error reading expected results: ", e)
            break

        # compare registers
        for i in range(0, 32):
            if data["registers"][i] != expected_data["registers"][i]:
                print(f"Error in register {i}: {data['registers'][i]} != {expected_data['registers'][i]}")

        # compare used memory
        mem_data = data["mem"]
        if (len(mem_data) != len(expected_data["mem"])):
            print("Error: Memory data length is not consistent")
            print(f"len(mem_data): {len(mem_data)} != len(expected_data['mem']): {len(expected_data['mem'])}")

        for i in range(0, len(mem_data)):
            if mem_data[i]["address"] != expected_data["mem"][i]["address"]:
                print(f"Error in memory address {i}: {mem_data[i]['address']} != {expected_data['mem'][i]['address']}")

            if mem_data[i]["data"] != expected_data["mem"][i]["data"]:
                print(f"Error in memory address {mem_data[i]['address']}: {mem_data[i]['data']} != {expected_data['mem'][i]['data']}")

        i += 1
    print(f"Finished running {i-1} tests")


def open_serial(port, baudrate):
    try:
        ser = serial.Serial(
            port=port, 
            baudrate=baudrate,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            bytesize=serial.EIGHTBITS,
        )
    except Exception as e:
        print("Error opening serial port: ", e)
        exit(1)

    return ser

def run_debug(ser):
    debug_start(ser)

    while True:
        print("1. Step")
        print("2. Salir")
        option = int(input("Ingrese la opción: "))

        if option == 1:
            debug_step(ser)
        elif option == 2:
            debug_stop(ser)
            break
        else:
            print("Opción inválida")

def debug_start(ser):
    send_opcode(START_DEBUG_OP, ser)

def debug_step(ser):
    send_opcode(STEP_OP, ser)
    data = get_data(ser)
    print_data(data)
    write_data(data)

def debug_stop(ser):
    send_opcode(END_DEBUG_OP, ser)

def run_continuous(ser):
    send_opcode(START_CONT_OP, ser)
    data = get_data(ser)
    print_data(data)
    write_data(data)

def print_data(data):
    pprint.pprint(data)

def write_data(data, output="data.json"):
    data["datetime"] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(output, "w") as file:
        json.dump(data, file, indent=4)

def get_data(ser)->dict:

    # print("waiting for registers")
    reg_data = receive_registers(ser)
    # print(reg_data)
    # print("waiting for IF_ID")
    latch1_data = receive_latch("IF_ID", ser)
    # print(latch1_data)
    # print("waiting for ID_EX")
    latch2_data = receive_latch("ID_EX", ser)
    # print(latch2_data)
    # print("waiting for EX_MEM")
    latch3_data = receive_latch("EX_MEM", ser)
    # print(latch3_data)
    # print("waiting for MEM_WB")
    latch4_data = receive_latch("MEM_WB", ser)
    # print(latch4_data)
    # print("waiting for mem")
    mem_data = receive_mem(ser)
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


def send_instructions(instructions, ser):
    send_opcode(LOAD_INSTR_OP, ser)
    print("Sending instructions")
    for instr in instructions:
        instr = instr.to_bytes(1, byteorder='big')
        ser.write(instr)
        recv = ser.read(1)
        if recv != instr:
            print("---------------------------------")
            print("Error sending instruction", instr)
            print("---------------------------------")


def send_opcode(op, ser):
    if (op not in [LOAD_INSTR_OP, START_CONT_OP, START_DEBUG_OP, STEP_OP, END_DEBUG_OP]):
        print("Invalid opcode")
        exit(1)

    # Set operator
    print("Sending opcode: ", op)
    ser.write(op)
    recv = ser.read(1)
    print("Received: ", recv)
    return recv

MEM_SIZE=256 # memoria de 256 bytes (4 bytes es un dato)
USED_MEM_ARRAY_LEN=8 # 1 bit por cada dato

def receive_mem(ser):
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

    used_mem = used_mem[::-1]

    if (sum(used_mem) != len(mem_data)):
        print("Error: used_mem array is not consistent with the data")
        print("used_mem: ", used_mem)
        print("mem_data: ", mem_data)

    data_address = []
    i = 0
    addr = 0
    for used in used_mem:
        if used:
            data_address.append(dict(
                data = mem_data[i], 
                address = addr
            ))
            i += 1
        addr += 4

    return data_address

def receive_registers(ser):
    recv = ser.read(32*4)
    return recv

def decode_registers(data):
    registers = []
    for i in range(0, 32):
        registers.append(int.from_bytes(data[i*4:i*4+4], byteorder='big'))
    return registers
    

def receive_latch(latch, ser):
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
            instruction = int.from_bytes(data[0:4], byteorder='big'),
            pc4 = int.from_bytes(data[4:8], byteorder='big')
        )
    elif latch == "ID_EX":
        return dict(
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
            write_reg=data[0],
            data_to_write=int.from_bytes(data[1:5], byteorder='big'),
            ALU_result=int.from_bytes(data[5:9], byteorder='big'),
            WB_ctrl=data[9],
            MEM_ctrl=data[10]
        )
    elif latch == "MEM_WB":
        return dict(
            ALU_result=int.from_bytes(data[0:4], byteorder='big'),
            read_data_from_mem=int.from_bytes(data[4:8], byteorder='big'),
            write_reg=data[8],
            WB_ctrl=data[9]
        )

    return dict()

if __name__ == "__main__":
    main()

