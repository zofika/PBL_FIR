// `timescale 1ns/1ps

// module tb_fsm_fir;

//     // ===============================
//     // Sygnały testbench
//     // ===============================
//     logic clk;
//     logic rst_n;
//     logic START;

//     logic pracuje;
//     logic DONE;

//     logic [2:0] dbg_state;

//     logic FSM_MUX_wyj;
//     logic FSM_MUX_wej;
//     logic FSM_MUX_CDC;

//     logic FSM_zapisz_wsp;
//     logic FSM_petla_en;
//     logic FSM_reset_petla;
//     logic Petla_full;

//     logic FSM_zapisz_probki;
//     logic FSM_reset_licznik;
//     logic Licznik_full;
//     logic FSM_nowa_probka;

//     logic FSM_nowa_shift;
//     logic FSM_reset_shift;

//     logic FSM_Acc_en;
//     logic FSM_Acc_zapisz;
//     logic FSM_reset_Acc;

//     // ===============================
//     // Instancja FSM
//     // ===============================
//     fsm_fir uut (
//         .clk(clk),
//         .rst_n(rst_n),
//         .START(START),
//         .pracuje(pracuje),
//         .DONE(DONE),
//         .dbg_state(dbg_state),
//         .FSM_MUX_wyj(FSM_MUX_wyj),
//         .FSM_MUX_wej(FSM_MUX_wej),
//         .FSM_MUX_CDC(FSM_MUX_CDC),
//         .FSM_zapisz_wsp(FSM_zapisz_wsp),
//         .FSM_petla_en(FSM_petla_en),
//         .FSM_reset_petla(FSM_reset_petla),
//         .Petla_full(Petla_full),
//         .FSM_zapisz_probki(FSM_zapisz_probki),
//         .FSM_reset_licznik(FSM_reset_licznik),
//         .Licznik_full(Licznik_full),
//         .FSM_nowa_probka(FSM_nowa_probka),
//         .FSM_nowa_shift(FSM_nowa_shift),
//         .FSM_reset_shift(FSM_reset_shift),
//         .FSM_Acc_en(FSM_Acc_en),
//         .FSM_Acc_zapisz(FSM_Acc_zapisz),
//         .FSM_reset_Acc(FSM_reset_Acc)
//     );

//     // ===============================
//     // Generowanie zegara
//     // ===============================
//     initial clk = 0;
//     always #5 clk = ~clk; // 100 MHz zegar (10 ns okres)

//     // ===============================
//     // Procedura testowa
//     // ===============================
//     initial begin
//         // Reset
//         rst_n = 0;
//         START = 0;
//         Petla_full = 0;
//         Licznik_full = 0;
//         #20;
//         rst_n = 1;

//         // Start FSM
//         #10;
//         START = 1;

//         // Symulacja działania pętli
//         repeat (3) begin
//             // Poczekaj aż FSM przejdzie do MAC_LOOP
//             wait(dbg_state == 3'd3);
//             #10;
//             Petla_full = 1;
//             #10;
//             Petla_full = 0;

//             // Poczekaj aż FSM przejdzie do NEXT_SAMPLE
//             wait(dbg_state == 3'd4);
//             #10;
//             Licznik_full = 1;
//             #10;
//             Licznik_full = 0;
//         end

//         // Zakończenie
//         #50;
//         START = 0;
//         #20;

//         $display("Test zakończony pomyślnie.");
//         $stop;
//     end

//     // ===============================
//     // Monitorowanie sygnałów
//     // ===============================
//     initial begin
//         $monitor("Czas=%0t | State=%0d | pracuje=%b | DONE=%b | FSM_Acc_en=%b",
//                  $time, dbg_state, pracuje, DONE, FSM_Acc_en);
//     end

// endmodule

`timescale 1ns/1ps

module tb_fsm_fir;

    logic clk, rst_n, START;
    logic pracuje, DONE;
    logic [2:0] dbg_state;
    logic FSM_MUX_wyj, FSM_MUX_wej, FSM_MUX_CDC;
    logic FSM_zapisz_wsp, FSM_petla_en, FSM_reset_petla, Petla_full;
    logic FSM_zapisz_probki, FSM_reset_licznik, Licznik_full, FSM_nowa_probka;
    logic FSM_nowa_shift, FSM_reset_shift;
    logic FSM_Acc_en, FSM_Acc_zapisz, FSM_reset_Acc;

    fsm uut ( //fsm_fir
        .clk(clk), .rst_n(rst_n), .START(START),
        .pracuje(pracuje), .DONE(DONE), .dbg_state(dbg_state),
        .FSM_MUX_wyj(FSM_MUX_wyj), .FSM_MUX_wej(FSM_MUX_wej), .FSM_MUX_CDC(FSM_MUX_CDC),
        .FSM_zapisz_wsp(FSM_zapisz_wsp), .FSM_petla_en(FSM_petla_en), .FSM_reset_petla(FSM_reset_petla),
        .Petla_full(Petla_full),
        .FSM_zapisz_probki(FSM_zapisz_probki), .FSM_reset_licznik(FSM_reset_licznik),
        .Licznik_full(Licznik_full), .FSM_nowa_probka(FSM_nowa_probka),
        .FSM_nowa_shift(FSM_nowa_shift), .FSM_reset_shift(FSM_reset_shift),
        .FSM_Acc_en(FSM_Acc_en), .FSM_Acc_zapisz(FSM_Acc_zapisz), .FSM_reset_Acc(FSM_reset_Acc)
    );

    // zegar
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // reset
        rst_n = 0; START = 0; Petla_full = 0; Licznik_full = 0;
        #20 rst_n = 1;

        // START FSM
        #10 START = 1;

        // poczekaj na MAC_LOOP
        wait(dbg_state == 3);

        // wyzwól NEXT_SAMPLE
        Petla_full = 1; 
        @(posedge clk);   // przekaż do FSM w następnym cyklu
        Petla_full = 0;

        // poczekaj na NEXT_SAMPLE
        wait(dbg_state == 4);

        // wyzwól DONE_STATE
        Licznik_full = 1;
        @(posedge clk);
        Licznik_full = 0;

        wait(dbg_state == 5);
        $display("FSM osiągnął stan DONE_STATE = %0d", dbg_state);
        $finish;
    end

    initial begin
        $monitor("%0t clk=%b rst_n=%b START=%b state=%d DONE=%b", $time, clk, rst_n, START, dbg_state, DONE);
    end

endmodule
