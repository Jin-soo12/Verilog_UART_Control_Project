`timescale 1ns / 1ps

module tb_uart_cu ();
    reg clk, rst, rx;
    reg [1:0] sw;
    reg [3:0] btn;
    reg [1:0] w_rs_state;
    wire w_rx_pop, w_rx_empty, w_rx_done;
    wire [7:0] w_rx_pop_data;
    wire [1:0] w_rx_sw;
    wire [3:0] w_rx_btn_watch, w_rx_btn_sr, w_rx_btn_dht;
    wire w_msec;

    reg [7:0] rx_send_data;
    uart_controller dut1 (
        .clk        (clk),
        .rst        (rst),
        //.tx_push     (w_tx_push),
        .rx         (rx),
        //.tx_push_data(w_tx_push_data),
        //.rx_data     (w_rx_data),
        .rx_pop     (w_rx_pop),
        .rx_empty   (w_rx_empty),
        .rx_done    (w_rx_done),
        .rx_pop_data(w_rx_pop_data)
        //.tx_full     (w_tx_full),
        //output       .tx_done(),
        //.tx_busy(),
        //.tx          (tx)
    );

    uart_cu dut2 (
        .clk(clk),
        .rst(rst|w_cu_rst),
        .sw(sw),
        .btn(btn),
        .rx_empty(w_rx_empty),  //rx empty
        .rx_pop_data(w_rx_pop_data),
        //.rx_done(w_rx_done),
        //.rx_data(w_rx_data),
        .rs_state(w_rs_state),
        .rx_rst(w_cu_rst),
        .o_rx_sw(w_rx_sw),
        .rx_pop(w_rx_pop),
        //.led(led),
        //.sens_state(w_sens_state),  //for fnd sens_state DISTANSCE : 0, DHT : 1
        //.ws_mode(w_ws_mode),
        //.rht_mode(w_rht_mode),
        .o_rx_btn_watch(w_rx_btn_watch),
        .o_rx_btn_sr(w_rx_btn_sr),
        .o_rx_btn_dht(w_rx_btn_dht)
    );

    Top_Watch dut3 (
        .clk        (clk),
        .rst        (rst|w_cu_rst),
        .sw         (w_rx_sw),
        .rx_btn_data(w_rx_btn_watch),
        //.L_R_Mode_led(L_R_Mode_led),
        //.rs_state    (w_rs_state),
        .msec       (w_msec)
        //.sec         (w_sec),
        //.min         (w_min),
        //.hour        (w_hour)
    );

    always #5 clk = ~clk;
    initial begin
        #0;
        clk = 0;
        rst = 1;
        rx = 1;
        btn = 0;
        w_rs_state = 2'b00;
        #20;
        rst = 0;
        #10;

        //CLK = 24'h434C4B;
        rx_send_data = 8'h43;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h4C;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h4B;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        #20;

        // "SNR" : {8'h53, 8'h4E, 8'h52}
        rx_send_data = 8'h53;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h4E;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h52;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        #20;

        // "TWO" : {8'h54, 8'h57, 8'h4F}
        rx_send_data = 8'h54;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h57;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h4F;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal

        #20;

        //"RUN" : {8'h52, 8'h55, 8'h4E}
        rx_send_data = 8'h52;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h55;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h4E;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal

        #20;

        // "CLK" : {8'h43, 8'h4C, 8'h4B}
        rx_send_data = 8'h43;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h4C;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h4B;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal

        #20;

        // "TWO" : {8'h54, 8'h57, 8'h4F}
        rx_send_data = 8'h54;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h57;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h4F;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal

        #20;

        //"RUN" : {8'h52, 8'h55, 8'h4E}
        rx_send_data = 8'h52;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h55;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h4E;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal

        #20;

        //"rst" : {8'h72, 8'h73, 8'h74}
        rx_send_data = 8'h72;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h73;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h74;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal

        #20;

        //"RST" : {8'h52, 8'h53, 8'h54}
        rx_send_data = 8'h52;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h53;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal
        rx_send_data = 8'h54;
        send_data_to_rx(rx_send_data);
        wait (w_rx_done);  // wait signal

        $stop;
    end

    integer i = 0;
    // to 
    task send_data_to_rx(input [7:0] send_data);
        begin
            // uart rx start condition
            rx = 0;
            #(10416 * 10);
            // rx data lsb transfer
            for (i = 0; i < 8; i = i + 1) begin
                rx = send_data[i];
                #(10416 * 10);
            end
            rx = 1;
            #(10416 * 3);
            $display("send_data = %h", send_data);
        end
    endtask
endmodule
