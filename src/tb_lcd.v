`timescale 1ns/1ps
`include "lcd1602_text.v"


module tb_lcd_controller;


parameter CLOCK_FREQ = 32'd50_000_000;   // 50 MHz (Periodo = 20 ns)
parameter COUNT_MAX  = 32'd50;           // Reducido de 800000 a 50
localparam CLK_PERIOD = 1_000_000_000 / CLOCK_FREQ; // 20 ns

// Entradas del DUT (Registros)
reg clk;            
reg reset;          // Reset, activo en bajo (0) [cite: 25]
reg ready_i;        // Señal de inicio
reg [7:0] time_hours;
reg [7:0] time_minutes;
reg [7:0] time_seconds;
reg [7:0] porciones;

// Salidas del DUT (Wires)
wire rs;
wire rw;
wire enable;
wire [7:0] data;
// Las salidas rs, rw, enable y data permiten verificar la secuencia de comandos y datos.

// Instanciación del controlador
LCD1602_controller #(
    .NUM_COMMANDS(4),
    .NUM_DATA_ALL(32),
    .NUM_DATA_PERLINE(16),
    .DATA_BITS(8),
    .COUNT_MAX(COUNT_MAX)
)
lcd_inst (
    .clk(clk),            
    .reset(reset),          
    .ready_i(ready_i),
    .time_hours(time_hours),
    .time_minutes(time_minutes),
    .time_seconds(time_seconds),
    .porciones(porciones),
    .rs(rs),
    .rw(rw),
    .enable(enable),
    .data(data)
);

// Generador de Reloj (clk)
always #(CLK_PERIOD / 2) clk = ~clk; // Conmutación cada 10 ns (Periodo de 20 ns)

initial begin
    // Configuracion VCD
    $dumpfile("lcd_controller.vcd");
    $dumpvars(0, tb_lcd_controller);

    // 1. Inicialización de Señales
    clk = 0;
    reset = 0; // Reset Activo
    ready_i = 0;
    
    // Datos Dinámicos Iniciales
    time_hours = 8'd10;
    time_minutes = 8'd0;
    time_seconds = 8'd5;
    porciones = 8'd6;

    // 2. Pulso de Reset (5 ciclos = 100 ns)
    #(CLK_PERIOD * 5); 
    reset = 1; // Liberar Reset

    // 3. Inicio de la Secuencia de Configuración
    #(CLK_PERIOD * 10); 
    ready_i = 1; // Activar ready_i (IDLE -> CONFIG_CMD1)

    // 4. Simulación de la Secuencia Estática (4 comandos + 16 datos + 1 comando + 16 datos)
    #(COUNT_MAX * CLK_PERIOD * 50);
    
    // Simular ~20 ciclos de clk_16ms para ver la nueva escritura dinámica (20,000 ns)
    #(COUNT_MAX * CLK_PERIOD * 20); 

    // 6. Desactivar ready_i (aunque la FSM ya no depende de ella)
    ready_i = 0;

    // 7. Finalización de la simulación
    #1000;
    $finish;
end

endmodule