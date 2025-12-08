[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=21886521&assignment_repo_type=AssignmentRepo)
# Proyecto final - Electrónica Digital 1 - 2025-II

# Integrantes

Paulina Jimenez Vargas (pajimenezv@unal.edu.co)

Alina Idaly Ortiz Martinez (alortizma@unal.edu.co)

Jana Rubiano Hurtado (jrubianoh@unal.edu.co)

# Nutripet

Hoy en día es normal tener todo tipo de mascotas en el hogar; sin embargo, las personas tienden a estar fuera de casa debido a horarios laborales u ocupaciones a lo largo del día, lo cual conlleva a que satisfacer las necesidades de las mascotas sea un reto, ya que muchas de ellas requieren alimentación constante. 

En muchas ocasiones, el dejar la comida del animal expuesta al aire puede suponer un riesgo debido a insectos, contaminación y deterioro del alimento.

El objetivo principal del proyecto es diseñar un sistema capaz de controlar la dispensación de alimento de forma automática, empleando módulos digitales descritos en Verilog que gestionan sensores, temporizadores y el control de un motor que se encargará de girar el dispositivo para entregar la comida del animal.

# Documentación
# Prototipo físico 
Se llevó a cabo el diseño y la impresión del siguiente diseño.
<p align="center">
  <img src="Images/Dseño fisico.jpg" width="600">
</p>





## Diagrama de bloques 
<p align="center">
  <img src="Images/Diagrama de bloques.png" width="700">
</p>


La arquirectura del sistema esta basada en la la tarjeta de desarrollo Cyclone IV, la cual contiene una FPGA. Esta se encarga de coordinar la lógica del dispensador automatico mediante tres bloques internos, los cuales son el temporizador, el contador de porciones y el módulo de interacción entre los sensores y componentes externos. 

La FPGA recibe información de un sensor de proximidad, controla el motor paso a paso mediante un drives y actualiza la pantalla LCD mediante texto dinámico continuamente con la información proveniente tanto del temporizador como del contador de porciones. Si el animal se encuentra muy cerca del dispensador, la tapa no se moverá y el temporizador no seguirá contando hasta que se retire. Por último el dispensador enviará un mensaje por medio de bluetooth cuando se acaben las porciones.


## Elementos incorporados.
### Temporizador.
### Contador de porciones.
### Sensor de proximidad.
### Modulo bluetooth.

## Justificación de diseño. 

En el caso de varios de los elementos, se decidió utilizar un clock independiente, que si bien está basado en el de 50 MHz de la FPGA, no dependen directamente de esta. Esto debido a que en algunos casos se necesitó una frecuencia diferente para que los elementos funcionaran (Por esto el divisor de frecuencia.)


## Arquitectura interna.

Para la realización del proyecto, se emplearon diversos recursos típicos de la descripción de hardware, incluyendo lógica combinacional (como multiplexores y compuertas), descripción comportamental mediante bloques always, estructuras de control similares a las de la programación clásica (como if) y componentes más avanzados como máquinas de estado y módulos que implementan protocolos de comunicación.


### Maquinas de estado. 

Se utilizaron maquinas de estado tanto para la LCD como para el modulo bluetooth.

Para la LCD, 
<p align="center">
  <img src="Images/Maquina LCD.jpg" width="600">
</p>

La máquina de estados controla paso a paso lo que la pantalla LCD debe hacer. Primero, cuando el sistema enciende o se reinicia, todo comienza en el estado IDLE, que es simplemente una espera inicial. Cuando la LCD está lista, la máquina avanza y envía una serie de comandos de configuración necesarios para dejar la pantalla lista para usar.

Después de configurar la LCD, la máquina escribe un texto fijo en la primera línea y luego en la segunda línea. Una vez termina esa etapa, pasa al último estado, donde se encarga de actualizar continuamente la información dinámica en pantalla, cambiando constantemente la hora y el número de porciones restantes.

En caso de ocurrir un reset, la máquina vuelve directamente al estado inicial (IDLE), sin importar en qué parte del proceso se encuent


Para el modulo bluetooth se utilizó la siguiente maquina de estados.
<p align="center">
  <img src="Images/Maquina bluetooth.jpg" width="170">
</p>
La función de esta es esperar la señal para cargar el mensaje, enviarlo y volver a esperar el mensaje.

### Protocolos 

Los protocolos juegan un papel bastante importante en la organización de comunicación entre los dispositivos, y se diseñan de diferentes maneras segun los requisitos y usos del sistema. 

Los microcontroladores, sistemas integrados y computadores utilizan principalmente el protocolo UART, el cual se especializa en la comunicación serial asincróna.

Las señales de UART son el transmisor (Tx) y el receptor (Rx), para asi enviar y recibir datos en serie. 

La transmisión de datos se realiza en forma de paquetes seriales, que constan de un bit de inicio, datos, un bit de paridad y bits de parada.

<p align="center">
  <img src="Images/UART.svg" width="500">
</p>

En el caso del proyecto, este protocolo fue aplicado para la transmisión de datos por bluetooth. En el modulo de "uart_tx" se puede observar que se siguen todos los pasos de la imagen anterior, enviando los datos uno tras otro a una determinada velocidad. El modulo recibe un dato, lo convierte a  un paquete de datos UART y lo envia bit por bit a la linea de salida.

## Simulaciones


## Evidencias de implementación

## Referencias.

[1] PlantUML, “Online UML Diagram Generator.” Disponible en: https://www.plantuml.com/plantuml/uml/SyfFKj2rKt3CoKnELR1Io4ZDoSa70000  

[2] Analog Devices, “UART: A Hardware Communication Protocol,” *Analog Dialogue*. Disponible en: https://www.analog.com/en/resources/analog-dialogue/articles/uart-a-hardware-communication-protocol.html
