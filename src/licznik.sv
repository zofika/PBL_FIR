`timescale 1ns/1ps

module counter_module (
    input        clk_b,
    input        rst_n,
    // input  [13:0] ile_probek,        // max liczba próbek
    input  [14:0] ile_razy,        // max liczba próbek
    input         FSM_zapisz_probki, // ustaw max licznik
    input         FSM_reset_licznik, // reset licznika
    input         FSM_nowa_probka,   // inkrementacja licznika
    //tutaj ile wsp jeszce
    output reg [12:0] A_probki_FIR,  // aktualny adres próbki
    //dla ram wyj
    output logic [12:0] A_probki_wyn_FIR,

    output reg        licznik_full    // flaga osiągnięcia max
);
    // reg [13:0] max_probek;
    reg [14:0] max_ile_razy;

    always @(posedge clk_b or negedge rst_n) begin
        if (!rst_n) begin
            A_probki_FIR <= 13'd0;
            A_probki_wyn_FIR <= 13'd0;
            max_ile_razy   <= '0;
            licznik_full <= 1'b0;
        end else begin
            // ustawienie max liczby próbek
            if (FSM_zapisz_probki)
                max_ile_razy <= ile_razy; //Tutaj nie ile probek a (ile probek + ile wsp) - 1    max_probek <= ile_probek[12:0]; (albo to w rejestry_ster)

            // reset licznika
            if (FSM_reset_licznik) begin
                A_probki_FIR <= 13'd0;
                A_probki_wyn_FIR <= 13'd0;
                licznik_full <= 1'b0;//reset tutaj tez
            end
            else if (FSM_nowa_probka) begin
                if (A_probki_FIR < max_ile_razy - 1'b1) begin   //if (A_probki_FIR < max_probek) begin  if (A_probki_FIR != max_probek - 1'b1) begin 
                    A_probki_FIR <= A_probki_FIR + 1'b1;
                    licznik_full <= 1'b0;
                end else begin
                    licznik_full <= 1'b1;
                    A_probki_FIR <= 13'd0;
                end
            end
            //ten asdres dla ram wyn poprostu opoxniony o 1 takt wzgledem a_probki_fir i wszystko dziala
            A_probki_wyn_FIR <= A_probki_FIR;
        end
    end

endmodule
