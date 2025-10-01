`timescale 1ns / 1ps

module stop_watch_dp (
    input        clk,
    input        rst,
    input        run_stop,
    input        clear,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);
    wire w_tick_100hz, w_tick_sec, w_tick_min, w_tick_hour, w_tick_day, w_rst, w_clk;

    tick_gen_100hz U_TICK_GEN (
        .clk(clk),
        .rst(rst | clear),
        .o_tick_100(w_tick_100hz)
    );

    time_counter #(7, 100) U_MSEC (
        .clk(clk),
        .run_stop(run_stop),
        .rst(rst | clear),
        .i_tick(w_tick_100hz),
        .o_time(msec),
        .o_tick(w_tick_sec)
    );

    time_counter #(6, 60) U_SEC (
        .clk(clk),
        .run_stop(run_stop),
        .rst(rst | clear),
        .i_tick(w_tick_sec),
        .o_time(sec),
        .o_tick(w_tick_min)
    );

    time_counter #(6, 60) U_MIN (
        .clk(clk),
        .run_stop(run_stop),
        .rst(rst | clear),
        .i_tick(w_tick_min),
        .o_time(min),
        .o_tick(w_tick_hour)
    );

    time_counter #(5, 24) U_HOUR (
        .clk(clk),
        .run_stop(run_stop),
        .rst(rst | clear),
        .i_tick(w_tick_hour),
        .o_time(hour),
        .o_tick(w_tick_day)
    );
endmodule

module tick_gen_100hz (
    input      clk,
    input      rst,
    output reg o_tick_100
);

    parameter FCOUNT = 1_000_000;
    reg [$clog2(FCOUNT)-1:0] r_counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            o_tick_100 <= 0;
        end else begin
            if (r_counter == FCOUNT - 1) begin
                o_tick_100 <= 1;
                r_counter  <= 0;
            end else begin
                o_tick_100 <= 0;
                r_counter  <= r_counter + 1;
            end
        end
    end
endmodule

module time_counter #(
    parameter BIT_WIDTH  = 7,
    parameter TICK_COUNT = 100
) (
    input                  clk,
    input                  rst,
    input                  i_tick,
    input                  run_stop,
    output [BIT_WIDTH-1:0] o_time,
    output                 o_tick
);

    reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg o_tick_reg, o_tick_next;

    assign o_time = count_reg;
    assign o_tick = o_tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg  <= 0;
            o_tick_reg <= 0;
        end else begin
            count_reg  <= count_next;
            o_tick_reg <= o_tick_next;
        end
    end

    always @(*) begin
        count_next  = count_reg;
        o_tick_next = 0;
        if (i_tick && run_stop) begin
            if (count_reg == TICK_COUNT - 1) begin
                count_next  = 0;
                o_tick_next = 1;
            end else begin
                count_next  = count_reg + 1;
                o_tick_next = 0;
            end
        end
    end
endmodule
