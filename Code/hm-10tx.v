
module uart_tx #(
    parameter CLOCK_FREQ = 32'd50_000_000, // Hz
    parameter BAUD       = 32'd9600
)(
    input  wire clk,
    input  wire rst_n,     // reset activo en 0
    input  wire start,     // pulso de 1 ciclo para enviar 'data'
    input  wire [7:0] data,
    output reg  tx,        // salida UART
    output reg  busy       // 1 mientras se está transmitiendo
);

    // Número de ciclos de reloj por bit
    localparam integer BAUD_TICKS = CLOCK_FREQ / BAUD;
    localparam integer CTR_WIDTH  = $clog2(BAUD_TICKS);

    reg [CTR_WIDTH-1:0] baud_cnt = 0;
    reg [3:0]           bit_cnt  = 0;   // cuenta de bits (0..9)
    reg [9:0]           shift_reg = 10'b1111111111; // incluye start + data + stop

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx        <= 1'b1; // línea en reposo en alto
            busy      <= 1'b0;
            baud_cnt  <= {CTR_WIDTH{1'b0}};
            bit_cnt   <= 4'd0;
            shift_reg <= 10'b1111111111;
        end else begin
            if (!busy) begin
                // UART en reposo, esperando un 'start'
                tx <= 1'b1;

                if (start) begin
                    // Cargar trama: [stop][data7..0][start]
                    // start bit = 0 (LSB), stop bit = 1 (MSB)
                    shift_reg <= {1'b1, data, 1'b0};
                    busy      <= 1'b1;
                    baud_cnt  <= {CTR_WIDTH{1'b0}};
                    bit_cnt   <= 4'd0;
                end
            end else begin
                // UART ocupado transmitiendo bits
                if (baud_cnt == BAUD_TICKS - 1) begin
                    baud_cnt <= {CTR_WIDTH{1'b0}};

                    // Enviar el bit LSB del shift_reg
                    tx        <= shift_reg[0];
                    shift_reg <= {1'b1, shift_reg[9:1]}; // desplazamiento a la derecha

                    if (bit_cnt == 4'd9) begin
                        // Ya se enviaron los 10 bits (1 start + 8 data + 1 stop)
                        bit_cnt <= 4'd0;
                        busy    <= 1'b0;
                        tx      <= 1'b1; // dejar la línea en reposo
                    end else begin
                        bit_cnt <= bit_cnt + 1'b1;
                    end
                end else begin
                    baud_cnt <= baud_cnt + 1'b1;
                end
            end
        end
    end

endmodule
