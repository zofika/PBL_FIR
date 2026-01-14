`timescale 1ns/1ps

module fsm (
    input  logic clk,
    input  logic rst_n,

    // ===== Sterowanie =====
    input  logic START,

    output logic pracuje,
    output logic DONE,
    output logic FSM_wyj_wr,


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
        START_S        = 3'd1,
        A = 3'd2,
        B    = 3'd3,
        C = 3'd4,
        D  = 3'd5,
      	KONIEC = 3'd6
    } state_t;

    state_t state, next_state;
 
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
              if (START) next_state = START_S;

            START_S:
                next_state = A;

            A:
                next_state = B;

            B:
                if (Petla_full)
                    next_state = C;

            C: 
                    next_state = D; 

            D:
                if (Licznik_full)
                    next_state = KONIEC;
          	    else 
                    next_state = A;
          
          	KONIEC: next_state = IDLE;
        endcase
    end

    // ===============================
    // Wyjścia FSM
    // ===============================
    always_comb begin
        //pracuje zawsze 1 - bo pracuje tylko w IDLE jest =0 bo czeka i nie pracuje
        pracuje = 1;
        // pracuje = 0;
        DONE    = 0;

        //muxy - zawsze na FIR skierowane, ale w IDLE do interfejsow naszych - bo zapis 
        FSM_MUX_wyj = 1;
        FSM_MUX_wej = 1;
        FSM_MUX_CDC = 1;
        // FSM_MUX_wyj = 0;
        // FSM_MUX_wej = 0;
        // FSM_MUX_CDC = 0;

        FSM_wyj_wr = 0;

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
            IDLE: begin
                pracuje = 0;
                FSM_MUX_CDC   = 0;
                FSM_MUX_wej = 0;
                FSM_MUX_wyj   = 0;
            end

            START_S: begin
                pracuje = 1;
                FSM_MUX_CDC = 1;
                FSM_MUX_wej = 1;
                FSM_MUX_wyj = 1;
              	FSM_zapisz_probki = 1;
                FSM_reset_licznik = 1;
                FSM_zapisz_wsp = 1;
              	FSM_reset_petla = 1;
                FSM_reset_Acc = 1;
                FSM_reset_shift = 1;
            end

            A: begin
                FSM_nowa_shift = 1;
                FSM_reset_petla = 1; 
            end

            B: begin 
                FSM_petla_en  = 1;
                FSM_Acc_en = 1;
            end

            C: begin
                FSM_petla_en = 0;
              	FSM_Acc_en = 0;
              	FSM_Acc_zapisz = 1;
                FSM_nowa_probka = 1; //tu
                //FSM_wyj_wr = 1;
            end
          
          	D: begin
                FSM_reset_Acc = 1;
              	// FSM_nowa_probka = 1; 
                FSM_wyj_wr = 1; //tutaj jeslibez zmiany acc
            end
          
           	KONIEC: begin
                DONE = 1;
              	pracuje = 0; 
            end
        endcase
    end

endmodule
