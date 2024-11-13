# MIPS Pipeline Design

This project implements a simplified MIPS processor in Basys3 FPGA as part of *Computer Architecture* final project. 

## Requirements
- Vivado 2023.1
- Node.js
- Python (with pyserial library `pip install pyserial`)

## Build

1. Clone the repo.
2. Create Vivado 2023.1 project for Basys3.
3. Add design sources from `design/`.
4. Add Basys3 constraints `constraints/basys3.xdc`.
5. Execute tcl script `/design/clk_wiz2.tcl` to create clocking wizard block diagram.
6. Generate bitstream.
7. Program FPGA with the generated bitstream.
8. Run user interface:
```sh
cd interfaz
node server.js
```
9. Go to localhost:8080 in your browser

## Screenshots

<div align="center">
    <img src="https://github.com/user-attachments/assets/c99ff35b-d310-440e-9acd-a79256cd366e" alt="Frontend">
    <p><em>Frontend</em></p>
</div>

<div align="center">
    <img src="https://github.com/user-attachments/assets/8446a2bd-a712-4523-92a0-7abf885800c2" alt="Continuous Mode Run">
    <p><em>Continuous Mode Run</em></p>
</div>

## Description

### Pipeline

<div align="center">
    <img src="https://github.com/user-attachments/assets/59575e35-c213-4caa-b2b6-a5a8723bfe47" alt="Pipeline">
    <p><em>Pipeline</em></p>
</div>

### Instructions

| N° Instr | Instrucción | Descripción                   | N° Instr | Instrucción | Descripción                     |
|----------|-------------|-------------------------------|----------|-------------|---------------------------------|
| 1        | ADD         | add                           | 21       | LBU         | load byte unsigned              |
| 2        | SUB         | subtract                      | 22       | LHU         | load halfword unsigned          |
| 3        | SLL         | shift left logical            | 23       | SB          | store byte                      |
| 4        | SRL         | shift right logical           | 24       | SH          | store halfword                  |
| 5        | SRA         | shift right arithmetic        | 25       | SW          | store word                      |
| 6        | SLLV        | shift word left logical variable | 26    | ADDI        | add immediate                   |
| 7        | SRLV        | shift word right logical variable | 27   | ADDIU       | add immediate unsigned word     |
| 8        | SRAV        | shift word right arithmetic variable | 28 | ANDI        | and immediate                   |
| 9        | ADDU        | add unsigned word             | 29       | ORI         | or immediate                    |
| 10       | SUBU        | subtract unsigned word        | 30       | XORI        | exclusive or immediate          |
| 11       | AND         | and                           | 31       | LUI         | load upper immediate            |
| 12       | OR          | or                            | 32       | SLTI        | set on less than immediate      |
| 13       | XOR         | exclusive or                  | 33       | SLTIU       | set on less than immediate unsigned |
| 14       | NOR         | not or                        | 34       | BEQ         | branch on equal                 |
| 15       | SLT         | set on less than              | 35       | BNE         | branch on not equal             |
| 16       | SLTU        | set on less than unsigned     | 36       | J           | jump                            |
| 17       | LB          | load byte                     | 37       | JAL         | jump and link                   |
| 18       | LH          | load halfword                 | 38       | JR          | jump register                   |
| 19       | LW          | load word                     | 39       | JALR        | jump and link register          |
| 20       | LWU         | load word unsigned            | 40       | HALT        | halt                            |

### Modules

The following modules where implemented:
- Instruction Fetch: `design/instruction_fetch.v`
- Instruction Decode: `design/instruction_decode.v`
- Execution: `design/instruction_execute.v`
- Mem Stage: `design/etapa_mem.v`
- Write Back Stage: `design/etapa_wb.v`
- Instructions and Data memory: `design/xilinx_one_port_ram_async.v`
- Register File: `design/banco_registros.v` 
- ALU: `design/alu.v`
- Hazard Detection Unit: `design/unidad_deteccion_riesgos.v`
- Forwarding Unit: `design/unidad_cortocircuito.v`
- Debug Unit (Uart Interface): `design/uart_interface.v`
- PC control: `design/pc_control.v`
- UART TX and RX: `design/uart_rx.v` and `design/uart_tx.v`

