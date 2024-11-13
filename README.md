# FSM y UART
Diseño e implementación de de un sistema para lograr la comunicación UART entre la ALU y cualquier dispositivo que se quiera comunicar mediante la comunicación serie con la placa Basys 3.

## Desarrollo

### Diagrama en Bloque

<div align="center">
    <img src="https://github.com/user-attachments/assets/4691b615-b10c-4cf9-9f22-297f72ebfdf3" alt="Diagrama en Bloque">
    <p><em>Figura 1: Diagrama en Bloque</em></p>
</div>

### Trama UART

En el estado IDLE de uart, la señal se mantiene en 1, para iniciar una transmisión de datos se envía primero un bit de start en 0. Luego se envían los datos que pueden ser 6, 7 u 8
bits. Finalmente se envían los bits de stop poniendo la señal en 1 por la duración de 1, 1.5 o 2 bits. También se puede utilizar un bit de paridad antes de enviar los bits de stop para
control de errores. 

Tanto el transmisor como el receptor deben estar configurados correctamente antes de
iniciar la comunicación con los parámetros adecuados: baudrate, cantidad de bits de datos,
cantidad de bits de stop y paridad. En este desarrollo se utiliza una trama con 8 bits de
datos, 1 bit de stop y sin bit de paridad.

<div align="center">
    <img src="https://github.com/user-attachments/assets/470c5a82-f112-4114-8bbd-441f5e847ea5" alt="Trama UART">
    <p><em>Figura 2: Trama UART</em></p>
</div>

### Baudrate Generator

El Baud Rate Generator genera una señal de muestreo cuya frecuencia es exactamente 16
veces (factor de sobremuestreo) la velocidad de transmisión designada para UART. Pero
para evitar la creación de un nuevo dominio de reloj y violar el principio de diseño
síncronico, la señal de muestreo debe funcionar como ticks de habilitación en lugar de que
la señal de reloj al receptor UART.
Para 19200 [Baudios], la frecuencia de muestreo sería de 307200 [ticks/seg] (19200 * 16).
Si partimos de un clock de 50MHz, el baud rate generator necesita contar
163 [ciclos de clock] para generar un tick para tomar una muestra. Esto viene de la
siguiente fórmula:

$$\text{Ciclos por tick} = \frac{\text{Clock [Hz]}}{\text{BaudRate} \times 16} \Rightarrow \frac{50 \text{[MHz]}}{19200 \times 16} \approx 163$$

Este sobre muestreo se hace para estimar el punto medio de los bits transmitidos y tomar
estos puntos como muestras. Se usa un factor de sobremuestreo de 16 veces el baud rate.
Que quiere decir que cada bit transmitido es muestreado 16 veces. Al no haber una línea de
clock entre emisor y receptor no se sabe exactamente cuando se transmite el bit pero
gracias al sobremuestreo se tiene una precisión de ± $$\frac{1}{16}$$ .

### UART RX FSM
<div align="center">
    <img src="https://github.com/user-attachments/assets/3cb4a6bc-758f-4ed0-81c5-62689bfc0e54" alt="RX FSM">
    <p><em>Figura 3: RX FSM</em></p>
</div>

### UART TX FSM
<div align="center">
    <img src="https://github.com/user-attachments/assets/f53daec6-9134-4d09-a6b1-d9a7fea201a2" alt="TX FSM">
    <p><em>Figura 4: TX FSM</em></p>
</div>

### UART INTERFACE FSM

La interfaz se encarga de interpretar los datos que llegan por UART para darle sentido en
nuestro sistema particular. Se trabaja también con una máquina de estados que se
comporta según el siguiente diagrama:

<div align="center">
    <img src="https://github.com/user-attachments/assets/2f931908-dfa1-49e4-84d6-67a95c66ecb8" alt="UART INTERFACE FSM">
    <p><em>Figura 5: UART INTERFACE FSM</em></p>
</div>

Se crean 3 estados:
- IDLE_STATE donde se espera por la llegada de un código (OPCODE) que indica
qué campo se quiere cargar en la ALU o si se quiere pedir el resultado de la ALU.
- LOAD_STATE para la carga de valores de la ALU (operación, operador A y operador
B). Aquí se espera la llegada del valor y se carga en el registro correspondiente
asociado a la entrada de la ALU.
- SEND_STATE para enviar el resultado de la ALU o un código de error en caso de
que se haya enviado un valor incorrecto. Aqui unicamente se inicia la transmisión
UART y se vuelve al estado IDLE, no se espera el tx_done dado que el tiempo
requerido para recibir el siguiente comando de transmisión es mayor que el tiempo
que se necesita para enviar el resultado y por lo tanto no habrá conflicto.


## BUILD


