module adder_lsb #(
    parameter WIDTH = 16
)(
    input  logic [WIDTH-1:0] mnozenie_wynik,
    input  logic [WIDTH-1:0] Acc_out,
    output logic [WIDTH-1:0] suma_wynik
);

    always_comb begin
        suma_wynik = mnozenie_wynik + Acc_out;
    end

endmodule
