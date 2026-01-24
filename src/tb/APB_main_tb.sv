`timescale 1ns/1ps

module APB_main_tb;

    // =================================================
    // Zegary i reset
    // =================================================
    logic PCLK;
    logic clk_b;
    logic PRESETn;
    logic rst_n;

    // =================================================
    // APB sygnały
    // =================================================
    logic [31:0] PADDR;
    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;
    logic [31:0] PWDATA;
    logic        PREADY;
    logic [31:0] PRDATA;
    logic        PSLVERR;

    // =================================================
    // Pozostałe
    // =================================================
    logic FSM_MUX_CDC;
    logic Start;
    logic pracuje;
    logic DONE;
    logic [5:0]  Ile_wsp;
    logic [13:0] Ile_probek;

    //test odczytu
    logic [31:0] rdata;

    // =================================================
    // DUT
    // =================================================
    APB_main dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),

        .PADDR(PADDR),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),

        .PREADY(PREADY),
        .PRDATA(PRDATA),
        .PSLVERR(PSLVERR),

        .clk_b(clk_b),
        .rst_n(rst_n),

        .FSM_MUX_CDC(FSM_MUX_CDC),

        .Start(Start),
        .pracuje(pracuje),
        .DONE(DONE),

        .Ile_wsp(Ile_wsp),
        .Ile_probek(Ile_probek)
    );

    // =================================================
    // Generatory zegara
    // =================================================
    always #10  PCLK  = ~PCLK;   // 100 MHz
    always #10 clk_b = ~clk_b; // 50 MHz

    // =================================================
    // Zadania APB
    // =================================================
    task apb_write(input [31:0] addr, input [31:0] data);
        begin
            // SETUP
            @(posedge PCLK);
            PADDR   <= addr;
            PWDATA  <= data;
            PWRITE  <= 1'b1;
            PSEL   <= 1'b1;
            PENABLE <= 1'b0;

            // ACCESS
            @(posedge PCLK);
            PENABLE <= 1'b1;

            // wait until PREADY
            fork
                begin : wait_loop
                    forever begin
                        @(posedge PCLK);
                        if (PREADY)
                            disable wait_loop;
                    end
                end
            join

            // IDLE
            PSEL   <= 1'b0;
            PENABLE <= 1'b0;
            PWRITE  <= 1'b0;
            PADDR   <= '0;
            PWDATA  <= '0;
        end
    endtask

    task apb_read(input [31:0] addr, output [31:0] data);
        begin
            // SETUP
            @(posedge PCLK);
            PADDR   <= addr;
            PWRITE  <= 1'b0;
            PSEL   <= 1'b1;
            PENABLE <= 1'b0;

            // ACCESS
            @(posedge PCLK);
            PENABLE <= 1'b1;

            // wait until PREADY
            fork
                begin : wait_loop
                    forever begin
                        @(posedge PCLK);
                        if (PREADY)
                            disable wait_loop;
                    end
                end
            join
            data = PRDATA;
            // IDLE
            PSEL   <= 1'b0;
            PENABLE <= 1'b0;
            PADDR   <= '0;
        end
    endtask

    // =================================================
    // Test główny
    // =================================================
    initial begin
        $dumpfile("APB_main_tb.vcd");
        $dumpvars(0, APB_main_tb);
        // Init
        PCLK     = 0;
        clk_b    = 0;
        PRESETn  = 0;
        rst_n    = 0;

        FSM_MUX_CDC = 1;

        PADDR    = 0;
        PSEL    = 0;
        PENABLE  = 0;
        PWRITE   = 0;
        PWDATA   = 0;

        pracuje=0;

        rdata = 0;

        // Reset
        repeat (5) @(posedge PCLK);
        PRESETn = 1;
        rst_n   = 1;

        $display("=== START TEST APB ===");

        // ---------------------------------------------
        // TEST 1: zapis rejestru Ile_wsp
        // ---------------------------------------------
        apb_write(32'd35, 32'd16); // nr_Rejestru = 3 (ile_wsp)
        #200;
        if (Ile_wsp !== 6'd16)
            $error("Ile_wsp ERROR: %0d", Ile_wsp);
        else
            $display("Ile_wsp OK");

        // ---------------------------------------------
        // TEST 2: zapis rejestru Ile_probek
        // ---------------------------------------------
        apb_write(32'd36, 32'd555); // nr_Rejestru = 4
        #200;
        if (Ile_probek !== 14'd555)
            $error("Ile_probek ERROR: %0d", Ile_probek);
        else
            $display("Ile_probek OK");

        // ---------------------------------------------
        // TEST 2: zapis probek
        // ---------------------------------------------
        for (int i = 0; i < 16; i++) begin
            apb_write(i, 32'd100 + i); // zapis probek do RAM
        end

        // ---------------------------------------------
        // TEST 3: odczyt rejestru
        // ---------------------------------------------
        apb_read(32'd35, rdata);

        if (rdata[5:0] !== 6'd16)
            $error("READ ERROR: %h", rdata);
        else
            $display("READ OK");

        #200;
        // ---------------------------------------------
        // TEST 4: START
        // ---------------------------------------------
        apb_write(32'd32, 32'd1); // START
        #200;
        if (!Start)
            $error("FSM did not start");
        else
            $display("FSM START OK");

        $display("=== TEST FINISHED ===");
        $finish;
    end

endmodule
