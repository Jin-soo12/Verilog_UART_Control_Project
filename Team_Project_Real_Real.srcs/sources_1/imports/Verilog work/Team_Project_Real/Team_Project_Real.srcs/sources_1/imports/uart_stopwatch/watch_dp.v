`timescale 1ns / 1ps

module watch_dp (
    input        clk,
    input        rst,
    input        u_btn,
    input        d_btn,
    input  [3:0] o_sig,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);
    wire w_tick_100hz, w_tick_sec, w_tick_min, w_tick_hour, w_tick_day, w_rst, w_clk;

    watch_tick_gen_100hz U_TICK_GEN (
        .clk(clk),
        .rst(rst),
        .o_tick_100(w_tick_100hz)
    );

    watch_time_counter #(7, 100, 0) U_MSEC (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_100hz),
        .u_btn(u_btn),
        .d_btn(d_btn),
        .o_sig(o_sig[0]),
        .o_time(msec),
        .o_tick(w_tick_sec)
    );

    watch_time_counter #(6, 60, 0) U_SEC (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_sec),
        .u_btn(u_btn),
        .d_btn(d_btn),
        .o_sig(o_sig[1]),
        .o_time(sec),
        .o_tick(w_tick_min)
    );

    watch_time_counter #(6, 60, 0) U_MIN (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_min),
        .u_btn(u_btn),
        .d_btn(d_btn),
        .o_sig(o_sig[2]),
        .o_time(min),
        .o_tick(w_tick_hour)
    );

    watch_time_counter #(5, 24, 12) U_HOUR (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_hour),
        .u_btn(u_btn),
        .d_btn(d_btn),
        .o_sig(o_sig[3]),
        .o_time(hour),
        .o_tick(w_tick_day)
    );
endmodule

module watch_tick_gen_100hz (
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

module watch_time_counter #(
    parameter BIT_WIDTH  = 7,
    parameter TICK_COUNT = 100,
    parameter INITIAL_NUM = 0
) (
    input                  clk,
    input                  rst,
    input                  i_tick,
    input                  u_btn,
    input                  d_btn,
    input                  o_sig,
    output [BIT_WIDTH-1:0] o_time,
    output                 o_tick
);
    /*reg u_btn_d, d_btn_d;
    wire u_rise = u_btn & ~u_btn_d;
    wire d_rise = d_btn & ~d_btn_d;*/
    reg [$clog2(TICK_COUNT)-1:0] count_reg  = INITIAL_NUM;
    reg [$clog2(TICK_COUNT)-1:0] count_next;
    reg o_tick_reg, o_tick_next;


    assign o_time = count_reg;
    assign o_tick = o_tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg  <= INITIAL_NUM;
            o_tick_reg <= 0;
        end else begin
            count_reg <= count_next;
            o_tick_reg <= o_tick_next;
            /*u_btn_d <= u_btn;
            d_btn_d <= d_btn;*/
        end
    end

    always @(*) begin
        count_next  = count_reg;
        o_tick_next = 0;
        if (i_tick) begin
            if (count_reg == TICK_COUNT - 1) begin
                count_next  = 0;
                o_tick_next = 1;
            end else begin
                count_next  = count_reg + 1;
                o_tick_next = 0;
            end
        end 
        
        if (o_sig) begin
            if (u_btn) begin
                if (count_reg == TICK_COUNT - 1) count_next  = 0;
                else count_next = count_reg + 1;
            end else if (d_btn) begin
                count_next = (count_reg == 0) ? TICK_COUNT - 1 : count_reg - 1;
            end
        end
    end

    /*    always @(posedge u_btn, posedge d_btn) begin
        count_next = count_next;
        if (u_btn && o_sig) begin
            count_next = count_next + 1;
        end else if (d_btn && o_sig) begin
            if (count_next == 0) count_next = TICK_COUNT;
            count_next = count_next - 1;
        end
    end*/
endmodule

