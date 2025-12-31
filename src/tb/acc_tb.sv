`timescale 1ns/1ps

module tb_acc_module;

    // =========================
    // Zegary i reset
    // =========================
    reg clk_b;
    reg rst_n;

    // =========================
    // Wejścia Acc
    // =========================
    reg FSM_Acc_en;
    reg FSM_Acc_zapis;
    reg FSM_reset_Acc;
    reg [20:0] suma_wynik;

    // =========================
    // Wyjścia Acc
    // =========================
    wire [20:0] Acc_out;
    wire [20:0] FIR_probka_wynik;

    // =========================
    // DUT
    // =========================
    acc_module dut (
        .clk_b(clk_b),
        .rst_n(rst_n),
        .FSM_Acc_en(FSM_Acc_en),
        .FSM_Acc_zapis(FSM_Acc_zapis),
        .FSM_reset_Acc(FSM_reset_Acc),
        .suma_wynik(suma_wynik),
        .Acc_out(Acc_out),
        .FIR_probka_wynik(FIR_probka_wynik)
    );

    // =========================
    // Zegar
    // =========================
    initial clk_b = 0;
    always #5 clk_b = ~clk_b; // 100 MHz

    // =========================
    // Test
    // =========================
    initial begin
        // inicjalizacja
        rst_n = 0;
        FSM_Acc_en = 0;
        FSM_Acc_zapis = 0;
        FSM_reset_Acc = 0;
        suma_wynik = 21'd0;

        #20;
        rst_n = 1;
        $display("[%0t] Reset released", $time);

        // test resetu akumulatora
        #10;
        FSM_reset_Acc = 1;
        #10;
        FSM_reset_Acc = 0;
        $display("[%0t] Acc_out after reset = %0d", $time, Acc_out);

        // test działania Acc
        #10;
        suma_wynik = 21'd5;
        FSM_Acc_en = 1;
        repeat (3) begin
            #10;
            suma_wynik = suma_wynik + 1; // 5,6,7
            #10;
            $display("[%0t] Acc_out=%0d", $time, Acc_out);
        end
        FSM_Acc_en = 0;

        // zapis wyniku do FIR
        #10;
        FSM_Acc_zapis = 1;
        #10;
        FSM_Acc_zapis = 0;
        $display("[%0t] FIR_probka_wynik=%0d", $time, FIR_probka_wynik);

        #20;
        $display("=== ACC TEST FINISHED ===");
        $finish;
    end

endmodule
