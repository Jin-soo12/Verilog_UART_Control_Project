`timescale 1ns / 1ps

module Top_SR04 (
    input clk,
    input rst,
    input btn_start,
    input echo,
    output trigger,
    output dist_done,
    output [9:0] range_data
);

    wire w_btn;
    btn_debounce U_BTN_DEB (
        .i_btn(btn_start),
        .clk  (clk),
        .rst  (rst),
        .o_btn(w_btn)
    );

    sr04_contorller U_SR04_CON (
        .clk(clk),
        .rst(rst),
        .start(w_btn),
        .echo(echo),
        .trigger(trigger),
        .range_data(range_data),
        .dist_done(dist_done)
    );
endmodule
