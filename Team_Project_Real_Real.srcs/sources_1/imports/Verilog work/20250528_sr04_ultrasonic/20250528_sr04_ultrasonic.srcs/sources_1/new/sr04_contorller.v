`timescale 1ns / 1ps

module sr04_contorller (
    input clk,
    input rst,
    input start,
    input echo,
    output trigger,
    output [9:0] range_data,
    output dist_done
);
    wire w_tick_1Mhz;

    tick_gen_1Mhz U_TICK_GEN (
        .clk(clk),
        .rst(rst),
        .o_tick_1Mhz(w_tick_1Mhz)
    );

    start_trigger U_START_TRIG (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_1Mhz),
        .start(start),
        .o_sr04_trigger(trigger)
    );

    distance_calculator U_DIST_CAL (
        .clk(clk),
        .rst(rst),
        .echo(echo),
        .i_tick(w_tick_1Mhz),
        .distance(range_data),
        .dist_done(dist_done)
    );


endmodule

module tick_gen_1Mhz (
    input  clk,
    input  rst,
    output o_tick_1Mhz
);
    parameter F_COUNT = (100 - 1);
    reg [6:0] count;
    reg tick;

    assign o_tick_1Mhz = tick;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            tick  <= 0;
        end else begin
            if (count == F_COUNT) begin
                count <= 0;
                tick  <= 1'b1;
            end else begin
                count <= count + 1;
                tick  <= 1'b0;
            end
        end
    end
endmodule

module start_trigger (
    input  clk,
    input  rst,
    input  i_tick,
    input  start,
    output o_sr04_trigger
);
    reg start_reg, start_next;
    reg [3:0] count_reg, count_next;
    reg o_sr04_trigger_reg, o_sr04_trigger_next;

    assign o_sr04_trigger = o_sr04_trigger_reg;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            start_reg <= 0;
            o_sr04_trigger_reg <= 0;
            count_reg <= 0;
        end else begin
            start_reg <= start_next;
            o_sr04_trigger_reg <= o_sr04_trigger_next;
            count_reg <= count_next;
        end
    end

    always @(*) begin
        start_next          = start_reg;
        o_sr04_trigger_next = o_sr04_trigger_reg;
        count_next          = count_reg;
        case (start_reg)
            0: begin
                count_next = 0;
                o_sr04_trigger_next = 1'b0;
                if (start) begin
                    start_next = 1'b1;
                end
            end
            1: begin
                if (i_tick) begin
                    o_sr04_trigger_next = 1'b1;
                    if (count_reg == 10) begin
                        start_next = 0;
                    end
                    count_next = count_reg + 1;
                end
            end

        endcase
    end

endmodule


module distance_calculator (
    input clk,
    input rst,
    input echo,
    input i_tick,
    output [9:0] distance,
    output dist_done
);
    reg c_state, n_state, dist_done_reg, dist_done_next, echo_d;
    reg [5:0] count_reg, count_next;
    reg [9:0] dist_reg, dist_next, r_dist_reg, r_dist_next;
    wire echo_posedge, echo_negedge;

    assign dist_done = dist_done_reg;
    assign distance  = r_dist_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            c_state <= 0;
            dist_done_reg <= 0;
            dist_reg <= 0;
            echo_d <= 0;
            r_dist_reg <= 0;
        end else begin
            count_reg <= count_next;
            c_state <= n_state;
            dist_done_reg <= dist_done_next;
            dist_reg <= dist_next;
            echo_d <= echo;
            r_dist_reg <= r_dist_next;
        end
    end
    assign echo_posedge = echo & (~echo_d);
    assign echo_negedge = (~echo) & echo_d;
    always @(*) begin
        n_state = c_state;
        count_next = count_reg;
        dist_done_next = dist_done_reg;
        dist_next = dist_reg;
        r_dist_next = r_dist_reg;
        case (c_state)
            0: begin
                dist_done_next = 0;
                if (echo_posedge) begin
                    n_state = 1;
                    count_next = 0;
                    dist_next = 0;
                end
            end
            1: begin
                if (echo_negedge) begin
                    n_state = 0;
                    dist_done_next = 1;
                    r_dist_next = dist_reg;
                end else if (i_tick) begin
                    if (count_reg == 57) begin
                        dist_next  = dist_reg + 1;
                        count_next = 0;
                    end else begin
                        count_next = count_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule

/*
module calculator (
    input [$clog2(58 * 400):0] distance,
    output [9:0] o_distance
);
    assign o_distance = distance / 58;
endmodule
*/
