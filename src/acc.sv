`timescale 1ns/1ps

module acc_module (
    input        clk_b,
    input        rst_n,

    input        FSM_Acc_en,       // włączenie Acc
    input        FSM_Acc_zapis,    // zapisz wartość do FIR_probka_wynik
    input        FSM_reset_Acc,    // reset Acc
    input  [20:0] suma_wynik,      // nowa wartość do dodania

    output reg [20:0] Acc_out,         // aktualna wartość akumulatora
    output reg [20:0] FIR_probka_wynik // wynik do wyjścia
);

    always @(posedge clk_b or negedge rst_n) begin
        if (!rst_n) begin
            Acc_out          <= 21'd0;
            FIR_probka_wynik <= 21'd0;
        end else begin
            // reset akumulatora
            if (FSM_reset_Acc)
                Acc_out <= 21'd0;
            // inkrementacja akumulatora jeśli włączony
            else if (FSM_Acc_en)
                Acc_out <= Acc_out + suma_wynik;

            // zapis wyniku do FIR
            if (FSM_Acc_zapis)
                FIR_probka_wynik <= Acc_out;
        end
    end

endmodule
