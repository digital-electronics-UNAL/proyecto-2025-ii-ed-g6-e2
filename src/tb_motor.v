`timescale 1ns/1ps
`include "motor.v"
`include "div_m.v"

module tb_motor;

reg clk_1;
reg motor_activo;
wire [3:0] M;

motor dut (
    .clk_1(clk_1),
    .motor_activo(motor_activo),
    .M(M)
);


always #10 clk_1 = ~clk_1;   // Periodo = 20ns

initial begin
    $dumpfile("motor.vcd");
    $dumpvars(0, tb_motor);
end
 
initial begin
    clk_1 = 0;
    motor_activo = 0;

    // Esperar un poco
    #50;

    // Activar motor
    motor_activo = 1;

    // Dejar que gire varias vueltas
    #500;

    // Detener motor
    motor_activo = 0;

    #200;
    $finish;
end

endmodule
