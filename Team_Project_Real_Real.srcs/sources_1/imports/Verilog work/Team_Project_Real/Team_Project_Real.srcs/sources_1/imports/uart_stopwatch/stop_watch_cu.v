`timescale 1ns / 1ps
module stop_watch_cu (
    input  clk,
    input  rst,
    input  sw,
    input  i_clear,
    input  i_runstop,
    output o_sw,
    output o_clear,
    output o_runstop,
    output [1:0] o_rs_state
);

    parameter STOP = 2'b00, RUN = 2'b10, CLEAR = 2'b01;
    assign o_sw = sw;

    reg [1:0] c_state, n_state;
    assign o_rs_state = c_state;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= STOP;
        end else begin
            c_state <= n_state;
        end
    end

    always @(*) begin
        n_state = c_state;
        case (c_state)
            STOP:
            if (i_clear == 1) begin
                n_state = CLEAR;
            end else if (i_runstop == 1) begin
                n_state = RUN;
            end
            CLEAR:
            if (i_clear == 1) begin
                n_state = STOP;
            end
            RUN:
            if (i_runstop == 1) begin
                n_state = STOP;
            end
            default: n_state = STOP;
        endcase
    end

    assign o_clear   = (c_state == CLEAR);
    assign o_runstop = (c_state == RUN);
endmodule
