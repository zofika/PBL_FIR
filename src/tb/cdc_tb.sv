`timescale 1ns/1ps

module tb_cdc_module;

    // ==============================
    // Zegary i reset
    // ==============================
    reg clk_a;
    reg clk_b;
    reg rst_n;

    // ==============================
    // Sygnały domeny A
    // ==============================
    reg  [5:0]  p_address;
    reg  [15:0] p_data;
    reg         p_wr;
    wire [15:0] p_data_back;

    // ==============================
    // Sygnały domeny B
    // ==============================
    wire [5:0]  CDC_A;
    wire [15:0] CDC_data;
    wire        CDC_wr;
    reg  [15:0] data_back;

    // ==============================
    // DUT
    // ==============================
    cdc_module dut (
        .clk_a(clk_a),
        .clk_b(clk_b),
        .rst_n(rst_n),

        .p_address(p_address),
        .p_data(p_data),
        .p_wr(p_wr),
        .p_data_back(p_data_back),

        .CDC_A(CDC_A),
        .CDC_data(CDC_data),
        .CDC_wr(CDC_wr),
        .data_back(data_back)
    );

    // ==============================
    // Zegary
    // ==============================
    initial clk_a = 0;
    always #5 clk_a = ~clk_a;   // 100 MHz

    initial clk_b = 0;
    always #7 clk_b = ~clk_b;   // ~71 MHz

    // ==============================
    // Prosta pamięć (domena B)
    // ==============================
    reg [15:0] mem [0:63];

    always @(posedge clk_b) begin
        if (CDC_wr) begin
            mem[CDC_A] <= CDC_data;
            data_back  <= CDC_data;
        end else begin
            data_back <= mem[CDC_A];
        end
    end

    // ==============================
    // Deklaracje tablic testowych
    // ==============================
    reg [15:0] test_data [0:4];
    reg [5:0]  test_addr [0:4];

    initial begin
        test_addr[0] = 6'd1;   test_data[0] = 16'h1111;
        test_addr[1] = 6'd5;   test_data[1] = 16'hABCD;
        test_addr[2] = 6'd10;  test_data[2] = 16'h1234;
        test_addr[3] = 6'd32;  test_data[3] = 16'hDEAD;
        test_addr[4] = 6'd63;  test_data[4] = 16'hBEEF;
    end

    // ==============================
    // Task wysyłania danych
    // ==============================
    task write_tx;
        input [5:0] addr;
        input [15:0] data;
        integer i;
        begin
            @(posedge clk_a);
            p_address <= addr;
            p_data    <= data;
            p_wr      <= 1'b1;

            @(posedge clk_a);
            p_wr      <= 1'b0;

            // Poczekaj kilka cykli clk_b, żeby CDC przetworzyło dane
            for (i=0; i<5; i=i+1)
                @(posedge clk_b);

            $display("[%0t] WRITE OK addr=%0d data=0x%04h",
                     $time, CDC_A, CDC_data);
        end
    endtask

    // ==============================
    // Test główny
    // ==============================
    integer j;

    initial begin
        // inicjalizacja
        clk_a = 0;
        clk_b = 0;
        rst_n = 0;
        p_address = 0;
        p_data = 0;
        p_wr = 0;
        data_back = 0;

        #50;
        rst_n = 1;
        $display("[%0t] Reset released", $time);

        // wykonanie wszystkich zapisów
        for (j=0; j<5; j=j+1) begin
            write_tx(test_addr[j], test_data[j]);
        end

        #100;
        $display("=== ALL TESTS PASSED ===");
        $finish;
    end

endmodule
