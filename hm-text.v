// ---------------------------------------------------------
// HM10sender.v
//  Envía "No hay mas porciones\r\n" cuando 'trigger' pasa 0->1
// ---------------------------------------------------------
module HM10sender #(
    parameter CLOCK_FREQ = 32'd50_000_000,
    parameter BAUD       = 32'd9600
)(
    input  wire clk,
    input  wire rst_n,
    input  wire trigger,   // 1 cuando no hay porciones
    output wire tx         // conectar a top_bluetooth
);

    // Mensaje: "No hay mas porciones\r\n"
    localparam integer MSG_LEN = 22;

    reg [7:0] msg [0:MSG_LEN-1];

    initial begin
        msg[0]  = "N";
        msg[1]  = "o";
        msg[2]  = " ";
        msg[3]  = "h";
        msg[4]  = "a";
        msg[5]  = "y";
        msg[6]  = " ";
        msg[7]  = "m";
        msg[8]  = "a";
        msg[9]  = "s";
        msg[10] = " ";
        msg[11] = "p";
        msg[12] = "o";
        msg[13] = "r";
        msg[14] = "c";
        msg[15] = "i";
        msg[16] = "o";
        msg[17] = "n";
        msg[18] = "e";
        msg[19] = "s";
        msg[20] = 8'h0D; // '\r'
        msg[21] = 8'h0A; // '\n'
    end

    // UART TX interno
    reg        start = 1'b0;
    reg [7:0]  data  = 8'd0;
    wire       busy;

    uart_tx #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD      (BAUD)
    ) uart_tx_inst (
        .clk   (clk),
        .rst_n (rst_n),
        .start (start),
        .data  (data),
        .tx    (tx),
        .busy  (busy)
    );

    // Detector de flanco de subida en trigger (0 -> 1)
    reg trigger_d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            trigger_d <= 1'b0;
        else
            trigger_d <= trigger;
    end

    wire trigger_rise = (trigger == 1'b1) && (trigger_d == 1'b0);

    // FSM para enviar mensaje una vez por flanco
    localparam [1:0]
        S_IDLE = 2'd0,
        S_LOAD = 2'd1,
        S_SEND = 2'd2,
        S_DONE = 2'd3;

    reg [1:0] state = S_IDLE;
    reg [4:0] index = 5'd0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            index <= 5'd0;
            start <= 1'b0;
            data  <= 8'd0;
        end else begin
            case (state)
                S_IDLE: begin
                    start <= 1'b0;
                    index <= 5'd0;

                    if (trigger_rise && !busy) begin
                        state <= S_LOAD;
                    end
                end

                S_LOAD: begin
                    if (!busy) begin
                        data  <= msg[index];
                        start <= 1'b1;   // pulso de un ciclo
                        state <= S_SEND;
                    end else begin
                        start <= 1'b0;
                    end
                end

                S_SEND: begin
                    start <= 1'b0;
                    if (!busy) begin
                        if (index == MSG_LEN - 1) begin
                            state <= S_DONE;
                        end else begin
                            index <= index + 1'b1;
                            state <= S_LOAD;
                        end
                    end
                end

                S_DONE: begin
                    // Mensaje completo enviado para ESTE flanco.
                    // Espera a que trigger vuelva a 0 para permitir otro envío.
                    if (!trigger) begin
                        state <= S_IDLE;
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule

