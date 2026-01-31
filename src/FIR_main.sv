////////////////////////////////////////////////////////////////////////
//   główny moduł dla FIR.
//   Do testów w cocoTB
//
//    f_[nazwa]
///////////////////////////////////////////////////////////////////////

module FIR_main(
    input wire clk,
    input wire rst_n,
    input wire [5:0] f_ile_wsp,
    input wire [13:0] f_ile_probek,
    input wire [14:0] f_ile_razy,
    input wire [15:0] f_wsp_data,
    input wire f_start,
    input wire [15:0] f_probka,
    output logic [4:0] f_adress_fir,
    output logic f_fsm_mux_cdc,
    output logic f_pracuje,
    output logic f_done,
    output logic [12:0] f_a_probki_fir,
    output logic [12:0] f_a_probki_wyn_fir,
    output logic f_fsm_mux_wej,
    output logic f_fsm_mux_wyj,
    output logic [15:0] f_fir_probka_wynik,
    // output logic [20:0] f_fir_probka_wynik,
    output logic f_fsm_wyj_wr
);
//------------------------
wire FSM_zapisz_wsp;
wire FSM_petla_en;
wire FSM_reset_petla;
wire Petla_full;
wire FSM_zapisz_probki;
wire FSM_reset_licznik;
wire Licznik_full;
wire FSM_nowa_probka;
wire FSM_nowa_shift;
wire FSM_reset_shift;
wire FSM_Acc_en;
wire FSM_Acc_zapisz;
wire FSM_reset_Acc;

wire [15:0] shift_out;

wire [20:0] suma_wynik;
wire [20:0] Acc_out;

wire [31:0] mnozenie_wynik;
 
//-------------------------
//FSM
fsm u_fsm (
    .clk(clk),
    .rst_n(rst_n),
    // ===== Sterowanie =====
    .START(f_start),
    .pracuje(f_pracuje),
    .DONE(f_done),
    .FSM_wyj_wr(f_fsm_wyj_wr),
    // ===== MUX =====
    .FSM_MUX_wyj(f_fsm_mux_wyj),
    .FSM_MUX_wej(f_fsm_mux_wej),
    .FSM_MUX_CDC(f_fsm_mux_cdc),
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

//Licznik
counter_module u_counter_module (
    .clk_b(clk),
    .rst_n(rst_n),
    // .ile_probek(f_ile_probek),
    .ile_razy(f_ile_razy),
    .FSM_zapisz_probki(FSM_zapisz_probki),
    .FSM_reset_licznik(FSM_reset_licznik), 
    .FSM_nowa_probka(FSM_nowa_probka), 
    .A_probki_FIR(f_a_probki_fir),
    .A_probki_wyn_FIR(f_a_probki_wyn_fir),
    .licznik_full(Licznik_full)   
);

//Licznik petli  
licznik_petli u_licznik_petla(
    .clk(clk),
    .rst_n(rst_n),
    .reset_petla(FSM_reset_petla),
    .petla_en(FSM_petla_en),
    .zapisz_wsp(FSM_zapisz_wsp),
    .wsp(f_ile_wsp),
    .full(Petla_full),
    .adres(f_adress_fir)
);

//Shift R
shift_R u_shift(
    .clk(clk),
    .rst_n(rst_n),
    .ile_probek(f_ile_probek),
    .probka_in(f_probka),
    .out(shift_out),
    .nowa_shift(FSM_nowa_shift),
    .reset_shift(FSM_reset_shift),
    .adres(f_adress_fir)
);

//Acc
acc_module u_acc(
    .clk_b(clk),
    .rst_n(rst_n),
    .FSM_Acc_en(FSM_Acc_en), 
    .FSM_Acc_zapis(FSM_Acc_zapisz),   
    .FSM_reset_Acc(FSM_reset_Acc),   
    .suma_wynik(suma_wynik),      
    .Acc_out(Acc_out),         
    .FIR_probka_wynik(f_fir_probka_wynik) 
);

//sumator
adder #(
    .WIDTH(21)   // >16 bitów
) u_adder (
    .mnozenie_wynik(mnozenie_wynik[30:15]),
    .Acc_out(Acc_out),   
    .suma_wynik(suma_wynik) 
);

//mnozenie
multiplier u_multiplier (
    .shift_out(shift_out),
    .wsp_data(f_wsp_data),  
    .mnozenie_wynik(mnozenie_wynik) 
);

endmodule