`timescale 1ns / 1ps

module uart_cu (
    input        clk,
    input        rst,
    input  [1:0] sw,
    input  [3:0] btn,
    input        rx_empty,        //rx empty
    input  [7:0] rx_pop_data,     //rx pop data
    //input        rx_done,
    //input  [7:0] rx_data,
    input  [1:0] rs_state,
    output       rx_pop,
    output [3:0] led,
    output       rx_rst,
    output [1:0] o_rx_sw,
    output       sens_state,
    output       ws_mode,
    output       rht_mode,
    output [3:0] o_rx_btn_watch,
    output [3:0] o_rx_btn_sr,
    output [3:0] o_rx_btn_dht
);
    parameter IDLE = 0, WATCH_SEL = 1, SENEOR_SEL = 2, WATCH = 3, STOP_WATCH = 4, DISTANCE = 5, DHT = 6, WAIT = 7, RESET = 8;

    parameter UP = 4'b0001, LEFT = 4'b0010, RIGHT = 4'b0100, DOWN = 4'b1000, NONE = 4'b0000;

    parameter MSEC_SEC = 0, MIN_HOUR = 1;

    parameter STOP = 2'b00, RUN = 2'b10, CLEAR = 2'b01;

    parameter G = 24'h52554E;  // "RUN" : {8'h52, 8'h55, 8'h4E}
    parameter S = 24'h535450;  // "STP" : {8'h53, 8'h54, 8'h50}
    parameter C = 24'h434C52;  // "CLR" : {8'h43, 8'h4C, 8'h52}
    parameter U = 24'h494E43;  // "INC" : {8'h49, 8'h4E, 8'h43}
    parameter D = 24'h444543;  // "DEC" : {8'h44, 8'h45, 8'h43}
    parameter L = 24'h4C4654;  // "LFT" : {8'h4C, 8'h46, 8'h54}
    parameter R = 24'h524754;  // "RGT" : {8'h52, 8'h47, 8'h54}
    parameter m = 24'h535750;  // "SWP" : {8'h53, 8'h57, 8'h50}
    parameter n = 24'h4D4458;  // "MDX" : {8'h4D, 8'h44, 8'h58}
    parameter esc = 24'h525354;  // "RST" : {8'h52, 8'h53, 8'h54}
    parameter one = 24'h4F4E45;  // "ONE" : {8'h4F, 8'h4E, 8'h45}
    parameter two = 24'h54574F;  // "TWO" : {8'h54, 8'h57, 8'h4F}
    parameter a = 24'h434C4B;  // "CLK" : {8'h43, 8'h4C, 8'h4B}
    parameter b = 24'h534E52;  // "SNR" : {8'h53, 8'h4E, 8'h52}

    parameter BTN_COUNT = 50000;

    reg [3:0] c_state, n_state;
    reg c_sw_0_state, n_sw_0_state;
    reg [$clog2(BTN_COUNT) - 1:0] b_cnt_reg, b_cnt_next;
    reg [3:0]
        btn_watch_reg,
        btn_watch_next,
        btn_sr_reg,
        btn_sr_next,
        btn_dht_reg,
        btn_dht_next;
    reg sw_0_d, sw_1_d;
    reg [3:0] state_back_reg, state_back_next;
    reg sw_1_state, sw_1_next;
    reg sens_state_reg, sens_state_next;
    reg ws_mode_reg, ws_mode_next;
    reg rht_mode_reg, rht_mode_next;
    reg rx_rst_reg, rx_rst_next;
    reg [23:0] cu_data_reg, cu_data_next;
    reg [1:0] data_cnt_reg, data_cnt_next;
    reg data_state_reg, data_state_next;
    reg rx_done_reg, rx_done_next;
    reg rx_pop_reg, rx_pop_next;

    wire sw_0_posedge, sw_0_negedge, sw_1_posedge, sw_1_negedge;

    assign o_rx_btn_watch = (btn | btn_watch_reg);
    assign o_rx_btn_sr = (btn | btn_sr_reg);
    assign o_rx_btn_dht = (btn | btn_dht_reg);
    assign sw_0_posedge = sw[0] & ~sw_0_d;
    assign sw_0_negedge = ~sw[0] & sw_0_d;
    assign sw_1_posedge = sw[1] & ~sw_1_d;
    assign sw_1_negedge = ~sw[1] & sw_1_d;
    assign sens_state = sens_state_reg;
    assign ws_mode = ws_mode_reg;
    assign rht_mode = rht_mode_reg;
    assign rx_rst = rx_rst_reg;
    assign o_rx_sw = {sw_1_state, c_sw_0_state};
    assign led = c_state;
    assign rx_pop = rx_pop_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state        <= 0;
            b_cnt_reg      <= 0;
            btn_watch_reg  <= 0;
            sw_0_d         <= 0;
            sw_1_d         <= 0;
            c_sw_0_state   <= MSEC_SEC;
            sw_1_state     <= 0;
            state_back_reg <= 0;
            btn_sr_reg     <= 0;
            btn_dht_reg    <= 0;
            sens_state_reg <= 0;
            ws_mode_reg    <= 0;
            rht_mode_reg   <= 0;
            rx_rst_reg     <= 0;
            data_cnt_reg   <= 0;
            cu_data_reg    <= 0;
            data_state_reg <= 0;
            rx_done_reg    <= 0;
            rx_pop_reg     <= 0;
        end else begin
            c_state        <= n_state;
            b_cnt_reg      <= b_cnt_next;
            btn_watch_reg  <= btn_watch_next;
            sw_0_d         <= sw[0];
            sw_1_d         <= sw[1];
            c_sw_0_state   <= n_sw_0_state;
            sw_1_state     <= sw_1_next;
            state_back_reg <= state_back_next;
            btn_sr_reg     <= btn_sr_next;
            btn_dht_reg    <= btn_dht_next;
            sens_state_reg <= sens_state_next;
            ws_mode_reg    <= ws_mode_next;
            rht_mode_reg   <= rht_mode_next;
            rx_rst_reg     <= rx_rst_next;
            data_cnt_reg   <= data_cnt_next;
            cu_data_reg    <= cu_data_next;
            data_state_reg <= data_state_next;
            rx_done_reg    <= rx_done_next;
            rx_pop_reg     <= rx_pop_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        b_cnt_next = b_cnt_reg;
        btn_watch_next = btn_watch_reg;
        state_back_next = state_back_reg;
        btn_sr_next = btn_sr_reg;
        btn_dht_next = btn_dht_reg;
        n_sw_0_state = c_sw_0_state;
        sw_1_next = sw_1_state;
        sens_state_next = sens_state_reg;
        ws_mode_next = ws_mode_reg;
        rht_mode_next = rht_mode_reg;
        rx_rst_next = rx_rst_reg;
        data_cnt_next = data_cnt_reg;
        cu_data_next = cu_data_reg;
        data_state_next = data_state_reg;
        rx_done_next = rx_done_reg;
        rx_pop_next = rx_pop_reg;

        case (data_state_reg)
            0: begin
                rx_done_next = 0;
                rx_pop_next  = 0;
                if (~rx_empty) begin
                    data_state_next = 1;
                    data_cnt_next = 0;
                    rx_pop_next = 1;
                end
            end
            1: begin
                if (data_cnt_reg == 3) begin
                    data_state_next = 0;
                    rx_done_next = 1;
                    rx_pop_next = 0;
                end
                if (~rx_empty) begin
                    case (data_cnt_reg)
                        0: cu_data_next[23:16] = rx_pop_data;
                        1: cu_data_next[15:8] = rx_pop_data;
                        2: cu_data_next[7:0] = rx_pop_data;
                    endcase
                    data_cnt_next = data_cnt_reg + 1;
                end
            end
        endcase

        case (c_state)
            IDLE: begin
                rx_rst_next = 0;
                if (cu_data_reg == a && rx_done_reg == 1) begin
                    n_state = WATCH_SEL;
                end else if (cu_data_reg == b && rx_done_reg == 1) begin
                    n_state = SENEOR_SEL;
                end else if (cu_data_reg == esc && rx_done_reg) begin
                    n_state = RESET;
                end else begin
                    n_state = IDLE;
                end
            end
            WATCH_SEL: begin
                ws_mode_next = 0;
                if (cu_data_reg == b && rx_done_reg == 1) begin
                    n_state = SENEOR_SEL;
                end else if (cu_data_reg == one && rx_done_reg == 1) begin
                    n_state = WATCH;
                end else if (cu_data_reg == two && rx_done_reg == 1) begin
                    n_state = STOP_WATCH;
                end else if (cu_data_reg == esc && rx_done_reg) begin
                    n_state = RESET;
                end else begin
                    n_state = WATCH_SEL;
                end
            end
            SENEOR_SEL: begin
                ws_mode_next = 1;
                if (cu_data_reg == a && rx_done_reg == 1) begin
                    n_state = WATCH_SEL;
                end else if (cu_data_reg == one && rx_done_reg == 1) begin
                    n_state = DISTANCE;
                end else if (cu_data_reg == two && rx_done_reg == 1) begin
                    n_state = DHT;
                end else if (cu_data_reg == esc && rx_done_reg) begin
                    n_state = RESET;
                end else begin
                    n_state = SENEOR_SEL;
                end
            end
            WATCH: begin
                sw_1_next = 0;
                if (cu_data_reg == a && rx_done_reg == 1) begin
                    n_state = WATCH_SEL;
                end else if (cu_data_reg == b && rx_done_reg == 1) begin
                    n_state = SENEOR_SEL;
                end else if (cu_data_reg == n && rx_done_reg == 1) begin
                    n_state = STOP_WATCH;
                end else if (cu_data_reg == m && rx_done_reg == 1) begin
                    n_sw_0_state = ~c_sw_0_state;
                end else if (cu_data_reg == U && rx_done_reg == 1) begin
                    n_state = WAIT;
                    btn_watch_next = UP;
                    state_back_next = WATCH;
                end else if (cu_data_reg == L && rx_done_reg == 1) begin
                    n_state = WAIT;
                    btn_watch_next = LEFT;
                    state_back_next = WATCH;
                end else if (cu_data_reg == R && rx_done_reg == 1) begin
                    n_state = WAIT;
                    btn_watch_next = RIGHT;
                    state_back_next = WATCH;
                end else if (cu_data_reg == D && rx_done_reg == 1) begin
                    n_state = WAIT;
                    btn_watch_next = DOWN;
                    state_back_next = WATCH;
                end else if (cu_data_reg == esc && rx_done_reg) begin
                    n_state = RESET;
                end else if (sw_1_posedge) begin
                    n_state = STOP_WATCH;
                end
                case (c_sw_0_state)
                    MSEC_SEC: begin
                        if (sw_0_posedge) begin
                            n_sw_0_state = MIN_HOUR;
                        end
                    end
                    MIN_HOUR: begin
                        if (sw_0_negedge) begin
                            n_sw_0_state = MSEC_SEC;
                        end
                    end
                endcase
            end
            STOP_WATCH: begin
                sw_1_next = 1;
                if (cu_data_reg == a && rx_done_reg == 1) begin
                    n_state = WATCH_SEL;
                end else if (cu_data_reg == b && rx_done_reg == 1) begin
                    n_state = SENEOR_SEL;
                end else if (cu_data_reg == n && rx_done_reg == 1) begin
                    n_state = WATCH;
                end else if (cu_data_reg == m && rx_done_reg == 1) begin
                    n_sw_0_state = ~c_sw_0_state;
                end else if (cu_data_reg == esc && rx_done_reg) begin
                    n_state = RESET;
                end else if (sw_1_negedge) begin
                    n_state = WATCH;
                end
                case (rs_state)
                    STOP: begin
                        if (cu_data_reg == G && rx_done_reg) begin
                            btn_watch_next = RIGHT;
                            n_state = WAIT;
                            state_back_next = STOP_WATCH;
                        end else if (cu_data_reg == C && rx_done_reg) begin
                            btn_watch_next = LEFT;
                            n_state = WAIT;
                            state_back_next = STOP_WATCH;
                        end
                    end
                    RUN: begin
                        if (cu_data_reg == S && rx_done_reg) begin
                            btn_watch_next = RIGHT;
                            n_state = WAIT;
                            state_back_next = STOP_WATCH;
                        end
                    end
                    CLEAR: begin
                        if (cu_data_reg == S && rx_done_reg) begin
                            btn_watch_next = LEFT;
                            n_state = WAIT;
                            state_back_next = STOP_WATCH;
                        end
                    end
                endcase
                case (c_sw_0_state)
                    MSEC_SEC: begin
                        if (sw_0_posedge) begin
                            n_sw_0_state = MIN_HOUR;
                        end
                    end
                    MIN_HOUR: begin
                        if (sw_0_negedge) begin
                            n_sw_0_state = MSEC_SEC;
                        end
                    end
                endcase
            end
            DISTANCE: begin
                sens_state_next = 0;
                if (cu_data_reg == a && rx_done_reg == 1) begin
                    n_state = WATCH_SEL;
                end else if (cu_data_reg == b && rx_done_reg == 1) begin
                    n_state = SENEOR_SEL;
                end else if (cu_data_reg == G && rx_done_reg == 1) begin
                    btn_sr_next = UP;
                    n_state = WAIT;
                    state_back_next = DISTANCE;
                end else if (cu_data_reg == n && rx_done_reg) begin
                    n_state = DHT;
                end else if (cu_data_reg == esc && rx_done_reg) begin
                    n_state = RESET;
                end
            end
            DHT: begin
                sens_state_next = 1;
                if (cu_data_reg == a && rx_done_reg == 1) begin
                    n_state = WATCH_SEL;
                end else if (cu_data_reg == b && rx_done_reg == 1) begin
                    n_state = SENEOR_SEL;
                end else if (cu_data_reg == G && rx_done_reg == 1) begin
                    btn_dht_next = UP;
                    n_state = WAIT;
                    state_back_next = DHT;
                end else if (cu_data_reg == n && rx_done_reg) begin
                    n_state = DISTANCE;
                end else if (cu_data_reg == esc && rx_done_reg) begin
                    n_state = RESET;
                end else if (cu_data_reg == m && rx_done_reg) begin
                    rht_mode_next = ~rht_mode_reg;
                end
            end
            WAIT: begin
                if (cu_data_reg == esc && rx_done_reg) begin
                    n_state = RESET;
                end else if (b_cnt_reg == BTN_COUNT - 1) begin
                    n_state = state_back_reg;
                    btn_watch_next = NONE;
                    btn_sr_next = NONE;
                    btn_dht_next = NONE;
                    b_cnt_next = 0;
                end else begin
                    b_cnt_next = b_cnt_reg + 1;
                end
            end
            RESET: begin
                rx_rst_next = 1;
                n_state = IDLE;
            end
        endcase
    end
endmodule
