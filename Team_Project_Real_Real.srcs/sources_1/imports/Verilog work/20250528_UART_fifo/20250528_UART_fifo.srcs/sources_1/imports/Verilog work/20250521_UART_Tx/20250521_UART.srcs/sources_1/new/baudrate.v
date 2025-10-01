`timescale 1ns / 1ps

module baudrate (
    input clk,
    input rst,
    output baud_tick
);
    parameter BAUD = 9600;
    parameter BAUD_COUNT = 100_000_000/(BAUD * 8);
    reg  [$clog2(BAUD_COUNT)-1:0] count_reg;
    wire [$clog2(BAUD_COUNT)-1:0] count_next;

    assign count_next = (count_reg == BAUD_COUNT - 1) ? 0 : count_reg + 1;
    assign baud_tick  = (count_reg == BAUD_COUNT - 1) ? 1'b1 : 1'b0;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= 0;
        end else begin
            count_reg <= count_next;
        end
    end
endmodule

