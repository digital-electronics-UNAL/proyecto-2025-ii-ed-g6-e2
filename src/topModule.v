module topModule #(
parameter [9:0] INIT_CICLOSM_T= 10'd683,//683 para que de un giro de 60°)
parameter CLOCK_FREQ_T = 32'd50_000_000, // 50MHz frecuencia del reloj de la FPGA
  //Parámetros configurables del contador regresivo
parameter [5:0] INIT_HORAS_T   = 6'd0,
parameter [5:0] INIT_MINUTOS_T = 6'd0,
parameter [5:0] INIT_SEGUNDOS_T = 6'd5
)

(
    input clk,
    input rst_n,
    output [3:0] M,

    // --- PUERTOS PARA EL LCD ---
    output rs,
    output rw,
    output enable,
    output [7:0] data,

    // --- PUERTOS PROXIMIDAD ---
    input  sensor_i,

    // --- PUERTO BLUETOOTH (UART TX) ---
    output bt_tx
);

wire led;
wire object_sensor;
wire [2:0] porciones_f;
wire [5:0] segundos;
wire [5:0] minutos;
wire [6:0] horas;
wire no_porciones = (porciones_f == 3'd0);
parameter [3:0] INIT_MOTOR   = 4'b0000;
parameter [2:0] INIT_PORCIONES = 3'd6;

wire clk_1;
div_m div(.clk(clk), .clk_1(clk_1));// usar el modulo div_m para obtener la nueva frecuancia para mover el motor

wire [3:0] M_seq;
reg [9:0] ciclos_motor = 0;
reg motor_activo = 0;
reg m_state = 0;
reg [2:0] porciones;

// Instancia del temporizador
timer_2 #(
    .CLOCK_FREQ(CLOCK_FREQ_T),
    .INIT_HORAS(INIT_HORAS_T),
    .INIT_MINUTOS(INIT_MINUTOS_T),
    .INIT_SEGUNDOS(INIT_SEGUNDOS_T)
)
timer(
    .clk(clk),
    .rst_n(rst_n),
    .o_seconds(segundos),
    .o_minutes(minutos),
    .o_hours(horas),
    .o_m_on(m_on),
    .m_state(m_state),
    .porciones(no_porciones),
    .motor_on(~motor_activo),
    .sensor_on(~object_sensor)
);

hm_ir_proximity #(
    .ACTIVE(1),
    .COUNT(5000)
) proximity (
    .clk(clk),
    .rst(rst_n),
    .sensor_i(sensor_i),
    .object(object_sensor)
);


always @(posedge clk_1 or negedge rst_n) begin
    if (!rst_n)begin
        porciones <= INIT_PORCIONES;
    end else begin
        if (m_on == 0) begin
            m_state <= 0;
        end
        if (m_on == 1 && m_state == 0 && porciones != 0 && object_sensor== 1) begin
            motor_activo <= 1'b1;
            m_state <= 1'b1;
            porciones <= porciones -1'b1;
        end
        if (motor_activo == 1) begin
            if (ciclos_motor < INIT_CICLOSM_T)begin
                ciclos_motor <= ciclos_motor + 1'b1;
            end else begin
                motor_activo <= 1'b0;
                m_state <= 1'b0;
                ciclos_motor <= 0;
            end
        end
    end
end


motor motor_inst(.clk_1(clk_1), .motor_activo(motor_activo), .M(M_seq));

assign M = (motor_activo) ? M_seq : INIT_MOTOR;
assign led = motor_activo;

LCD1602_controller lcd_inst (.clk(clk), .reset(rst_n), .ready_i(1'b1), .time_hours(horas), .time_minutes(minutos), .time_seconds(segundos), .porciones(porciones),     
.rs(rs), .rw(rw), .enable(enable), .data(data));
assign porciones_f = porciones;

top_bluetooth bluetooth_inst (
    .clk_50mhz (clk),
    .rst_n     (rst_n),
    .trigger   (no_porciones), // cuando porciones == 0
    .bt_tx     (bt_tx)         // sale a la FPGA y de ahí al RX del HM-10
);



endmodule

