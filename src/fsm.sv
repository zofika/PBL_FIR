`timescale 1ns/1ps

module fsm_fir (
    input  logic clk,
    input  logic rst_n,

    // ===== Sterowanie =====
    input  logic START,

    output logic pracuje,
    output logic DONE,

    // ===== DEBUG =====
    output logic [2:0] dbg_state,

    // ===== MUX =====
    output logic FSM_MUX_wyj,
    output logic FSM_MUX_wej,
    output logic FSM_MUX_CDC,

    // ===== Licznik współczynników =====
    output logic FSM_zapisz_wsp,
    output logic FSM_petla_en,
    output logic FSM_reset_petla,
    input  logic Petla_full,

    // ===== Licznik próbek =====
    output logic FSM_zapisz_probki,
    output logic FSM_reset_licznik,
    input  logic Licznik_full,
    output logic FSM_nowa_probka,

    // ===== Shift =====
    output logic FSM_nowa_shift,
    output logic FSM_reset_shift,

    // ===== Acc =====
    output logic FSM_Acc_en,
    output logic FSM_Acc_zapisz,
    output logic FSM_reset_Acc
);

    typedef enum logic [2:0] {
        IDLE        = 3'd0,
        INIT        = 3'd1,
        LOAD_SAMPLE = 3'd2,
        MAC_LOOP    = 3'd3,
        NEXT_SAMPLE = 3'd4,
        DONE_STATE  = 3'd5
    } state_t;

    state_t state, next_state;

    // DEBUG
    assign dbg_state = state;

    // ===============================
    // Rejestr stanu
    // ===============================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // ===============================
    // Logika przejść
    // ===============================
    always_comb begin
        next_state = state;

        case (state)
            IDLE:
                if (START) next_state = INIT;

            INIT:
                next_state = LOAD_SAMPLE;

            LOAD_SAMPLE:
                next_state = MAC_LOOP;

            MAC_LOOP:
                if (Petla_full)
                    next_state = NEXT_SAMPLE;

            NEXT_SAMPLE:
                if (Licznik_full)
                    next_state = DONE_STATE;
                else
                    next_state = LOAD_SAMPLE;

            DONE_STATE:
                if (!START)
                    next_state = IDLE;
        endcase
    end

    // ===============================
    // Wyjścia FSM
    // ===============================
    always_comb begin
        pracuje = 0;
        DONE    = 0;

        FSM_MUX_wyj = 0;
        FSM_MUX_wej = 0;
        FSM_MUX_CDC = 0;

        FSM_zapisz_wsp     = 0;
        FSM_petla_en       = 0;
        FSM_reset_petla    = 0;

        FSM_zapisz_probki  = 0;
        FSM_reset_licznik  = 0;
        FSM_nowa_probka    = 0;

        FSM_nowa_shift     = 0;
        FSM_reset_shift    = 0;

        FSM_Acc_en         = 0;
        FSM_Acc_zapisz     = 0;
        FSM_reset_Acc      = 0;

        case (state)
            INIT: begin
                pracuje = 1;
                FSM_reset_petla   = 1;
                FSM_reset_licznik = 1;
                FSM_reset_shift   = 1;
                FSM_reset_Acc     = 1;
                FSM_zapisz_wsp    = 1;
                FSM_zapisz_probki = 1;
            end

            LOAD_SAMPLE: begin
                pracuje = 1;
                FSM_nowa_shift = 1;
                FSM_reset_petla = 1;
                FSM_reset_Acc = 1;
            end

            MAC_LOOP: begin
                pracuje = 1;
                FSM_petla_en = 1;
                FSM_Acc_en   = 1;
                FSM_MUX_CDC  = 1;
            end

            NEXT_SAMPLE: begin
                pracuje = 1;
                FSM_Acc_zapisz  = 1;
                FSM_nowa_probka = 1;
            end

            DONE_STATE: begin
                DONE = 1;
            end
        endcase
    end

endmodule
