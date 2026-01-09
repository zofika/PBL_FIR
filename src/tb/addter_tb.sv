`timescale 1ns/1ps

module tb_adder_16;

    localparam WIDTH = 16;

    logic [WIDTH-1:0] mnozenie_wynik;
    logic [WIDTH-1:0] Acc_out;
    logic [WIDTH-1:0] suma_wynik;

    adder #(.WIDTH(WIDTH)) uut (
        .mnozenie_wynik(mnozenie_wynik),
        .Acc_out(Acc_out),
        .suma_wynik(suma_wynik)
    );

    initial begin
        // test 1
        mnozenie_wynik = 16'd10;
        Acc_out        = 16'd5;
        #10;
        $display("10 + 5 = %0d", suma_wynik);

        // test 2
        mnozenie_wynik = 16'd200;
        Acc_out        = 16'd55;
        #10;
        $display("200 + 55 = %0d", suma_wynik);

        // test 3 (granica 16 bitów)
        mnozenie_wynik = 16'd60000;
        Acc_out        = 16'd500;
        #10;
        $display("60000 + 500 = %0d", suma_wynik);

        $finish;
    end

endmodule
