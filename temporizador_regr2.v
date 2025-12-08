
module timer_2#(
parameter CLOCK_FREQ = 32'd50_000_000, // 50MHz frecuencia del reloj de la FPGA

//Parámetros configurables del contador regresivo
parameter [5:0] INIT_HORAS   = 6'd0,
parameter [5:0] INIT_MINUTOS = 6'd0,
parameter [5:0] INIT_SEGUNDOS = 6'd10
) 

(
    // Puertos
    input clk,
    input rst_n,
    input m_state,
    input motor_on,
    input sensor_on,
    input [2:0] porciones,
    output [5:0] o_seconds, // 0–59 segundos
    output [5:0] o_minutes, // 0–59 minutos
    output [6:0] o_hours,    // 0–99 horas 
    output o_m_on

);

localparam ONE_SECOND = CLOCK_FREQ - 1; // Número de ciclos del reloj equivalentes a un segundo

// Lógica interna
reg [5:0] seconds_cnt;  // 0–59 segundos
reg [5:0] minutes_cnt;  // 0–59 minutos
reg [6:0] hours_cnt;    // 0–99 horas (8’d99 es el valor más grande que se puede representar en 7 segementos)
reg [31:0] counter_1sec; // cuenta cada ciclo del reloj (max valor 2**32 > 4.2bln)
reg m_on = 0;

// Código para el temporizador
always @(posedge clk or negedge rst_n) // Si el pin no tiene lógica negada entonces cambiar el negedge por posedge y el if(!rst_n) por if(rst)
begin
    if(!rst_n) begin
        seconds_cnt  <= INIT_SEGUNDOS;
        minutes_cnt  <= INIT_MINUTOS;
        hours_cnt    <= INIT_HORAS;
        m_on <= 1'b0;
    end else begin
        if (m_state == 1)begin
            m_on <= 0;
        end
        //Bloque del temporizador
        if (counter_1sec >= ONE_SECOND && (motor_on == 1'b1 ^ sensor_on == 1'b1) )begin
            counter_1sec <= 0;

            if (seconds_cnt == 0) begin // decrementa el contador de segundos
                seconds_cnt <= 6'd59;

                if (minutes_cnt == 0) begin // decrementa el contador de minutos
                    minutes_cnt <= 6'd59;

                    if (hours_cnt == 0) begin
                        if (porciones) begin
                            // NO reiniciar
                            seconds_cnt <= 0;
                            minutes_cnt <= 0;
                            hours_cnt   <= 0;
                            m_on <= 0;
                        end else begin
                            // Reinicio normal
                            seconds_cnt  <= INIT_SEGUNDOS;
                            minutes_cnt  <= INIT_MINUTOS;
                            hours_cnt    <= INIT_HORAS;
                            m_on <= 1'b1;
                        end

                    end else begin
                        hours_cnt <= hours_cnt - 1'b1;
                    end

                end else begin
                    minutes_cnt <= minutes_cnt - 1'b1;
                end

            end else begin
                seconds_cnt <= seconds_cnt - 1'b1;
            end

        end else begin
            counter_1sec <= counter_1sec + 1'b1;
        end
    end
end



// Output assignments
assign o_seconds = seconds_cnt;
assign o_minutes = minutes_cnt;
assign o_hours   = hours_cnt;
assign o_m_on = m_on;
endmodule

