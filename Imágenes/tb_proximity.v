`timescale 1ns/1ps
`include "antirrebote.v"
`include "proximity.v"

module tb_proximity;

// Reducir COUNT para que la simulación termine rápido
parameter COUNT = 5; 

// Declaración de registros 
reg  clk;             
reg  rst;             
reg  sensor_i;        
// Declaración de wire
wire  object; 

// 1. Instanciación del módulo correcto (hm_ir_proximity)
hm_ir_proximity #(
    .COUNT(COUNT)
)
sensor_inst (
    .clk(clk),          // Conexión correcta
    .rst(rst),
    .sensor_i(sensor_i),
    .object(object)
);

// 2. Generador de Reloj 
always #10 clk = ~clk;   // Periodo = 20ns

initial begin
    // Inicialización de las señales de entrada
    clk = 0;
    rst = 1; // Iniciar con reset activo
    sensor_i = 0;

    // Esperar y liberar el reset
    #50;
    rst = 0; 

    // Simulación: Poner objeto y esperar
    sensor_i = 1;

    // Esperar a que el debouncer (5 ciclos) actúe: 5 * 20ns = 100ns
    #200; 

    // Simulación: Quitar objeto y esperar
    sensor_i = 0;

    #200; // Esperar a que el debouncer vuelva a actuar
    
    $finish;
end

initial begin
    $dumpfile("proximity.vcd");
    $dumpvars(0, tb_proximity); // Se suele dumpear el módulo del testbench
end

endmodule