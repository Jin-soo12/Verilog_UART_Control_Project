`timescale 1ns / 1ps

module Top_Module (
    input        clk,
    input        rst,
    input  [3:0] btn,
    input  [1:0] sw,
    input        rx,
    input        echo,
    output       trigger,
    output [3:0] led,
    output [2:0] L_R_Mode_led,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output       tx,
    inout        dht11_io
);

    wire w_rst, w_cu_rst;
    wire w_sens_state, w_ws_mode, w_rht_mode;
    wire [1:0] w_rs_state;
    wire w_tx_push, w_tx_full, w_rx_done;
    wire [7:0] w_tx_push_data, w_rx_pop_data, w_rx_data;
    wire [6:0] w_msec;
    wire [5:0] w_sec, w_min;
    wire [4:0] w_hour;
    wire [1:0] w_rx_sw;
    wire [3:0] w_rx_btn_watch, w_rx_btn_sr, w_rx_btn_dht;
    wire w_dist_done, w_dht_done;
    wire [9:0] w_sr_data;
    wire [7:0] w_rh_data, w_t_data;
    wire w_send_start;
    wire w_rx_empty, w_rx_pop;

    assign w_rst = (rst | w_cu_rst);
    assign w_send_start = (w_sens_state == 0) ? w_dist_done : w_dht_done;

    uart_controller U_UART_CON (
        .clk         (clk),
        .rst         (w_rst),
        .tx_push     (w_tx_push),
        .rx          (rx),
        .tx_push_data(w_tx_push_data),
        //.rx_data     (w_rx_data),
        .rx_pop      (w_rx_pop),
        .rx_empty    (w_rx_empty),
        //.rx_done     (w_rx_done),
        .rx_pop_data (w_rx_pop_data),
        .tx_full     (w_tx_full),
        //output       .tx_done(),
        //.tx_busy(),
        .tx          (tx)
    );

    ascii_sender U_ASCII_SEND (
        .clk         (clk),
        .rst         (w_rst),
        .sens_state  (w_sens_state),
        .i_sr_data   (w_sr_data),                   //distance in data
        .i_dht_data  (w_t_data * 100 + w_rh_data),  //dht in data
        .tx_full     (w_tx_full),
        .start       (w_send_start),                // done signal
        .tx_push     (w_tx_push),
        .tx_push_data(w_tx_push_data)
    );

    uart_cu U_UART_CU (
        .clk(clk),
        .rst(w_rst),
        .sw(sw),
        .btn(btn),
        .rx_empty(w_rx_empty),  //rx empty
        .rx_pop_data(w_rx_pop_data),
        //.rx_done(w_rx_done),        //나중에 주석
        //.rx_data(w_rx_data),
        .rs_state(w_rs_state),
        .rx_rst(w_cu_rst),
        .o_rx_sw(w_rx_sw),
        .rx_pop(w_rx_pop),
        .led(led),
        .sens_state(w_sens_state),  //for fnd sens_state DISTANSCE : 0, DHT : 1
        .ws_mode(w_ws_mode),
        .rht_mode(w_rht_mode),
        .o_rx_btn_watch(w_rx_btn_watch),
        .o_rx_btn_sr(w_rx_btn_sr),
        .o_rx_btn_dht(w_rx_btn_dht)
    );

    Top_Watch U_TOP_WATCH (
        .clk         (clk),
        .rst         (w_rst),
        .sw          (w_rx_sw),
        .rx_btn_data (w_rx_btn_watch),
        .L_R_Mode_led(L_R_Mode_led),
        .rs_state    (w_rs_state),
        .msec        (w_msec),
        .sec         (w_sec),
        .min         (w_min),
        .hour        (w_hour)
    );

    Top_SR04 U_TOP_SR (
        .clk       (clk),
        .rst       (w_rst),
        .btn_start (w_rx_btn_sr[0]),
        .echo      (echo),
        .trigger   (trigger),
        .dist_done (w_dist_done),     //to ascii sender
        .range_data(w_sr_data)        //to fnd
    );

    dht11_controller U_DHT_CON (
        .clk       (clk),
        .rst       (w_rst),
        .start     (w_rx_btn_dht[0]),
        .rh_data   (w_rh_data),        //to fnd
        .t_data    (w_t_data),         //to fnd
        .dht11_done(w_dht_done),       //to ascii sender
        //.valid     (),              
        //output [2:0] state_led,
        .dht11_io  (dht11_io)
    );

    fnd_controller U_FND_CON (
        .clk        (clk),
        .reset      (w_rst),
        .ws_mode    (w_ws_mode),     //watch or sensor mode
        .en         (w_rx_sw[0]),    // sw랑 똑같음
        .sensor_mode(w_sens_state),  // 초음파인지 온습도 센서인지.
        .rht_mode   (w_rht_mode),    // 온도인지 습도인지.
        .msec       (w_msec),
        .sec        (w_sec),
        .min        (w_min),
        .hour       (w_hour),
        .u_data     (w_sr_data),
        .rh_data    (w_rh_data),
        .t_data     (w_t_data),
        .fnd_data   (fnd_data),
        .fnd_com    (fnd_com)
    );
endmodule
