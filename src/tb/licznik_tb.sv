`timescale 1ns/1ps

module tb_counter_module;

    reg clk_b;
    reg rst_n;

    reg [13:0] ile_probek;
    reg        FSM_zapisz_probki;
    reg        FSM_reset_licznik;
    reg        FSM_nowa_probka;

    wire [12:0] A_probki_FIR;
    wire        licznik_full;

    counter_module dut (
        .clk_b(clk_b),
        .rst_n(rst_n),
        .ile_probek(ile_probek),
        .FSM_zapisz_probki(FSM_zapisz_probki),
        .FSM_reset_licznik(FSM_reset_licznik),
        .FSM_nowa_probka(FSM_nowa_probka),
        .A_probki_FIR(A_probki_FIR),
        .licznik_full(licznik_full)
    );

    initial clk_b = 0;
    always #5 clk_b = ~clk_b; // 100 MHz

    initial begin
        // inicjalizacja
        rst_n = 0;
        ile_probek = 14'd10;
        FSM_zapisz_probki = 0;
        FSM_reset_licznik = 0;
        FSM_nowa_probka = 0;

        #20;
        rst_n = 1;
        $display("[%0t] Reset released", $time);

        // ustawienie max liczby próbek
        #10;
        FSM_zapisz_probki = 1;
        #10;
        FSM_zapisz_probki = 0;

        // reset licznika
        #10;
        FSM_reset_licznik = 1;
        #10;
        FSM_reset_licznik = 0;

        // inkrementacja licznika
        repeat (12) begin
            #10;
            FSM_nowa_probka = 1;
            #10;
            FSM_nowa_probka = 0;
            #10;
            $display("[%0t] A_probki_FIR=%0d licznik_full=%b",
                     $time, A_probki_FIR, licznik_full);
        end

        #20;
        $display("=== TEST FINISHED ===");
        $finish;
    end

endmodule
