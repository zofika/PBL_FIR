`timescale 1ns/1ps

////////////////////////////////////////////////////////////////////////
//   cd src\tb
//   iverilog -g2012 -o ram_tb.vvp ../ram.sv ram_tb.sv
//   vvp ram_tb.vvp
//   gtkwave ram_tb.vcd
///////////////////////////////////////////////////////////////////////


module ram_tb;

    localparam adres_W = 5;
    localparam data_W = 16;
    // sygnały
    logic clk;
    logic wr_mem;
    logic [adres_W-1:0] adres;
    logic [data_W-1:0] dane;
    logic [data_W-1:0] out;

    // instancja modułu
    ram  #(
        .ADDR_WIDTH(adres_W),
        .DATA_WIDTH(data_W)
    ) DUT (
        .clk(clk),
        .wr(wr_mem),
        .adres(adres),
        .data(dane),
        .data_out(out)
    );

    initial clk = 1;
    always #5 clk = ~clk;

    initial begin
        wr_mem = 0;
        adres  = 0;
        dane   = 0;
        #10;

        //@(posedge clk);
        wr_mem = 1;
        adres  = 8'd0;
        dane   = 8'hAA;
        #10;
        //@(posedge clk);
        wr_mem = 0;

        #10;
        //@(posedge clk);
        wr_mem = 1;
        adres  = 8'd1;
        dane   = 8'h55;
        #10;//@(posedge clk);
        wr_mem = 0;

        #10;//@(posedge clk);
        wr_mem = 1;
        adres  = 8'd10;
        dane   = 8'hCC;
        #10;//@(posedge clk);
        wr_mem = 0;

        #10;//@(posedge clk);
        adres = 8'd0;

        #10;//@(posedge clk);
        adres = 8'd1;

        #10;//@(posedge clk);
        adres = 8'd10;

        #10;//@(posedge clk);
        adres = 8'd2;

        #20;
        wr_mem = 1;
        adres  = 8'd15;
        dane   = 8'hAA;
        #10;
        adres  = 8'd16;
        dane   = 8'hAB;
        #10;
        adres  = 8'd17;
        dane   = 8'hAC;
        #10;
        wr_mem = 0;

        #20;
        adres = 8'd15;
        #10;
        adres  = 8'd16;
        #10;
        adres  = 8'd17;

        #300;
        $finish;
    end

    initial begin
        $dumpfile("ram_tb.vcd");
        $dumpvars(0, ram_tb);
    end


endmodule