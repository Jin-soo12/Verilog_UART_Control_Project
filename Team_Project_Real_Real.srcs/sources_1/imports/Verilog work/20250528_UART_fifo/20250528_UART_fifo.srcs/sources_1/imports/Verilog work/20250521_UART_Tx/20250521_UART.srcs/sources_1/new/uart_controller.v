`timescale 1ns / 1ps

module uart_controller (
    input        clk,
    input        rst,
    input        tx_push,
    input        rx,
    input  [7:0] tx_push_data,
    input        rx_pop,
    output [7:0] rx_data,
    output       rx_empty,
    output       rx_done,
    output [7:0] rx_pop_data,
    output       tx_full,
    //output       tx_done,
    output       tx_busy,
    output       tx
);

    wire w_bd_tick, w_tx_busy, w_tx_empty;
    wire [7:0] w_rx_data, w_tx_pop_data;
    wire w_rx_done;

    assign rx_done = w_rx_done;
    assign rx_data = w_rx_data;
    assign tx_busy = w_tx_busy;

    baudrate U_BR (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_bd_tick)
    );
    fifo U_FIFIO_TX (
        .clk      (clk),
        .rst      (rst),
        .push     (tx_push),       //push
        .pop      (~w_tx_busy),
        .push_data(tx_push_data),
        .full     (tx_full),
        .empty    (w_tx_empty),
        .pop_data (w_tx_pop_data)
    );
    uart_tx U_UART_TX (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_bd_tick),
        .start((~w_tx_empty)),
        .din(w_tx_pop_data),
        .o_tx_busy(w_tx_busy),
        //.o_tx_done(tx_done),
        .o_tx(tx)
    );

    fifo U_FIFIO_RX (
        .clk      (clk),
        .rst      (rst),
        .push     (w_rx_done),
        .pop      (rx_pop),      //rx fifo
        .push_data(w_rx_data),
        .full     (),
        .empty    (rx_empty),    //rx fifo empty
        .pop_data (rx_pop_data)
    );

    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .b_tick(w_bd_tick),
        .rx(rx),
        .o_dout(w_rx_data),
        .o_rx_done(w_rx_done)
    );
endmodule
