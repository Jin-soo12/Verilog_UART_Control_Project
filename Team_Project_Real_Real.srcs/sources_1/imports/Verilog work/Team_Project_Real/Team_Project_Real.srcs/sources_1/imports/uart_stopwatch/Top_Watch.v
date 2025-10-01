`timescale 1ns / 1ps

module Top_Watch (
    input        clk,
    input        rst,
    input  [1:0] sw,
    input  [3:0] rx_btn_data,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [2:0] L_R_Mode_led,
    output [1:0] rs_state,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);
    wire [3:0] w_btn, w_stop_w_btn, w_watch_btn;
    wire [6:0] w_stop_w_msec, w_watch_msec;
    wire [5:0] w_stop_w_sec, w_watch_sec, w_stop_w_min, w_watch_min;
    wire [4:0] w_stop_w_hour, w_watch_hour;
    wire [1:0] w_led;


    btn_debounce U_DEBOUNCE_U (
        .i_btn(rx_btn_data[0]),
        .clk  (clk),
        .rst  (rst),
        .o_btn(w_btn[0])
    );

    btn_debounce U_DEBOUNCE_D (
        .i_btn(rx_btn_data[3]),
        .clk  (clk),
        .rst  (rst),
        .o_btn(w_btn[3])
    );

    btn_debounce U_DEBOUNCE_L (
        .i_btn(rx_btn_data[1]),
        .clk  (clk),
        .rst  (rst),
        .o_btn(w_btn[1])
    );

    btn_debounce U_DEBOUNCE_R (
        .i_btn(rx_btn_data[2]),
        .clk  (clk),
        .rst  (rst),
        .o_btn(w_btn[2])
    );

    btn_demux_1x2 U_BTN_DEMUX (
        .clk(clk),
        .rst(rst),
        .sw(sw[1]),
        .btn(w_btn),
        .i_led(w_led),
        .stop_w_btn(w_stop_w_btn),
        .watch_btn(w_watch_btn),
        .led(L_R_Mode_led)
    );

    stop_watch U_STOP_WATCH (
        .clk(clk),
        .rst(rst),
        .sw(sw[0]),
        .btnL_Clear(w_stop_w_btn[1]),
        .btnR_RunStop(w_stop_w_btn[2]),
        .msec(w_stop_w_msec),
        .sec(w_stop_w_sec),
        .min(w_stop_w_min),
        .hour(w_stop_w_hour),
        .rs_state(rs_state)
    );

    watch U_WATCH (
        .clk(clk),
        .rst(rst),
        .sw(sw[0]),
        .btn(w_watch_btn),
        .msec(w_watch_msec),
        .sec(w_watch_sec),
        .min(w_watch_min),
        .hour(w_watch_hour),
        .o_led(w_led)
    );

    watch_mode_mux U_WATCH_MUX (
        .clk(clk),
        .rst(rst),
        .sw(sw[1]),
        .stop_w_msec(w_stop_w_msec),
        .stop_w_sec(w_stop_w_sec),
        .stop_w_min(w_stop_w_min),
        .stop_w_hour(w_stop_w_hour),
        .watch_msec(w_watch_msec),
        .watch_sec(w_watch_sec),
        .watch_min(w_watch_min),
        .watch_hour(w_watch_hour),
        .o_msec(msec),
        .o_sec(sec),
        .o_min(min),
        .o_hour(hour)
    );

endmodule

module watch_mode_mux (
    input            clk,
    input            rst,
    input            sw,
    input      [6:0] stop_w_msec,
    input      [5:0] stop_w_sec,
    input      [5:0] stop_w_min,
    input      [4:0] stop_w_hour,
    input      [6:0] watch_msec,
    input      [5:0] watch_sec,
    input      [5:0] watch_min,
    input      [4:0] watch_hour,
    output reg [6:0] o_msec,
    output reg [5:0] o_sec,
    output reg [5:0] o_min,
    output reg [4:0] o_hour
);
    parameter WATCH = 0, STOP_WATCH = 1;

    always @(*) begin
        case (sw)
            WATCH: begin
                o_msec = watch_msec;
                o_sec  = watch_sec;
                o_min  = watch_min;
                o_hour = watch_hour;
            end
            STOP_WATCH: begin
                o_msec = stop_w_msec;
                o_sec  = stop_w_sec;
                o_min  = stop_w_min;
                o_hour = stop_w_hour;
            end
            default: begin
                o_msec = watch_msec;
                o_sec  = watch_sec;
                o_min  = watch_min;
                o_hour = watch_hour;
            end
        endcase
    end
endmodule

module btn_demux_1x2 (
    input            clk,
    input            rst,
    input            sw,
    input      [1:0] i_led,
    input      [3:0] btn,
    output reg [3:0] stop_w_btn,
    output reg [3:0] watch_btn,
    output reg [2:0] led
);

    always @(*) begin
        watch_btn  = 4'b0000;
        stop_w_btn = 4'b0000;
        case (sw)
            0: begin
                watch_btn = btn;
                stop_w_btn = 4'b0000;
                led = {1'b0, i_led};
            end
            1: begin
                stop_w_btn = btn;
                watch_btn = 4'b0000;
                led = 3'b100;
            end
            default: begin
                watch_btn = btn;
                stop_w_btn = 4'b0000;
                led = {1'b0, i_led};
            end
        endcase
    end
endmodule
