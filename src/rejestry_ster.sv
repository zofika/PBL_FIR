`timescale 1ns/1ps

module ctrl_registers (
    input         clk_b,
    input         rst_n,

    input  [15:0] CDC_data,
    input  [2:0]  nr_Rejestru,
    input         wr_Rej,
    output reg [15:0] Rej_out,       // odczyt rejestru pod nr_Rejestru
    output reg        Start,
    input             Pracuje,
    input             DONE,
    output reg [5:0]  Ile_wsp,
    output reg [13:0] Ile_probek
);

    reg [15:0] rej [0:4]; // 5 rejestrów: 0=START,1=DONE,2=PRACUJE,3=ile_wsp,4=ile_probek

    reg done_reg;

    always @(posedge clk_b or negedge rst_n) begin
        if (!rst_n) begin
            Start      <= 1'b0;
            Ile_wsp    <= 6'd0;
            Ile_probek <= 14'd0;
            Rej_out    <= 16'd0;
            rej[0]     <= 16'd0;
            rej[1]     <= 16'd0;
            rej[2]     <= 16'd0;
            rej[3]     <= 16'd0;
            rej[4]     <= 16'd0;
        end else begin
            // zapis danych
            if (wr_Rej) begin
                case (nr_Rejestru)
                    3'b000: rej[0] <= CDC_data; // START
                    3'b011: rej[3] <= CDC_data; // ile_wsp
                    3'b100: rej[4] <= CDC_data; // ile_probek
                    default: ; // inne rejestry tylko do odczytu
                endcase
            end

            // aktualizacja wyjść rejestrów
            Start      <= rej[0][0];     // START sygnał 1-bit
            Ile_wsp    <= rej[3][5:0];   // 6-bit
            Ile_probek <= rej[4][13:0];  // 14-bit

            //Tutaj chyba musi byc cos takiego ze jak dostaniemy START = 1 to w kolejnym takcie go resetujemy?
            // if(Start) begin
            //     Start <= 1'b0;
            // end
            //to samo dla DONE jak fsm wystawi DONE (na 1 takt) to trzeba go zapisac. i reset jak START = 1.
            // done_reg <= DONE;
            // if(Start) begin
                
            // end
            /* No czyli START i DONE trzeba jakos ogarnac */

            // wyjście odczytu rejestru pod nr_Rejestru
            case (nr_Rejestru)
                3'b000: Rej_out <= {15'd0, Start};
                3'b001: Rej_out <= {15'd0, DONE};
                3'b010: Rej_out <= {15'd0, Pracuje};
                3'b011: Rej_out <= {10'd0, Ile_wsp};
                3'b100: Rej_out <= {2'd0, Ile_probek};
                default: Rej_out <= 16'd0;
            endcase
        end
    end

endmodule
