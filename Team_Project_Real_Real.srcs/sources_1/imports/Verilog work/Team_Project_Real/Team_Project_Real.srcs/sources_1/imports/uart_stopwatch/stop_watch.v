`timescale 1ns / 1ps

module stop_watch (
    input        clk,
    input        rst,
    input        sw,
    input        btnL_Clear,
    input        btnR_RunStop,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour,
    output [1:0] rs_state
);
    wire w_clear, w_runstop, w_sw;

    stop_watch_cu U_StopWatch_cu (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .i_clear(btnL_Clear),
        .i_runstop(btnR_RunStop),
        .o_clear(w_clear),
        .o_sw(w_sw),
        .o_runstop(w_runstop),
        .o_rs_state(rs_state)
    );

    stop_watch_dp U_StopWatch_dp (
        .clk(clk),
        .rst(rst),
        .run_stop(w_runstop),
        .clear(w_clear),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );
endmodule
