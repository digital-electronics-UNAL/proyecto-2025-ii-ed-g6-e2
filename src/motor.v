module motor(clk_1, motor_activo, M);
input clk_1; //frecuencia del reloj de la fpga
input motor_activo;
output reg [3:0] M; //señal que mueve el motor M

reg [2:0] cont; //contador de 3 bits

initial begin //inicializar variables del motor y del contador
    M <= 4'b0000;
    cont <= 3'b000;
end

always @(posedge clk_1)begin //cada vez que clk_1 pase de 0 a 1 se ejecutará el siguiente bloque:
    if (motor_activo) begin
        case(cont) //M toma el valor que corresponda con el respectivo contador
            3'b000: begin M <= 4'b0001; end
            3'b001: begin M <= 4'b0011; end
            3'b010: begin M <= 4'b0010; end
            3'b011: begin M <= 4'b0110; end
            3'b100: begin M <= 4'b0100; end
            3'b101: begin M <= 4'b1100; end
            3'b110: begin M <= 4'b1000; end
            3'b111: begin M <= 4'b1001; end
            default begin cont <= 3'b000; end //condición de precuación para resetear el contador
        endcase
        cont <= cont + 3'b001; //incrementar el contador con 1
    end
end

endmodule