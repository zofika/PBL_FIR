

module testy_fir_tb;

logic clk;
logic rst_n;

// ===== Sterowanie =====
logic START;

logic pracuje;
logic DONE;
logic FSM_wyj_wr;


// ===== MUX =====
logic FSM_MUX_wyj;
logic FSM_MUX_wej;
logic FSM_MUX_CDC;

// ===== Licznik współczynników =====
logic FSM_zapisz_wsp;
logic FSM_petla_en;
logic FSM_reset_petla;
logic Petla_full;

// ===== Licznik próbek =====
logic FSM_zapisz_probki;
logic FSM_reset_licznik;
logic Licznik_full;
logic FSM_nowa_probka;

// ===== Shift =====
logic FSM_nowa_shift;
logic FSM_reset_shift;

// ===== Acc =====
logic FSM_Acc_en;
logic FSM_Acc_zapisz;
logic FSM_reset_Acc;

logic [15:0] mnozenie_wynik;
logic [15:0] Acc_out;
logic [15:0] suma_wynik;
localparam WIDTH = 16;
//dod
adder #(
    .WIDTH(WIDTH)   // >16 bitów
) u_adder (
    .mnozenie_wynik(mnozenie_wynik),// IN
    .Acc_out(Acc_out),         // IN
    .suma_wynik(suma_wynik)        // OUT 
);

fsm u_fsm (
    .clk(clk),
    .rst_n(rst_n),

    // ===== Sterowanie =====
    .START(START),

    .pracuje(pracuje),
    .DONE(DONE),
    .FSM_wyj_wr(FSM_wyj_wr),


    // ===== MUX =====
    .FSM_MUX_wyj(FSM_MUX_wyj),
    .FSM_MUX_wej(FSM_MUX_wej),
    .FSM_MUX_CDC(FSM_MUX_CDC),

    // ===== Licznik współczynników =====
    .FSM_zapisz_wsp(FSM_zapisz_wsp),
    .FSM_petla_en(FSM_petla_en),
    .FSM_reset_petla(FSM_reset_petla),
    .Petla_full(Petla_full),

    // ===== Licznik próbek =====
    .FSM_zapisz_probki(FSM_zapisz_probki),
    .FSM_reset_licznik(FSM_reset_licznik),
    .Licznik_full(Licznik_full),
    .FSM_nowa_probka(FSM_nowa_probka),

    // ===== Shift =====
    .FSM_nowa_shift(FSM_nowa_shift),
    .FSM_reset_shift(FSM_reset_shift),

    // ===== Acc =====
    .FSM_Acc_en(FSM_Acc_en),
    .FSM_Acc_zapisz(FSM_Acc_zapisz),
    .FSM_reset_Acc(FSM_reset_Acc)
);

initial clk = 1;
always #5 clk = ~clk;

initial begin
    $dumpfile("testy_fir_tb.vcd");
    $dumpvars(0, testy_fir_tb);
end

initial begin
    Acc_out = 0;
    mnozenie_wynik = 0;

    rst_n = 0;
    START = 0;
    Licznik_full = 0;
    Petla_full = 0;
    #10;
    rst_n = 1;
    #40;
    //testg
    //jest start
    START = 1;
    #10;
    START = 0; //czyli w apb proramista musi wyzerowac potem ten START. odpalil raz potem ustawia start na 0.
    //albo u nas to sie dzieje jakos...
    #40; //petla sie robi iles razy (licznik petla)
    Petla_full = 1;
    #20; //po 2 jest reset licznika petli
    Petla_full = 0;
    #30;
    Petla_full = 1;
    Licznik_full = 1;

    #100;
    Acc_out = 100;
    mnozenie_wynik = 50;


    #500;
    $finish;
end


endmodule