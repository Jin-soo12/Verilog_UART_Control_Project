`timescale 1ns / 1ps

module fnd_controller (
    input        clk,
    input        reset,
    input        sw,
    input  [6:0] msec,
    input  [5:0] sec,
    input  [5:0] min,
    input  [4:0] hour,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output       o_led
);

    wire [3:0] w_bcd, w_msec_1, w_msec_10, w_sec_1, w_sec_10;
    wire [3:0] w_min_1, w_min_10, w_hour_1, w_hour_10;
    wire [3:0] w_msec_bcd, w_min_bcd;
    wire [3:0] w_dot;
    wire w_oclk;
    wire [2:0] w_sel;

    counter_8 U_Counter_8 (
        .clk(w_oclk),
        .reset(reset),
        .fnd_sel(w_sel)
    );

    clk_div U_Clk_div (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_oclk)
    );

    bcd U_BCD (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );

    decorder_2x4 U_D_2x4 (
        .fnd_sel(w_sel),
        .fnd_com(fnd_com)
    );
    msec_compare U_MSEC_COM (
        .msec(msec),
        .dot (w_dot)
    );
    mux_8x1 U_MUX_MSEC_SEC (
        .sel(w_sel),
        .dot(w_dot),
        .digit1_1(w_msec_1),
        .digit1_10(w_msec_10),
        .digit2_1(w_sec_1),
        .digit2_10(w_sec_10),
        .bcd(w_msec_bcd)
    );

    mux_8x1 U_MUX_MIN_HOUR (
        .sel(w_sel),
        .dot(w_dot),
        .digit1_1(w_min_1),
        .digit1_10(w_min_10),
        .digit2_1(w_hour_1),
        .digit2_10(w_hour_10),
        .bcd(w_min_bcd)
    );

    mux_2x1 U_sw_2x1_mux (
        .sw(sw),
        .msec_sec(w_msec_bcd),
        .min_hour(w_min_bcd),
        .bcd(w_bcd),
        .o_led(o_led)
    );

    digit_splitter #(7) U_DIG_MSEC (
        .time_data(msec),
        .digit_time_1(w_msec_1),
        .digit_time_10(w_msec_10)
    );

    digit_splitter #(6) U_DIG_SEC (
        .time_data(sec),
        .digit_time_1(w_sec_1),
        .digit_time_10(w_sec_10)
    );

    digit_splitter #(6) U_DIG_MIN (
        .time_data(min),
        .digit_time_1(w_min_1),
        .digit_time_10(w_min_10)
    );

    digit_splitter #(5) U_DIG_HOUR (
        .time_data(hour),
        .digit_time_1(w_hour_1),
        .digit_time_10(w_hour_10)
    );
endmodule

module clk_div (
    input  clk,
    input  reset,
    output o_clk
);
    reg [$clog2(100_000)-1:0] r_counter;
    reg r_clk;  //1khz r_counter = 100Mhz/1khz = 100_000 -> 17bit
    assign o_clk = r_clk;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk     <= 0;
        end else begin
            if (r_counter == 100_000 - 1) begin
                r_counter <= 0;
                r_clk <= 1;
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 0;
            end
        end
    end
endmodule


module counter_8 (
    input        clk,
    input        reset,
    output [2:0] fnd_sel
);
    reg [2:0] r_counter;
    assign fnd_sel = r_counter;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end

endmodule


module decorder_2x4 (
    input [1:0] fnd_sel,
    output reg [3:0] fnd_com
);
    always @(*) begin
        case (fnd_sel)
            2'b00:   fnd_com = 4'b1110;
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;
        endcase
    end

endmodule

module msec_compare (
    input  [6:0] msec,
    output [3:0] dot
);
    assign dot = ((msec > 49) ? 4'ha : 4'hb);
endmodule

module mux_8x1 (
    input      [2:0] sel,
    input      [3:0] dot,
    input      [3:0] digit1_1,
    input      [3:0] digit1_10,
    input      [3:0] digit2_1,
    input      [3:0] digit2_10,
    output reg [3:0] bcd
);
    always @(*) begin

        case (sel)
            3'b000: begin
                bcd = digit1_1;
            end
            3'b001: begin
                bcd = digit1_10;
            end
            3'b010: begin
                bcd = digit2_1;
            end
            3'b011: begin
                bcd = digit2_10;
            end
            3'b100: begin
                bcd = 4'hb;
            end
            3'b101: begin
                bcd = 4'hb;
            end
            3'b110: begin
                bcd = dot;
            end
            3'b111: begin
                bcd = 4'hb;
            end
            default: bcd = 0;
        endcase
    end
endmodule


module mux_2x1 (
    input            sw,
    input            rx_sw_sig,
    input      [3:0] msec_sec,
    input      [3:0] min_hour,
    output reg [3:0] bcd,
    output reg       o_led
);

    always @(*) begin
        case (sw)
            0: begin
                bcd   = msec_sec;
                o_led = 1'b0;
            end
            1: begin
                bcd   = min_hour;
                o_led = 1'b1;
            end
            default: bcd = msec_sec;
        endcase
    end
endmodule


module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input [BIT_WIDTH-1:0] time_data,
    output [3:0] digit_time_1,
    output [3:0] digit_time_10
);
    assign digit_time_1  = time_data % 10;
    assign digit_time_10 = time_data / 10;

endmodule

module bcd (
    input  [3:0] bcd,
    output [7:0] fnd_data
);
    reg [7:0] r_fnd_data;
    assign fnd_data = r_fnd_data;
    always @(*) begin
        case (bcd)
            4'h0: r_fnd_data = 8'hc0;
            4'h1: r_fnd_data = 8'hf9;
            4'h2: r_fnd_data = 8'ha4;
            4'h3: r_fnd_data = 8'hb0;
            4'h4: r_fnd_data = 8'h99;
            4'h5: r_fnd_data = 8'h92;
            4'h6: r_fnd_data = 8'h82;
            4'h7: r_fnd_data = 8'hf8;
            4'h8: r_fnd_data = 8'h80;
            4'h9: r_fnd_data = 8'h90;
            4'ha: r_fnd_data = 8'h7f;
            default: r_fnd_data = 8'hff;
        endcase
    end
endmodule
