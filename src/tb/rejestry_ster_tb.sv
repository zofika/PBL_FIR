`timescale 1ns/1ps

module tb_ctrl_registers;
    reg clk_b;
    reg rst_n;

    reg  [15:0] CDC_data;
    reg  [2:0]  nr_Rejestru;
    reg         wr_Rej;
    reg         Pracuje;
    reg         DONE;

    wire [15:0] Rej_out;
    wire        Start;
    wire [5:0]  Ile_wsp;
    wire [13:0] Ile_probek;

    ctrl_registers dut (
        .clk_b(clk_b),
        .rst_n(rst_n),
        .CDC_data(CDC_data),
        .nr_Rejestru(nr_Rejestru),
        .wr_Rej(wr_Rej),
        .Rej_out(Rej_out),
        .Start(Start),
        .Pracuje(Pracuje),
        .DONE(DONE),
        .Ile_wsp(Ile_wsp),
        .Ile_probek(Ile_probek)
    );

    initial clk_b = 0;
    always #5 clk_b = ~clk_b;

    // =========================
    // Test
    // =========================
    initial begin
        // inicjalizacja
        rst_n = 0; CDC_data = 0; nr_Rejestru = 0; wr_Rej = 0; Pracuje = 0; DONE = 0;

        #20;
        rst_n = 1;
        $display("[%0t] Reset released", $time);

        // zapis START
        #10;
        CDC_data = 16'd1;
        nr_Rejestru = 3'b000; wr_Rej = 1;
        #10; wr_Rej = 0;
        $display("[%0t] Start=%b Rej_out=%h", $time, Start, Rej_out);

        // zapis ile_wsp
        #10;
        CDC_data = 16'd45;
        nr_Rejestru = 3'b011; wr_Rej = 1;
        #10; wr_Rej = 0;
        $display("[%0t] Ile_wsp=%d Rej_out=%h", $time, Ile_wsp, Rej_out);

        // zapis ile_probek
        #10;
        CDC_data = 16'd1024;
        nr_Rejestru = 3'b100; wr_Rej = 1;
        #10; wr_Rej = 0;
        $display("[%0t] Ile_probek=%d Rej_out=%h", $time, Ile_probek, Rej_out);

        // odczyt DONE i Pracuje
        #10;
        Pracuje = 1; DONE = 1;
        nr_Rejestru = 3'b001; #10; $display("[%0t] Rej_out DONE=%h", $time, Rej_out);
        nr_Rejestru = 3'b010; #10; $display("[%0t] Rej_out Pracuje=%h", $time, Rej_out);

        #20;
        $display("=== CTRL REGISTERS TEST FINISHED ===");
        $finish;
    end
initial begin
    $dumpfile("rejestry_ster_tb.vcd");
    $dumpvars(0, tb_ctrl_registers);
end

endmodule
