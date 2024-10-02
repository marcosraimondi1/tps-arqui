import time
import serial
import random

BAUDRATE = 19200
PORT = '/dev/ttyUSB1'

ser = serial.Serial(
    port=PORT, 
    baudrate=BAUDRATE,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
)

# ALU commands
ALU_DATA_A_OP = bytes([0b00000000])
ALU_DATA_B_OP = bytes([0b00000001])
GET_RESULT_OP = bytes([0b00000010])
ALU_OPERATOR_OP = bytes([0b00000011])

# ALU operations
ADD_OP = bytes([0b00100000])
SUB_OP = bytes([0b00100010])
AND_OP = bytes([0b00100100])
OR_OP = bytes([0b00100101])
XOR_OP = bytes([0b00100110])
SRA_OP = bytes([0b00000011])
SRL_OP = bytes([0b00000010])
NOR_OP = bytes([0b00100111])

# Error Codes
ALU_OPERATOR_ERROR = bytes([0xa1])
INVALID_OPCODE = bytes([0xff])

random.seed(0)

# Function to send data to ALU and get the result
def get_value_alu_test(operator, a_value, b_value):
    # Set operator
    ser.write(ALU_OPERATOR_OP)
    # time.sleep(0.1)
    ser.write(operator)
    # time.sleep(0.1)
    
    # Send first operand (A)
    ser.write(ALU_DATA_A_OP)
    # time.sleep(0.1)
    ser.write(bytes([a_value]))
    # time.sleep(0.1)
    
    # Send second operand (B)
    ser.write(ALU_DATA_B_OP)
    # time.sleep(0.1)
    ser.write(bytes([b_value]))
    # time.sleep(0.1)
    
    # Request result
    ser.write(GET_RESULT_OP)
    # time.sleep(0.1)
    
    # Receive result
    recv = ser.read(1)
    return recv

# Test all operations
def test_all_operations():

    test_cases = [
        # test ID, operator, valueA, valueB, expected result
        # ("ADD", ADD_OP, 3, 2, 5),
        # ("SUB", SUB_OP, 3, 2, 1),
        # ("AND", AND_OP, 3, 2, 2),
        # ("OR", OR_OP, 3, 2, 3),
        # ("XOR", XOR_OP, 3, 2, 1),
        # ("SRA", SRA_OP, 3, 1, 1),
        # ("SRL", SRL_OP, 4, 1, 2),
        # ("NOR", NOR_OP, 3, 2, 252),
    ]

    for i in range(100):
        a_val = random.randint(0, 255)
        b_val = random.randint(0, 255)
        test_cases.append((f"ADD[{i}]", ADD_OP, a_val, b_val, (a_val + b_val) % 256))

    for i in range(100):
        a_val = random.randint(0, 255)
        b_val = random.randint(0, 255)
        test_cases.append((f"AND[{i}]", AND_OP, a_val, b_val, (a_val & b_val)))

    for i in range(100):
        a_val = random.randint(0, 255)
        b_val = random.randint(0, 255)
        test_cases.append((f"OR[{i}]", OR_OP, a_val, b_val, (a_val | b_val)))

    for i in range(100):
        a_val = random.randint(0, 255)
        b_val = random.randint(0, 255)
        test_cases.append((f"NOR[{i}]", NOR_OP, a_val, b_val, ~(a_val | b_val) % 256))

    for i in range(100):
        a_val = random.randint(0, 255)
        b_val = random.randint(0, 255)
        test_cases.append((f"XOR[{i}]", XOR_OP, a_val, b_val, (a_val ^ b_val) % 256))

    for i in range(100):
        a_val = random.randint(0, 255)
        b_val = random.randint(0, 10)
        test_cases.append((f"SRL[{i}]", SRL_OP, a_val, b_val, (a_val >> b_val) % 256))

    for i in range(100):
        a_val = random.randint(0, 255)
        b_val = random.randint(0, 255)
        test_cases.append((f"SUB[{i}]", SUB_OP, a_val, b_val, (a_val - b_val) % 256))

    for test_id, operator, a_value, b_value, expected in test_cases:
        print(f"Testing {test_id}: {a_value} {test_id} {b_value} = {expected}")
        val = get_value_alu_test(operator, a_value, b_value)

        try:
            assert(val == bytes([expected]))
        except AssertionError:
            print(f"Test {test_id} failed: expected {expected}, got {val}")
            if (val == ALU_OPERATOR_ERROR):
                print("ALU operator error")
            elif (val == INVALID_OPCODE):
                print("Invalid opcode")
            else:
                print("Unknown error")
            print("=================")
            return

# Run all tests
test_all_operations()

ser.close()
