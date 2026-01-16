module adder #(
    parameter WIDTH = 21   // >16 bitów
)(
    input logic [15:0] mnozenie_wynik, // IN   //[WIDTH-1:0] logic
    input logic [WIDTH-1:0] Acc_out,         // IN            logic
    output logic [WIDTH-1:0] suma_wynik        // OUT 
);
    //wyn mnozenia jest 32 bity ale do adder wchodzi tylko 16 najstarszych(odpowiednich bitów)
    //mnozenie wyn jest 16 bit a my tu dod 21 bitowe
    //wire [20:0] xd; 
    //assign xd = {{5{mnozenie_wynik[15]}}, mnozenie_wynik};
    always_comb begin
        suma_wynik = mnozenie_wynik + Acc_out;//xd + Acc_out; //powtorzony znak do 21bitow//{{5{mnozenie_wynik[15]}}, mnozenie_wynik} + Acc_out; //powtorzony znak do 21bitow  mnozenie_wynik + Acc_out;
    end

endmodule
