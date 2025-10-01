`timescale 1ns / 1ps

module watch (
    input        clk,
    input        rst,
    input        sw,
    input  [3:0] btn,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour,
    output [1:0] o_led
);
    wire [3:0] w_sig;
    watch_dp U_WATCH_DP (
        .clk  (clk),
        .rst  (rst),
        .u_btn(btn[0]),
        .d_btn(btn[3]),
        .o_sig(w_sig),
        .msec (msec),
        .sec  (sec),
        .min  (min),
        .hour (hour)
    );

    watch_cu U_WATCH_CU(
    .sw(sw),
    .btnL(btn[1]),
    .btnR(btn[2]),
    .clk(clk),
    .rst(rst),
    .o_sig(w_sig),
    .o_led(o_led)
);
endmodule
