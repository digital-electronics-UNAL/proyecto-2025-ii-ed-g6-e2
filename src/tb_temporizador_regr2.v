`timescale 1ns/1ps
`include "temporizador_regr2.v"

module tb_timer_2();

    // Señales del TB
    reg clk;
    reg rst_n;
    reg m_state;
    reg motor_on;
    reg sensor_on;
    reg [2:0] porciones;

    wire [5:0] o_seconds;
    wire [5:0] o_minutes;
    wire [6:0] o_hours;
    wire o_m_on;

    // ==== DUT ====
    // CLOCK_FREQ reducido para que la simulación sea rápida
    timer_2 #(
        .CLOCK_FREQ(32'd20),       // <<<< Un "segundo" dura 20 ciclos → 200ns
        .INIT_HORAS(0),
        .INIT_MINUTOS(0),
        .INIT_SEGUNDOS(5)          // temporizador comienza en 5 seg
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .m_state(m_state),
        .motor_on(motor_on),
        .sensor_on(sensor_on),
        .porciones(porciones),
        .o_seconds(o_seconds),
        .o_minutes(o_minutes),
        .o_hours(o_hours),
        .o_m_on(o_m_on)
    );

   
    // ==== Estímulos ====
    initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Limpia el X solo en simulación
initial begin
    force dut.counter_1sec = 0;
    #10;
    release dut.counter_1sec;
end

initial begin
    rst_n = 0;
    m_state = 1;
    motor_on = 1;
    sensor_on = 0;
    porciones = 3;

    #200;      // deja tiempo suficiente
    rst_n = 1;
    #1500;
    rst_n = 0;
    #100;
    rst_n = 1;

    #3000;
    $finish;
end



    // VCD
    initial begin
        $dumpfile("timer_2.vcd");
        $dumpvars(0, tb_timer_2);
    end

endmodule
