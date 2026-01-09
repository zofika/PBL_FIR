// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module tb_decoder;

    logic [5:0] CDC_A;
    logic       CDC_wr;

    logic       Dekoder_MUX;
    logic [4:0] address_RAM;
    logic       wr_RAM;
    logic [2:0] nr_Rejestru;
    logic       wr_Rej;

    // Instancja DUT
    decoder dut (
        .CDC_A(CDC_A),
        .CDC_wr(CDC_wr),
        .Dekoder_MUX(Dekoder_MUX),
        .address_RAM(address_RAM),
        .wr_RAM(wr_RAM),
        .nr_Rejestru(nr_Rejestru),
        .wr_Rej(wr_Rej)
    );

    initial begin
        $display("--------------------------------------------------------------");
        $display(" CDC_A  | wr | MUX | addr_RAM | wr_RAM | nr_Rej | wr_Rej ");
        $display("--------------------------------------------------------------");

        // ===== Test 1: RAM, zapis =====
        CDC_A  = 6'b000101; // RAM, addr = 5
        CDC_wr = 1;
        #1;
        $display(" %6b |  %0d |  %0d  |    %2d     |   %0d    |   %2d   |   %0d",
                 CDC_A, CDC_wr, Dekoder_MUX,
                 address_RAM, wr_RAM,
                 nr_Rejestru, wr_Rej);

        // ===== Test 2: RAM, brak zapisu =====
        CDC_A  = 6'b000111; // RAM, addr = 7
        CDC_wr = 0;
        #1;
        $display(" %6b |  %0d |  %0d  |    %2d     |   %0d    |   %2d   |   %0d",
                 CDC_A, CDC_wr, Dekoder_MUX,
                 address_RAM, wr_RAM,
                 nr_Rejestru, wr_Rej);

        // ===== Test 3: Rejestr, zapis =====
        CDC_A  = 6'b100011; // Rej, nr = 3
        CDC_wr = 1;
        #1;
        $display(" %6b |  %0d |  %0d  |    %2d     |   %0d    |   %2d   |   %0d",
                 CDC_A, CDC_wr, Dekoder_MUX,
                 address_RAM, wr_RAM,
                 nr_Rejestru, wr_Rej);

        // ===== Test 4: Rejestr, brak zapisu =====
        CDC_A  = 6'b100001; // Rej, nr = 1
        CDC_wr = 0;
        #1;
        $display(" %6b |  %0d |  %0d  |    %2d     |   %0d    |   %2d   |   %0d",
                 CDC_A, CDC_wr, Dekoder_MUX,
                 address_RAM, wr_RAM,
                 nr_Rejestru, wr_Rej);

        // ===== Test 5: Granica =====
        CDC_A  = 6'b011111; // RAM, max addr
        CDC_wr = 1;
        #1;
        $display(" %6b |  %0d |  %0d  |    %2d     |   %0d    |   %2d   |   %0d",
                 CDC_A, CDC_wr, Dekoder_MUX,
                 address_RAM, wr_RAM,
                 nr_Rejestru, wr_Rej);

        $display("--------------------------------------------------------------");
        $finish;
    end

initial begin
    $dumpfile("decoder_tb.vcd");
    $dumpvars(0, tb_decoder);
end

endmodule
