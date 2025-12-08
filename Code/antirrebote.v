module antirrebote #(parameter COUNT=5000) (
    input clk,
    input btn,
    output reg clean = 0
);
    reg [$clog2(COUNT)-1:0] count = 0;
    reg btn_sync = 0;

    always @(posedge clk) begin
        // Sincronizo la entrada al reloj
        btn_sync <= btn;
        
        if (btn_sync == clean) begin
            count <= 0;
        end else begin
            // Si NO coincide, empiezo a contar cuánto tiempo lleva distinto
            count <= count + 1;
            if (count == COUNT)
                // Cuando se alcanza COUNT, actualizo clean
                clean <= btn_sync;
        end
    end
endmodule