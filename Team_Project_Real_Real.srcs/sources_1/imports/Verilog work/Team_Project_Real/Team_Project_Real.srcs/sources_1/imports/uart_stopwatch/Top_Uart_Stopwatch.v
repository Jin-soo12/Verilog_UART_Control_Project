`timescale 1ns / 1ps

module Top_Uart_Stopwatch (
    input        clk,
    input        rst,
    input  [1:0] sw,
    input  [3:0] btn,
    input        rx,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [2:0] L_R_Mode_led,
    output       Time_Mode_led,
    output       tx
);
    wire w_rx_done;
    wire [3:0] w_rx_btn;
    wire [1:0] w_rx_sw;
    wire [7:0] w_rx_data;
    wire [1:0] w_rs_state;
    wire w_rst;

    assign w_rst = (rst | rx_rst);


endmodule
