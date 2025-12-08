module LCD1602_controller #(parameter NUM_COMMANDS = 4, 
                                      NUM_DATA_ALL = 32,  
                                      NUM_DATA_PERLINE = 16,
                                      DATA_BITS = 8,
                                      COUNT_MAX = 800000)(
    input clk,            
    input reset,          
    input ready_i,

    input [DATA_BITS-1:0] time_hours,
    input [DATA_BITS-1:0] time_minutes,
    input [DATA_BITS-1:0] time_seconds,
    input [DATA_BITS-1:0] porciones,

    output reg rs,
    output reg rw,
    output enable,
    output reg [DATA_BITS-1:0] data
);

// Definir los estados de la FSM - Condiciones iniciales
localparam IDLE              = 3'b000;
localparam CONFIG_CMD1       = 3'b001;
localparam WR_STATIC_TEXT_1L = 3'b010;
localparam CONFIG_CMD2       = 3'b011;
localparam WR_STATIC_TEXT_2L = 3'b100;
localparam WRITE_DYNAMIC_TEXT = 3'b101;
localparam SET_COURSOR = 4'd0;

reg [2:0] fsm_state;
reg [2:0] next_state;
reg clk_16ms;
reg [3:0] sel_dynamic_state;
reg sel_use_coursor;

// Comandos de configuración
localparam CLEAR_DISPLAY = 8'h01;
localparam SHIFT_CURSOR_RIGHT = 8'h06;
localparam DISPON_CURSOROFF = 8'h0C;
localparam DISPON_CURSORBLINK = 8'h0E;
localparam LINES2_MATRIX5x8_MODE8bit = 8'h38;
localparam START_2LINE = 8'hC0;

// Definir un contador para el divisor de frecuencia
reg [$clog2(COUNT_MAX)-1:0] clk_counter;
// Definir un contador para controlar el envío de comandos
reg [$clog2(NUM_COMMANDS):0] command_counter;
// Definir un contador para controlar el envío de datos
reg [$clog2(NUM_DATA_PERLINE):0] data_counter;

// Banco de registros
reg [DATA_BITS-1:0] static_data_mem [0:NUM_DATA_ALL-1];
reg [DATA_BITS-1:0] config_mem [0:NUM_COMMANDS-1];
reg [DATA_BITS-1:0] coursor_data [0:1];

// Datos dinámicos
reg [7:0] dyn_hours;
reg [7:0] dyn_minutes;
reg [7:0] dyn_seconds;
reg [7:0] dyn_porciones;

initial begin
    fsm_state <= IDLE; //Que fue el que se definió antes, es 0
    coursor_data[0] <= 8'h80 + 8'h08; 
    coursor_data[1] <= 8'hC0 + 8'h0d; 
    sel_dynamic_state <= SET_COURSOR;
    command_counter <= 0;
    data_counter <= 0;
    rs <= 0;
    rw <= 0;
    data <= 0;
    clk_16ms <= 0;
    clk_counter <= 0;
    sel_use_coursor <= 0;
    $readmemh("/home/paulina/Descargas/temp_motor2/data.txt", static_data_mem);
    config_mem[0] <= LINES2_MATRIX5x8_MODE8bit;
	config_mem[1] <= SHIFT_CURSOR_RIGHT;
	config_mem[2] <= DISPON_CURSOROFF;
	config_mem[3] <= CLEAR_DISPLAY;
end

always @(posedge clk) begin
    if (clk_counter == COUNT_MAX-1) begin
        clk_16ms <= ~clk_16ms;
        clk_counter <= 0;
    end else begin
        clk_counter <= clk_counter + 1;
    end
end

// Aqui se empieza a definir la maquina de estados

always @(posedge clk_16ms)begin
    if(reset == 0)begin     // Por la lógica negada de la fpga 
        fsm_state <= IDLE;
    end else begin
        fsm_state <= next_state; 
    end
end

always @(*) begin // No depende de una señal de reloj, combinacional 
    case(fsm_state)  // Se implementa un multiplexor.
        IDLE: begin
            next_state <= (ready_i)? CONFIG_CMD1 : IDLE;
        end
        CONFIG_CMD1: begin 
            next_state <= (command_counter == NUM_COMMANDS)? WR_STATIC_TEXT_1L : CONFIG_CMD1;
        end
        WR_STATIC_TEXT_1L:begin
			next_state <= (data_counter == NUM_DATA_PERLINE)? CONFIG_CMD2 : WR_STATIC_TEXT_1L;
        end
        CONFIG_CMD2: begin 
            next_state <= WR_STATIC_TEXT_2L;
        end
		WR_STATIC_TEXT_2L: begin
			next_state <= (data_counter == NUM_DATA_PERLINE)? WRITE_DYNAMIC_TEXT : WR_STATIC_TEXT_2L;
		end
        default: next_state =WRITE_DYNAMIC_TEXT;
    endcase
end

always @(posedge clk_16ms) begin
    if (reset == 0) begin
        command_counter <= 'b0;
        data_counter <= 'b0;
		  data <= 'b0;
        $readmemh("/home/paulina/Descargas/temp_motor2/data.txt", static_data_mem);
    end else begin
        case(next_state)
            IDLE: begin
                command_counter <= 'b0;
                data_counter <= 'b0;
                rs <= 1'b0; // Para que la LCD sepa que son datos de configuración 
                data  <= 'b0;
            end
            CONFIG_CMD1: begin
			    rs <= 1'b0; 	
                command_counter <= command_counter + 1;
				data <= config_mem[command_counter];
            end
            WR_STATIC_TEXT_1L: begin
                data_counter <= data_counter + 1;
                rs <= 1'b1;  // Ahora si son datos de escritura
				data <= static_data_mem[data_counter];
            end
            CONFIG_CMD2: begin
                data_counter <= 'b0;
				rs <= 1'b0; 
				data <= START_2LINE;
            end
			WR_STATIC_TEXT_2L: begin
                data_counter <= data_counter + 1;
                rs <= 1'b1; 
				data <= static_data_mem[NUM_DATA_PERLINE + data_counter];
                sel_dynamic_state <= SET_COURSOR;
                sel_use_coursor <= 1'b0;
            end
            WRITE_DYNAMIC_TEXT: begin
                case(sel_dynamic_state)
                    SET_COURSOR: begin
                        rs <= 1'b0;
                        data <= coursor_data[sel_use_coursor];
                        sel_dynamic_state <= (sel_use_coursor == 0) ? 4'd1 : 4'd9;
                    end
                    4'd1: begin rs<=1; data <= (dyn_hours/10)+8'h30;  sel_dynamic_state<=4'd2; end
                    4'd2: begin rs<=1; data <= (dyn_hours%10)+8'h30;  sel_dynamic_state<=4'd3; end
                    4'd3: begin rs<=1; data <= 8'h3A;                 sel_dynamic_state<=4'd4; end

                    4'd4: begin rs<=1; data <= (dyn_minutes/10)+8'h30; sel_dynamic_state<=4'd5; end
                    4'd5: begin rs<=1; data <= (dyn_minutes%10)+8'h30; sel_dynamic_state<=4'd6; end
                    4'd6: begin rs<=1; data <= 8'h3A;                  sel_dynamic_state<=4'd7; end

                    4'd7: begin rs<=1; data <= (dyn_seconds/10)+8'h30; sel_dynamic_state<=4'd8; end
                    4'd8: begin rs<=1; data <= (dyn_seconds%10)+8'h30;
                        sel_use_coursor <= 1;     
                        sel_dynamic_state <= SET_COURSOR;
                    end
                    4'd9:  begin rs<=1; data <= (dyn_porciones/10)+8'h30; sel_dynamic_state<=4'd10; end
                    4'd10: begin rs<=1; data <= (dyn_porciones%10)+8'h30;
                        sel_use_coursor <= 0;  
                        sel_dynamic_state <= SET_COURSOR;
                    end

                endcase
            end
        endcase
    end
end

always @(posedge clk) begin
    if (!reset) begin
        dyn_hours <= 0;
        dyn_minutes <= 0;
        dyn_seconds <= 0;
        dyn_porciones <= 0;
    end else begin
        dyn_hours <= time_hours;
        dyn_minutes <= time_minutes;
        dyn_seconds <= time_seconds;
        dyn_porciones <= porciones;
    end
end

assign enable = clk_16ms;

endmodule


