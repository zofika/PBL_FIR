`timescale 1ns/1ps

module cdc_module (
    // ===== Domena A =====
    input        clk_a,
    input        rst_n,

    input  [5:0]  p_address,
    input  [15:0] p_data,
    input         p_wr,
    output reg [15:0] p_data_back,

    // ===== Domena B =====
    input        clk_b,

    output reg [5:0]  CDC_A,
    output reg [15:0] CDC_data,
    output reg        CDC_wr,
    input      [15:0] data_back
);

    // =================================================
    // REJESTRY
    // =================================================
    reg req_a;
    reg ack_a_sync1, ack_a_sync2;

    reg [5:0]  addr_a_reg;
    reg [15:0] data_a_reg;
    reg        wr_a_reg;

    reg req_b_sync1, req_b_sync2;
    reg ack_b;

    reg [15:0] data_back_reg;
    reg [15:0] data_back_a;   // <<< B → A synchronizacja

    // =================================================
    // DOMENA A – WYSYŁANIE
    // =================================================
    always @(posedge clk_a or negedge rst_n) begin
        if (!rst_n) begin
            req_a       <= 1'b0;
            addr_a_reg  <= 6'd0;
            data_a_reg  <= 16'd0;
            wr_a_reg    <= 1'b0;
            p_data_back <= 16'd0;
        end else begin
            if (p_wr && !req_a) begin
                addr_a_reg <= p_address;
                data_a_reg <= p_data;
                wr_a_reg   <= p_wr;
                req_a      <= 1'b1;
            end

            if (ack_a_sync2) begin
                req_a       <= 1'b0;
                p_data_back <= data_back_a;
            end
        end
    end

    // =================================================
    // SYNC ACK (B → A)
    // =================================================
    always @(posedge clk_a or negedge rst_n) begin
        if (!rst_n) begin
            ack_a_sync1 <= 1'b0;
            ack_a_sync2 <= 1'b0;
        end else begin
            ack_a_sync1 <= ack_b;
            ack_a_sync2 <= ack_a_sync1;
        end
    end

    // =================================================
    // PRZENIESIENIE DANYCH (B → A)
    // =================================================
    always @(posedge clk_a or negedge rst_n) begin
        if (!rst_n)
            data_back_a <= 16'd0;
        else if (ack_a_sync2)
            data_back_a <= data_back_reg;
    end

    // =================================================
    // SYNC REQ (A → B)
    // =================================================
    always @(posedge clk_b or negedge rst_n) begin
        if (!rst_n) begin
            req_b_sync1 <= 1'b0;
            req_b_sync2 <= 1'b0;
        end else begin
            req_b_sync1 <= req_a;
            req_b_sync2 <= req_b_sync1;
        end
    end

    // =================================================
    // DOMENA B – ODBIÓR
    // =================================================
    always @(posedge clk_b or negedge rst_n) begin
        if (!rst_n) begin
            CDC_A         <= 6'd0;
            CDC_data      <= 16'd0;
            CDC_wr        <= 1'b0;
            ack_b         <= 1'b0;
            data_back_reg <= 16'd0;
        end else begin
            if (req_b_sync2 && !ack_b) begin
                CDC_A         <= addr_a_reg;
                CDC_data      <= data_a_reg;
                CDC_wr        <= wr_a_reg;
                data_back_reg <= data_back;
                ack_b         <= 1'b1;
            end else if (!req_b_sync2) begin
                ack_b  <= 1'b0;
                CDC_wr <= 1'b0;
            end
        end
    end

endmodule
