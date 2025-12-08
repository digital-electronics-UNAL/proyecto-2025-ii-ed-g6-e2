module hm_ir_proximity #(
    parameter ACTIVE = 1,        // 1 si el sensor es activo en alto, 0 si activo en bajo
    parameter COUNT  = 5000      // mismo parámetro que antirrebote
)(
    input  clk,             // reloj del sistema
    input  rst,             // reset síncrono, activo en alto
    input  sensor_i,        // salida cruda del sensor IR (HM series)
    output reg  object         // 1 cuando se detecta objeto
   // output wire led              
);

    wire sensor_clean;

    antirrebote #(
        .COUNT(COUNT)
    ) debouncer_inst (
        .clk (clk),
        .btn (sensor_i),
        .clean(sensor_clean)
    );
    wire object_next = (ACTIVE) ? sensor_clean : 1'b0;

    // Registro de salida
    always @(posedge clk) begin
        if (!rst) begin
            object <= 1'b0;
        end else begin
            object <= object_next;
        end
    end


    //assign led = object;

endmodule