`timescale 1ns / 1ps

module ascii_sender (
    input         clk,
    input         rst,
    input         sens_state,
    input  [ 9:0] i_sr_data,    //distance in data
    input  [13:0] i_dht_data,   //dht in data
    input         tx_full,
    input         start,
    output        tx_push,
    output [ 7:0] tx_push_data
);
    wire [47:0] ascii_data;
    wire [47:0] w_sr_ascii_data, w_dht_ascii_data;

    assign ascii_data = (sens_state == 0) ? w_sr_ascii_data : w_dht_ascii_data;

    datatoascii_sr U_D_TO_A_SR (
        .i_data(i_sr_data),
        .o_data(w_sr_ascii_data)
    );

    datatoascii_dht U_D_TO_A_DHT (
        .i_data(i_dht_data),
        .o_data(w_dht_ascii_data)
    );
    reg c_state, n_state;
    reg [7:0] send_data_reg, send_data_next;
    reg send_reg, send_next;
    reg [2:0] send_cnt_reg, send_cnt_next;

    assign tx_push = send_reg;
    assign tx_push_data = send_data_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state       <= 0;
            send_data_reg <= 0;
            send_reg      <= 0;
            send_cnt_reg  <= 0;
        end else begin
            c_state       <= n_state;
            send_data_reg <= send_data_next;
            send_reg      <= send_next;
            send_cnt_reg  <= send_cnt_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        send_data_next = send_data_reg;
        send_next = send_reg;
        send_cnt_next = send_cnt_reg;
        case (c_state)
            0: begin
                if (start) begin
                    n_state = 1;
                    send_cnt_next = 0;
                end
            end
            1: begin
                if (~tx_full) begin
                    send_next = 1'b1;
                    if (send_cnt_reg == 6) begin
                        n_state   = 0;
                        send_next = 0;
                    end else begin
                        case (send_cnt_reg)
                            3'b000: send_data_next = ascii_data[47:40];
                            3'b001: send_data_next = ascii_data[39:32];
                            3'b010: send_data_next = ascii_data[31:24];
                            3'b011: send_data_next = ascii_data[23:16];
                            3'b100: send_data_next = ascii_data[15:8];
                            3'b101: send_data_next = ascii_data[7:0];
                        endcase
                        send_cnt_next = send_cnt_reg + 1;
                    end
                end else begin
                    n_state = c_state;
                end
            end
        endcase
    end
endmodule

module datatoascii_sr (
    input  [ 9:0] i_data,
    output [47:0] o_data
);
    wire [3:0] digit_1, digit_10, digit_100, digit_1000;

    assign digit_1 = i_data % 10;
    assign digit_10 = (i_data / 10) % 10;
    assign digit_100 = (i_data / 100) % 10;
    assign digit_1000 = (i_data / 1000) % 10;
    assign o_data = {
        8'h30,
        4'h3,
        digit_1000,
        4'h3,
        digit_100,
        4'h3,
        digit_10,
        4'h3,
        digit_1,
        8'h0A
    };
endmodule

module datatoascii_dht (
    input  [13:0] i_data,
    output [47:0] o_data
);
    wire [3:0] digit_1, digit_10, digit_100, digit_1000;

    assign digit_1 = i_data % 10;
    assign digit_10 = (i_data / 10) % 10;
    assign digit_100 = (i_data / 100) % 10;
    assign digit_1000 = (i_data / 1000) % 10;
    assign o_data = {
        4'h3,
        digit_1000,
        4'h3,
        digit_100,
        8'h20,
        4'h3,
        digit_10,
        4'h3,
        digit_1,
        8'h0A
    };
endmodule
