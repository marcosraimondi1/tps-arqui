import time
import serial

BAUDRATE = 19200
PORT = '/dev/ttyUSB1'

ser = serial.Serial(
    port=PORT, 
    baudrate=BAUDRATE,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
)

# send bytes of byte list one by one to the serial port 
for a in range(0, 256):
    to_send = bytes([a])

    while True:
        time.sleep(0.1)
        ser.write(to_send)
        recv = ser.read(1)
        print(f"{a}. {to_send}-{recv}")

        # check if the received byte is the same as the sent byte
        if to_send != recv:
            print(f"Error: received {recv} and expected {to_send}")
        else:
            break


ser.close()

