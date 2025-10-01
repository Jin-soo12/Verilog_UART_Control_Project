`timescale 1ns / 1ps


module dht11_controller (
    input clk,
    input rst,
    input start,
    output [7:0] rh_data,
    output [7:0] t_data,
    output dht11_done,
    //output valid,
    //output [2:0] state_led,
    inout dht11_io
);
    wire w_clk, w_start_btn;

    btn_debounce U_BTN_DEB (
        .i_btn(start),
        .clk  (clk),
        .rst  (rst),
        .o_btn(w_start_btn)
    );

    tick_gen_10us U_10us_TICK (
        .clk(clk),
        .rst(rst),
        .o_10us_tick(w_clk)
    );

    parameter IDLE = 0, START = 1, WAIT = 2, SYNCL = 3, 
    SYNCH = 4, DATA_SYNC = 5, DATA_DETECT = 6, STOP = 7;

    parameter START_CYNC = 1900;

    reg [2:0] c_state, n_state;
    reg [$clog2(START_CYNC) - 1 : 0] t_cnt_reg, t_cnt_next;
    reg dht11_reg, dht11_next;
    reg io_en_reg, io_en_next;
    reg [39:0] data_reg;
    reg [39:0] data_next;
    reg [5:0] data_cnt_reg, data_cnt_next;
    reg valid_reg, valid_next;
    reg done_reg, done_next;
    reg [7:0] rh_data_reg, rh_data_next, t_data_reg, t_data_next;

    assign state_led = c_state;
    assign dht11_io = (io_en_reg) ? dht11_reg : 1'bz;
    assign dht11_done = done_reg;
    assign valid = valid_reg;
    assign rh_data = rh_data_reg;
    assign t_data = t_data_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= 0;
            t_cnt_reg <= 0;
            dht11_reg <= 1;
            io_en_reg <= 1;
            valid_reg <= 0;
            data_cnt_reg <= 0;
            done_reg <= 0;
            data_reg <= 0;
            rh_data_reg <= 0;
            t_data_reg <= 0;
        end else begin
            c_state <= n_state;
            t_cnt_reg <= t_cnt_next;
            dht11_reg <= dht11_next;
            io_en_reg <= io_en_next;
            valid_reg <= valid_next;
            data_cnt_reg <= data_cnt_next;
            done_reg <= done_next;
            data_reg <= data_next;
            rh_data_reg <= rh_data_next;
            t_data_reg <= t_data_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        t_cnt_next = t_cnt_reg;
        dht11_next = dht11_reg;
        io_en_next = io_en_reg;
        valid_next = valid_reg;
        data_cnt_next = data_cnt_reg;
        done_next = done_reg;
        data_next = data_reg;
        rh_data_next = rh_data_reg;
        t_data_next = t_data_reg;
        case (c_state)
            IDLE: begin
                done_next  = 0;
                dht11_next = 1'b1;
                if (w_start_btn) begin
                    n_state = START;
                    t_cnt_next = 0;
                end
            end
            START: begin
                dht11_next = 1'b0;
                if (w_clk) begin
                    if (t_cnt_reg == 1900 - 1) begin
                        n_state = WAIT;
                        t_cnt_next = 0;
                        data_next = 0;
                    end else begin
                        t_cnt_next = t_cnt_reg + 1;
                    end
                end
            end
            WAIT: begin
                dht11_next = 1;
                if (w_clk) begin
                    if (t_cnt_reg == 2) begin
                        n_state = SYNCL;
                        t_cnt_next = 0;
                        io_en_next = 0;     // 입력 전환
                    end
                    begin
                        t_cnt_next = t_cnt_reg + 1;
                    end
                end
            end
            SYNCL: begin
                if (w_clk) begin
                    if (dht11_io) begin
                        n_state = SYNCH;
                    end
                end
            end
            SYNCH: begin
                if (w_clk) begin
                    if (!dht11_io) begin
                        n_state = DATA_SYNC;
                        data_cnt_next = 0;
                    end
                end
            end
            DATA_SYNC: begin
                if (data_cnt_reg == 40) begin
                    n_state = STOP;
                    t_cnt_next = 0;
                end
                if (w_clk) begin
                    if (dht11_io) begin
                        n_state = DATA_DETECT;
                        t_cnt_next = 0;
                    end
                end
            end
            DATA_DETECT: begin
                if (w_clk) begin
                    if (!dht11_io) begin
                        if (t_cnt_reg < 5) begin
                            data_next = {data_reg[38:0], 1'b0};
                        end else begin
                            data_next = {data_reg[38:0], 1'b1};
                        end
                        t_cnt_next = 0;
                        data_cnt_next = data_cnt_reg + 1;
                        n_state = DATA_SYNC;
                    end
                    t_cnt_next = t_cnt_reg + 1;
                end
            end
            STOP: begin
                if (w_clk) begin
                    if (t_cnt_reg == 5) begin
                        n_state = IDLE;
                        done_next = 1;
                        io_en_next = 1;
                        valid_next = ((data_reg[39:32] + data_reg[31:24] + data_reg[23:16] 
                        + data_reg[15:8]) == data_reg[7:0]) ? 1'b1 : 1'b0;
                        rh_data_next = data_reg[39:32];
                        t_data_next = data_reg[23:16];
                    end else begin
                        t_cnt_next = t_cnt_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule


module tick_gen_10us (
    input  clk,
    input  rst,
    output o_10us_tick
);
    parameter F_COUNT = 1000;
    reg [$clog2(F_COUNT) - 1 : 0] count_reg;
    reg tick_reg;

    assign o_10us_tick = tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= 0;
        end else begin
            if (count_reg == F_COUNT - 1) begin
                tick_reg <= 1;
            end else begin
                tick_reg <= 0;
            end
            count_reg <= count_reg + 1;
        end
    end
endmodule

