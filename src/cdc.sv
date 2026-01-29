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
    // REJESTRY - SYNCHRONIZERY (CDC bez handshake)
    // =================================================
    reg [5:0]  addr_sync1, addr_sync2;
    reg [15:0] data_sync1, data_sync2;
    reg        wr_sync1, wr_sync2;

    reg [15:0] data_back_sync1, data_back_sync2;

    // =================================================
    // DOMENA A – SYNCHRONIZACJA B → A (odczyt)
    // =================================================
    always @(posedge clk_a or negedge rst_n) begin
        if (!rst_n) begin
            data_back_sync1 <= 16'd0;
            data_back_sync2 <= 16'd0;
            p_data_back     <= 16'd0;
        end else begin
            data_back_sync1 <= data_back;
            data_back_sync2 <= data_back_sync1;
            p_data_back     <= data_back_sync2;
        end
    end

    // =================================================
    // DOMENA B – SYNCHRONIZACJA A → B (zapis, adres)
    // =================================================
    always @(posedge clk_b or negedge rst_n) begin
        if (!rst_n) begin
            addr_sync1  <= 6'd0;
            addr_sync2  <= 6'd0;
            data_sync1  <= 16'd0;
            data_sync2  <= 16'd0;
            wr_sync1    <= 1'b0;
            wr_sync2    <= 1'b0;

            CDC_A       <= 6'd0;
            CDC_data    <= 16'd0;
            CDC_wr      <= 1'b0;
        end else begin
            addr_sync1  <= p_address;
            addr_sync2  <= addr_sync1;
            data_sync1  <= p_data;
            data_sync2  <= data_sync1;
            wr_sync1    <= p_wr;
            wr_sync2    <= wr_sync1;

            CDC_A       <= addr_sync2;
            CDC_data    <= data_sync2;
            CDC_wr      <= wr_sync2;
        end
    end

endmodule
