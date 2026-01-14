

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

logic [15:0] mnozenie_wynik_adder;
logic [20:0] Acc_out;
logic [20:0] suma_wynik;
localparam WIDTH = 21;

logic [15:0] shift_out;      // IN
logic [15:0] wsp_data;           // IN
logic [31:0] mnozenie_wynik;   //[31:0] 
logic [20:0] fir_probka_wynik;


logic [5:0] wsp;
wire [4:0] adres_FIR;
logic [13:0] ile_probek;
logic [12:0] adres_probki;

counter_module u_counter_module (
    .clk_b(clk),
    .rst_n(rst_n),
    .ile_probek(ile_probek),
    .FSM_zapisz_probki(FSM_zapisz_probki),
    .FSM_reset_licznik(FSM_reset_licznik), 
    .FSM_nowa_probka(FSM_nowa_probka), 
    .A_probki_FIR(adres_probki),
    .licznik_full(Licznik_full)   
);

licznik_petli u_licznik_petla(
    .clk(clk),
    .rst_n(rst_n),
    .reset_petla(FSM_reset_petla),
    .petla_en(FSM_petla_en),
    .zapisz_wsp(FSM_zapisz_wsp),
    .wsp(wsp),
    .full(Petla_full),
    .adres(adres_FIR)
);



//acc
acc_module u_acc(
    .clk_b(clk),
    .rst_n(rst_n),
    .FSM_Acc_en(FSM_Acc_en),       // włączenie Acc
    .FSM_Acc_zapis(FSM_Acc_zapisz),    // zapisz wartość do FIR_probka_wynik
    .FSM_reset_Acc(FSM_reset_Acc),    // reset Acc
    .suma_wynik(suma_wynik),      // nowa wartość do dodania
    .Acc_out(Acc_out),         // aktualna wartość akumulatora
    .FIR_probka_wynik(fir_probka_wynik) // wynik do wyjścia
);

//dod
adder #(
    .WIDTH(WIDTH)   // >16 bitów
) u_adder (
    .mnozenie_wynik(mnozenie_wynik[30:15]),// IN  mnozenie_wynik[31:16]           31:0   31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 .. 0
    .Acc_out(Acc_out),         // IN 
    .suma_wynik(suma_wynik)        // OUT 
);

multiplier u_multiplier (
    .shift_out(shift_out),        // IN
    .wsp_data(wsp_data),           // IN
    .mnozenie_wynik(mnozenie_wynik)      // OUT (>16)
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
    //Acc_out = 0;
    mnozenie_wynik_adder = 0;
    shift_out = 0;
    wsp_data = 0;
    wsp = 3; //ile wsp
    ile_probek = 5; // ile probek
    rst_n = 0;
    START = 0;
    // Licznik_full = 0;
    // Petla_full = 0;
    #10;
    shift_out = 16'b0100000000000000;  //1/4   -1/4  16'b1111000000000000;   16'b0010000000000000;
    wsp_data = 16'b0100000000000000;   //1/2  -1/2
    rst_n = 1;
    #40;
    //testg
    //jest start
    START = 1;
    #10;
    START = 0; //czyli w apb proramista musi wyzerowac potem ten START. odpalil raz potem ustawia start na 0.
    //albo u nas to sie dzieje jakos...
    #10;
    //start obliczen
    shift_out = 16'b1100000000000000;   //1/4 16'b0010000000000000;    -1/4  16'b1111000000000000; 
    wsp_data = 16'b0100000000000000;   //1/2
    $display("trestS, %b", mnozenie_wynik);
    #10;
    shift_out = 16'b0100000000000000;  //1/4  16'b0000000000000000;
    wsp_data = 16'b0100000000000000;   //1/2
    #10;
    shift_out = 16'b0010000000000000;;  //1/4
    wsp_data = 16'b0100000000000000;   //1/2
    #10; //petla sie robi iles razy (licznik petla)
    // Petla_full = 1;
    // Licznik_full = 1;

    $display("suma wynik, %b", suma_wynik[15:0]);
    #20; //po 2 jest reset licznika petli
    // Petla_full = 0;
    #10;
    //znowu acc enable

    #30;
    // Petla_full = 1;
    // Licznik_full = 1;
//=============================================
//Liczby w u2
//16 bitow
//-1, 1/2, 1/4, 1/8, 1/16, 1/32, 1/64, 1/128,...

    #100;
    //mno
    shift_out = 16'b0010000000000000;  
    wsp_data = 16'b0100000000000000;

    //dod
    //Acc_out = 21'b000000100000000000000;
    // $display("suma wynik, %b", suma_wynik);
    #10;



    #500;
    $finish;
end


endmodule