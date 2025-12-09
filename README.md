[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=21886521&assignment_repo_type=AssignmentRepo)
# Proyecto final - Electrónica Digital 1 - 2025-II

# Integrantes


# Nombre del proyecto



# Documentación
# Prototipo físico

## Elementos incorporados.

### Temporizador.
### Motor.
### Contador de porciones.
### Sensor de proximidad.

El primer diagrama es el detalle interno del módulo, mientras que el segundo muestra su uso externo. La salida del módulo, generada a partir del contador y el comparador, se toma como señal limpia y se almacena en otro registro para que el resto del sistema la utilice. Todo el procesamiento interno queda oculto cuando el módulo se integra.

<p align="center">
  <img src="Imágenes/antirrebote.png" alt="Diagrama de circuito del antirrebote" width=100%/>
  <br>
  <em>Diagrama de circuito del antirrebote.</em>
</p>

El primer diagrama muestra los componentes que forman el módulo del antirrebote. Primero aparece un registro (btn_sync) que sincroniza la entrada con el reloj del sistema. Desde ahí, la señal pasa a una pequeña lógica combinacional que controla un contador. El contador está formado por un sumador de 13 bits y un registro, donde el sumador calcula el siguiente valor y el registro lo almacena en cada ciclo de reloj. Un comparador digital verifica cuando el contador llega a un valor establecido, y cuando esto ocurre activa la señal interna que define la salida. Esta señal se guarda en un registro final (clean_reg), que entrega un resultado estable y alineado al reloj. Compuesto principalmente por un registro de entrada, un contador con comparador y un registro de salida.

<p align="center">
  <img src="Imágenes/infrarrojo.png" alt="Diagrama de circuito del sensor infrarrojo" width=100%/>
  <br>
  <em>Diagrama de circuito del sensor infrarrojo.</em>
</p>

En el segundo diagrama, el módulo anterior aparece integrado como un bloque completo con nombre debouncer_inst. Solo se muestran sus puertos: la entrada, el reloj y su salida limpia. La salida del módulo pasa por un multiplexor que selecciona la señal a utilizar y luego entra a un registro que guarda el valor final. Aquí ya no se ven los componentes internos, porque todo está encapsulado dentro del módulo, y solo se usa su resultado. Por lo que el diagrama muestra cómo el módulo se conecta con el resto del circuito mediante elementos simples como un multiplexor y un registro.

### Modulo bluetooth.

## Descripción de la arquitectura


## Diagramas de la arquitectura


## Simulaciones


## Evidencias de implementación

