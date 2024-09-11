# Trabajo Practico 1

## Integrantes
- [Giuliano M. Palombarini](giuli2803@gmail.com)
- [Marcos Raimondi](marcosraimondi1@mi.unc.edu.ar)

## Consigna

1. Implementar en FPGA una ALU. 
2. La ALU debe ser parametrizable (bus de datos) para poder ser utilizada posteriormente en el trabajo final.
3. Validar el desarrollo por medio de un Test Bench:
    - El testbench debe incluir generacion de entradas aleatorias y codigo de chequeo automatico.
4. Simular el diseno usando las herramientas de simulacion de vivado incluyendo analisis de tiempo.

## Diagrama en bloque del sistema

![image](https://github.com/user-attachments/assets/6de57965-78a2-4e1a-95e7-16b5e7db0c3d)

## Operaciones de la ALU

Operación | Código
--- | ---
ADD | 100000
SUB | 100010
AND | 100100
OR  | 100101
XOR | 100110
SRA | 000011
SRL | 000010
NOR | 100111


