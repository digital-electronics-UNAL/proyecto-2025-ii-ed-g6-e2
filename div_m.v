
module div_m(clk, clk_1);

input clk; //frcuencia del reloj de la fpga
output reg clk_1; //nueva frecuencia para mover el motor
reg [27:0] cont; //contador con tamaño de 28 bits

initial begin //inicializar variables del contador y de clk_1
    cont = 28'd0;
    clk_1 = 0;
end

always @(posedge clk)begin //este bloque se ejecuta cada vez que la señal del reloj pasa de 0 a 1
    cont = cont + 28'd1; // se incrementa 1 el contador

    if(cont == 100000)begin //si el contador alcanzó un valor de 100000: (modificar para simular en el testbench)
        cont = 0; //volver el contador a 0
        clk_1 = ~clk_1; //cambia el estado del nuevo contador de 0 a 1 o viceversa
    end

end

endmodule