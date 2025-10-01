`timescale 1ns / 1ps


module tb_send_ascii ();
    reg clk, rst, tx_full, start, sens_state;
    reg [9:0] i_sr_data;
    reg [13:0] i_dht_data;
    wire tx_push;
    wire [7:0] tx_push_data;

    ascii_sender dut (
        .clk(clk),
        .rst(rst),
        .sens_state(sens_state),
        .i_sr_data(i_sr_data),  //distance in data
        .i_dht_data(i_dht_data),  //dht in data
        .tx_full(tx_full),
        .start(start),
        .tx_push(tx_push),
        .tx_push_data(tx_push_data)
    );

    always #5 clk = ~clk;
    initial begin
        #0;
        clk = 0;
        rst = 1;
        i_sr_data = 253;
        i_dht_data = 0;
        tx_full = 0;
        start = 0;
        sens_state = 0;
        #20;
        rst = 0;
        #15;
        start  = 1;
        #10;
        start = 0;
        #10000;
    end
endmodule
