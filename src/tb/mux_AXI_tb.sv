`timescale 1ns/1ps

module tb_mux;

    parameter WIDTH = 13;

    logic clk;
    logic [WIDTH-1:0] A_probka_FIR;
    logic [WIDTH-1:0] a_address;
    logic FSM_MUX;
    logic [WIDTH-1:0] probka_address;

    // mux #(.WIDTH(WIDTH)) dut (
    //     .clk(clk),
    //     .A_probka_FIR(A_probka_FIR),
    //     .a_address(a_address),
    //     .FSM_MUX(FSM_MUX),
    //     .probka_address(probka_address)
    // );
    multiplekser #(.WIDTH(WIDTH)) dut (
        .data_a(A_probka_FIR),
        .data_b(a_address),
        .sel(FSM_MUX),
        .data_out(probka_address)
    );


    // Zegar 10 ns
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        FSM_MUX = 0;
        A_probka_FIR = 0;
        a_address = 0;

        #1;
        $display(" TIME | CLK | FSM | A_probka_FIR | a_address | OUT ");
        $display("---------------------------------------------------");

        // Test 1
        a_address = 10;
        A_probka_FIR = 100;
        FSM_MUX = 0;
        #10;
        $display("%4t |  %0d  |  %0d  |     %4d      |    %4d    | %4d",
                 $time, clk, FSM_MUX, A_probka_FIR, a_address, probka_address);

        // Test 2
        FSM_MUX = 1;
        #10;
        $display("%4t |  %0d  |  %0d  |     %4d      |    %4d    | %4d",
                 $time, clk, FSM_MUX, A_probka_FIR, a_address, probka_address);

        // Test 3
        A_probka_FIR = 200;
        #10;
        $display("%4t |  %0d  |  %0d  |     %4d      |    %4d    | %4d",
                 $time, clk, FSM_MUX, A_probka_FIR, a_address, probka_address);

        // Test 4
        FSM_MUX = 0;
        a_address = 55;
        #10;
        $display("%4t |  %0d  |  %0d  |     %4d      |    %4d    | %4d",
                 $time, clk, FSM_MUX, A_probka_FIR, a_address, probka_address);

        $finish;
    end

endmodule
