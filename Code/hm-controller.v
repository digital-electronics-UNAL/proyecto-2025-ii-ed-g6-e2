module top_bluetooth #(
    parameter CLOCK_FREQ = 32'd50_000_000,
    parameter BAUD       = 32'd9600
)(
    input  wire clk_50mhz,
    input  wire rst_n,
    input  wire trigger,   // 1 cuando no hay porciones
    output wire bt_tx      // va al RX del HM-10
);

    HM10sender #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD      (BAUD)
    ) sender_inst (
        .clk     (clk_50mhz),
        .rst_n   (rst_n),
        .trigger (trigger),
        .tx      (bt_tx)
    );

endmodule
