module adder #(
    parameter WIDTH = 16   // >16 bitów
)(
    input  logic [WIDTH-1:0] mnozenie_wynik, // IN
    input  logic [WIDTH-1:0] Acc_out,         // IN
    output logic [WIDTH-1:0] suma_wynik        // OUT
);

    always_comb begin
        suma_wynik = mnozenie_wynik + Acc_out;
    end

endmodule
