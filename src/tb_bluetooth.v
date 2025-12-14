`timescale 1ns/1ps
// Incluir los módulos necesarios
`include "hm-10tx.v" 
`include "hm-text.v" 
`include "hm-controller.v" // Contiene top_bluetooth

module tb_bluetooth;

// Parámetros ajustados para MÁXIMA VELOCIDAD de simulación
parameter CLOCK_FREQ = 32'd25_000_000;   // Reloj de 25 MHz
parameter BAUD       = 32'd12_500_000; // 2 ciclos por bit, CTR_WIDTH será 1
localparam CLK_PERIOD = 1_000_000_000 / CLOCK_FREQ; // 40 ns

// Señales del testbench (entradas)
reg  clk_50mhz;
reg  rst_n;
reg  trigger;

// Señales del testbench (salidas)
wire bt_tx;

// Instanciación del módulo de nivel superior
top_bluetooth #(
    .CLOCK_FREQ(CLOCK_FREQ),
    .BAUD      (BAUD) 
) top_inst (
    .clk_50mhz (clk_50mhz),
    .rst_n     (rst_n),
    .trigger   (trigger),
    .bt_tx     (bt_tx)
);

// Generador de Reloj: Periodo total de 40 ns (20 ns alto, 20 ns bajo)
always #(CLK_PERIOD / 2) clk_50mhz = ~clk_50mhz; 

initial begin
    // Configuración para GTKWave
    $dumpfile("bluetooth.vcd");
    $dumpvars(0, tb_bluetooth);

    // 1. Inicialización y Reset
    clk_50mhz = 0;
    trigger   = 0;
    rst_n     = 0; // Reset Activo 
    
    // Esperar unos ciclos (200 ns)
    #(CLK_PERIOD * 5);
    
    rst_n     = 1; // Liberar Reset

    // 2. Transmisión del Mensaje (Activación del trigger)
    // Se espera 10 ciclos (400 ns) después del reset
    #(CLK_PERIOD * 10);
    trigger = 1;

    // Simular 100 ciclos de reloj (4000 ns) para completar la transmisión rápida
    #(CLK_PERIOD * 100); 

    // 3. Desactivación del trigger (Mueve la FSM a S_IDLE)
    trigger = 0;

    // Esperar un tiempo en IDLE (2000 ns)
    #2000;
    
    // 4. Segunda Transmisión
    trigger = 1;
    // Simular 100 ciclos de reloj (4000 ns)
    #(CLK_PERIOD * 100);
    trigger = 0;

    // 5. Finalización
    // El tiempo total de simulación es aproximadamente 15000 ns, cumpliendo el límite.
    #8000;
    $finish;
end

endmodule