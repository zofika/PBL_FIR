`timescale 1ns/1ps

module tb_multiplier;

    logic [15:0] shift_out;
    logic [15:0] wsp_data;
    logic [31:0] mnozenie_wynik;

    multiplier uut (
        .shift_out(shift_out),
        .wsp_data(wsp_data),
        .mnozenie_wynik(mnozenie_wynik)
    );

    initial begin
        // test 1
        shift_out = 16'd5;
        wsp_data  = 16'd3;
        #10;
        $display("5 * 3 = %0d", mnozenie_wynik);

        // test 2
        shift_out = 16'd100;
        wsp_data  = 16'd20;
        #10;
        $display("100 * 20 = %0d", mnozenie_wynik);

        // test 3 (większe wartości)
        shift_out = 16'd30000;
        wsp_data  = 16'd2;
        #10;
        $display("30000 * 2 = %0d", mnozenie_wynik);

        $finish;
    end

endmodule
