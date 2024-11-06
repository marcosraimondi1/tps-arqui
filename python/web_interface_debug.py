import debugger as deb
import compiler as cp
import argparse

def main():
    parser = argparse.ArgumentParser(description='Debugger')
    parser.add_argument('--port', type=str, help='Puerto serial')
    parser.add_argument('--baudrate', type=int, help='Baudrate')
    parser.add_argument('--loadfile', type=str, help='Enviar archivo a la placa')
    parser.add_argument('--runcontinuous', action='store_true', help='Ejecutar en modo continuo')
    parser.add_argument('--startdebug', action='store_true', help='Ejecutar en modo debug')
    parser.add_argument('--stepdebug', action='store_true', help='Ejecutar en paso en debug')
    parser.add_argument('--stopdebug', action='store_true', help='Detener debug')
    parser.add_argument('--senduart', type=str, help='Enviar byte a la placa')
    parser.add_argument('--health', action='store_true', help='Checkear que anda')

    args = parser.parse_args()

    if args.health:
        print("Debugger listo para ejecutar")
        data = dict(
            registers = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31],
            if_id = dict(
                pc = 0,
                instruction = 0
            ),
            id_ex = dict(
                RA=0,
                RB=0,
                rs=0,
                rt=0,
                rd=0,
                funct=0,
                inmediato=0,
                opcode=0,
                shamt=0,
                WB_ctrl=0,
                MEM_ctrl=0,
                EX_ctrl=0
            ),
            ex_mem = dict(
                write_reg=0,
                data_to_write=0,
                ALU_result=0,
                WB_ctrl=0,
                MEM_ctrl=0
            ),
            mem_wb = dict(
                ALU_result=0,
                read_data_from_mem=0,
                write_reg=0,
                WB_ctrl=0
            ),
            mem = [dict(address=0, data=0),dict(address=4, data=64)]
        )
        deb.write_data(data)
        exit(0)

    ser = deb.open_serial(args.port, args.baudrate)

    try: 
        if args.loadfile:
            asm = cp.Assembler(args.loadfile, "output.hex", True)
            asm.compile()
            deb.send_instructions(asm.byte_code, ser)
        elif args.runcontinuous:
            deb.run_continuous(ser)
        elif args.startdebug:
            deb.debug_start(ser)
        elif args.stepdebug:
            deb.debug_step(ser)
        elif args.stopdebug:
            deb.debug_stop(ser)
        elif args.senduart:
            value = int(args.senduart)
            tosend = value.to_bytes(1, byteorder='big')
            ser.write(tosend)
            print(f"Enviado: {tosend}, Recibido: {ser.read(1)}")
    finally:
        ser.close()

        
if __name__ == '__main__':
    main()
