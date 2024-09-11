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

## Implementación

Se desarrollan 2 modulos, uno para la ALU y otro para el top el cual implementa una ALU. 

### ALU
La ALU (Unidad Aritmetico Logica) es un circuito digital que realiza operaciones aritmeticas y logicas 
y se implementa de manera puramente combinacional. 

En este caso, se implementan las operaciones de suma, resta, and, or, xor, sra (desplazamiento hacia la derecha aritmetico), 
srl (desplazamiento hacia la derecha logico) y nor.

Se utilizan parametros para definir el tamaño de los buses de entrada y salida, y para definir el tamaño de los registros internos. 
De forma que el modulo sea parametrizable.

Tiene su respectivo testbench que se encarga de verificar que las operaciones se realicen correctamente.


### TOP
El top es el modulo que implementa la ALU y se encarga de recibir los datos de entrada y la operacion a realizar, y mostrar el resultado.
Las entradas provienen de 8 switches de la FPGA. Con 3 botones se carga el valor de los switches a las entradas A, B y el codigo del operador.
La salida de la ALU se muestra en 8 leds de la FPGA.

Se agrega un boton mas para el reset del sistema y un led mas para mostrar el estado del reset y que sirva para verificar que el sistema esta funcionando.

Las entradas se cargan en registros los cuales se conectan a la ALU. La salida de la ALU se conecta directamente a los leds.

```verilog
  always @(posedge i_clk) begin
    if (i_reset) 
        alu_op <= {(NB_OP) {1'b0}};
    else if (i_btn[2]) 
        alu_op <= i_sw[NB_OP-1:0];
  end
```

Para mapear las entradas y salidas del modulo top a pines de la FPGA que esten conectados a los componentes de interes se utiliza un archivo de constraint `.xdc`:
```
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports { o_led[0] }];
```

En la documentacion de la placa FPGA utilizada (la Basys 3), se obtienen estos valores. Los mismos tambien se observan escritas sobre la placa.

![basys3](https://digilent.com/reference/_media/basys3-frontbackviews.jpg)
