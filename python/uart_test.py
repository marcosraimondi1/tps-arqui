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
    send = bytes([a])
    ser.write(send)
    recv = ser.read(1)

    print(f"{a}. {send}-{recv}")

    # check if the received byte is the same as the sent byte
    if send != recv:
        print(f"Error: received {recv} and expected {send}")
        break

    time.sleep(0.1)

ser.close()

