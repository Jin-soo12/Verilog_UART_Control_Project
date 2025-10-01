`timescale 1ns / 1ps


module fnd_controller (
    input clk,
    input reset,
    input ws_mode,     //watch or sensor mode
    input en, // sw랑 똑같음
    input sensor_mode, // 초음파인지 온습도 센서인지.
    input rht_mode, // 온도인지 습도인지.
    input [6:0] msec,
    input [5:0] sec,
    input [5:0] min,
    input [4:0] hour,
    input [9:0] u_data,
    input [7:0] rh_data,
    input [7:0] t_data,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);
    wire [3:0] w_dot, w_bcd, w_bcd_s, w_bcd_w, w_d1_msec, w_d10_msec, w_d1_sec, w_d10_sec, w_d1_min, w_d10_min, w_d1_hour, w_d10_hour;
    wire [3:0] w_u_1, w_u_10, w_u_100, w_rh_1, w_rh_10, w_rh_100, w_t_1, w_t_10, w_t_100;
    wire w_o_clk;
    wire [2:0] fnd_sel;


    assign w_bcd = ws_mode ? w_bcd_s : w_bcd_w;  // watch 0, sensor 1

    counter_8 U_COUNTER_8 (
        .clk(w_o_clk),
        .reset(reset),
        .fnd_sel(fnd_sel)
    );

    clk_div U_CLK_DIV (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_o_clk)
    );

    decoder_2x4 U_DECODER (
        .fnd_sel(fnd_sel),
        .fnd_com(fnd_com)
    );

    digit_splitter #(
        .BIT_WIDTH(7)
    ) U_DIGIT_MSEC (
        .count_data(msec),
        .digit_1(w_d1_msec),
        .digit_10(w_d10_msec)
    );

    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_DIGIT_SEC (
        .count_data(sec),
        .digit_1(w_d1_sec),
        .digit_10(w_d10_sec)
    );

    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_DIGIT_MIN (
        .count_data(min),
        .digit_1(w_d1_min),
        .digit_10(w_d10_min)
    );

    digit_splitter #(
        .BIT_WIDTH(5)
    ) U_DIGIT_HOUR (
        .count_data(hour),
        .digit_1(w_d1_hour),
        .digit_10(w_d10_hour)
    );

    digit_splitter_sensor #(
        .BIT_WIDTH(10)
    ) U_DIGIT_SONIC (
        .count_data(u_data),
        .digit_1(w_u_1),
        .digit_10(w_u_10),
        .digit_100(w_u_100)
    );

    digit_splitter_sensor #(
        .BIT_WIDTH(8)
    ) U_DIGIT_RH (
        .count_data(rh_data),
        .digit_1(w_rh_1),
        .digit_10(w_rh_10),
        .digit_100(w_rh_100)
    );

    digit_splitter_sensor #(
        .BIT_WIDTH(8)
    ) U_DIGIT_T (
        .count_data(t_data),
        .digit_1(w_t_1),
        .digit_10(w_t_10),
        .digit_100(w_t_100)
    );

    dot_comparator U_DOT_COM (
        .msec(msec),
        .mode(ws_mode),
        .dot(w_dot)
    );

    mux_8x1 U_MUX_WATCH (
        .sel(fnd_sel),
        .digit_1(w_d1_msec), // msec
        .digit_10(w_d10_msec),
        .digit_100(w_d1_sec), // sec
        .digit_1000(w_d10_sec),
        .digit2_1(w_d1_min), // min
        .digit2_10(w_d10_min),
        .digit2_100(w_d1_hour), // hour
        .digit2_1000(w_d10_hour),
        .en(en), // msec or min
        .dot_watch(w_dot),
        .bcd(w_bcd_w)
    );

    mux_sensor U_MUX_SENSOR (
        .sel(fnd_sel),
        .digit_1(w_u_1), // ultrasonic
        .digit_10(w_u_10),
        .digit_100(w_u_100),
        .digit2_1(w_rh_1), // rh_data
        .digit2_10(w_rh_10),
        .digit2_100(w_rh_100),
        .digit3_1(w_t_1), // t_data
        .digit3_10(w_t_10),
        .digit3_100(w_t_100),
        .sensor_mode(sensor_mode),
        .rht_mode(rht_mode),
        .dot_sensor(w_dot),
        .bcd(w_bcd_s)
    );

    bcd U_BCD (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
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

module dot_comparator (
    input [6:0] msec,
    input mode,  // 0이면 watch, 1이면 sensor
    output reg [3:0] dot

);

    always @(*) begin
        if (mode == 0) begin
            dot = (msec > 49) ? 4'hf : 4'ha;
        end else begin
            dot = 4'ha;
        end
    end
endmodule

module counter_8 (
    input clk,
    input reset,
    output [2:0] fnd_sel
);
    reg [2:0] r_counter;
    assign fnd_sel = r_counter;
    always @(posedge clk, posedge reset) begin  // positive edge triggered, 비동기식 reset
        if (reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end
endmodule

module decoder_2x4 (
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

module mux_8x1 (
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    input [3:0] digit2_1,
    input [3:0] digit2_10,
    input [3:0] digit2_100,
    input [3:0] digit2_1000,
    input en,  // 1이면 mh, 2이면 ms
    input [2:0] sel,
    input [3:0] dot_watch,
    output [3:0] bcd
);

    reg [3:0] r_bcd;

    assign bcd = r_bcd;

    always @(*) begin
        case (sel)
            3'b000: r_bcd = (!en) ? digit_1 : digit2_1;
            3'b001: r_bcd = (!en) ? digit_10 : digit2_10;
            3'b010: r_bcd = (!en) ? digit_100 : digit2_100;
            3'b011: r_bcd = (!en) ? digit_1000 : digit2_1000;
            3'b100: r_bcd = 4'hf;
            3'b101: r_bcd = 4'hf;
            3'b110: r_bcd = dot_watch;
            3'b111: r_bcd = 4'hf;
        endcase

    end
endmodule

module mux_sensor (
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit2_1,     // 습도
    input  [3:0] digit2_10,
    input  [3:0] digit2_100,
    input  [3:0] digit3_1,     // 온도
    input  [3:0] digit3_10,
    input  [3:0] digit3_100,
    input        sensor_mode,  // 0 : 초음파센서, 1 : 온습도센서
    input        rht_mode,     // 0 : 온도, 1: 습도
    input  [2:0] sel,
    input  [3:0] dot_sensor,
    output [3:0] bcd
);

    reg [3:0] r_bcd;

    assign bcd = r_bcd;

    always @(*) begin
        case (sel)
            3'b000: r_bcd = 4'h0;
            3'b001:
            r_bcd = (!sensor_mode) ? digit_1 : {(rht_mode) ? digit2_1 : digit3_1};
            3'b010:
            r_bcd = (!sensor_mode) ? digit_10 : {(rht_mode) ? digit2_10 : digit3_10};
            3'b011:
            r_bcd = (!sensor_mode) ? digit_100 : {(rht_mode) ? digit2_100 : digit3_100};
            3'b100: r_bcd = 4'hf;
            3'b101: r_bcd = dot_sensor;
            3'b110: r_bcd = 4'hf;
            3'b111: r_bcd = 4'hf;
        endcase
    end
endmodule

module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input [BIT_WIDTH - 1:0] count_data,
    output [3:0] digit_1,
    output [3:0] digit_10
);

    assign digit_1  = count_data % 10;
    assign digit_10 = count_data / 10;
endmodule

module digit_splitter_sensor #(
    parameter BIT_WIDTH = 7
) (
    input [BIT_WIDTH - 1:0] count_data,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100
);

    assign digit_1   = count_data % 10;
    assign digit_10  = (count_data / 10) % 10;
    assign digit_100 = count_data / 100;
endmodule

module bcd (
    input  [3:0] bcd,
    output [7:0] fnd_data
);

    reg [7:0] r_fnd_data;
    assign fnd_data = r_fnd_data;

    always @(bcd) begin
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

