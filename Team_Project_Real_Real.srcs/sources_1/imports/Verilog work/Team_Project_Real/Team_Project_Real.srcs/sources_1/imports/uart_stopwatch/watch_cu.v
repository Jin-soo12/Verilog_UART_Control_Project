`timescale 1ns / 1ps

module watch_cu (
    input            sw,
    input            btnL,
    input            btnR,
    input            clk,
    input            rst,
    output reg [3:0] o_sig,
    output reg [1:0] o_led
);
    parameter MSEC = 2'b00, SEC = 2'b01, MIN = 2'b10, HOUR = 2'b11;
    reg [1:0] c_state, n_state;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= 4'b0000;
        end else begin
            c_state <= n_state;
        end
    end

    always @(*) begin
        n_state = c_state;
        case (sw)
            0: begin
                if (btnR) begin
                    n_state = MSEC;
                end else if (btnL) begin
                    n_state = SEC;
                end else if (c_state == MIN) begin
                    n_state = MSEC;
                end else if (c_state == HOUR) begin
                    n_state = SEC;
                end

            end
            1: begin
                if (btnR) begin
                    n_state = MIN;
                end else if (btnL) begin
                    n_state = HOUR;
                end else if (c_state == MSEC) begin
                    n_state = MIN;
                end else if (c_state == SEC) begin
                    n_state = HOUR;
                end
            end
        endcase
    end

    always @(*) begin
        o_sig = 4'b0001;
        o_led = 2'b01;
        case (c_state)
            MSEC: begin
                o_sig = 4'b0001;
                o_led = 2'b01;
            end
            SEC: begin
                o_sig = 4'b0010;
                o_led = 2'b10;
            end
            MIN: begin
                o_sig = 4'b0100;
                o_led = 2'b01;
            end
            HOUR: begin
                o_sig = 4'b1000;
                o_led = 2'b10;
            end
        endcase
    end
endmodule
