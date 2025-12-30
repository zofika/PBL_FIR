//`timescale 1ns/1ps

//====================================
//iverilog -g2012 -o AXI_main_tb.vvp ../AXI_main.sv ../axi.sv ../multiplekser.sv ../ram.sv AXI_main_tb.sv
//=====================================

module AXI_main_tb;
    reg a_clk;
    reg a_rst_n;

    reg awvalid;
    reg [31:0] awaddr;
    reg [3:0] awlen;
    reg [2:0] awsize;
    reg [1:0] awburst;

    reg wvalid;
    reg [63:0] wdata;
    reg wlast;
    reg [7:0] wstrb;

    wire awready;
    wire wready;
    wire bvalid;
    wire [1:0] bresp;

    logic [13-1:0] a_address_wr;
    logic [16-1:0] a_data_out;
    logic a_wr;

    reg bready;
    logic [1:0] state_w;

    // instancja slave
    AXI_main uut( //TYLKO zapis narazie
        .a_clk(a_clk),
        .a_rst_n(a_rst_n),
        .awvalid(awvalid),
        .awaddr(awaddr),
        .awlen(awlen),
        .awsize(awsize),
        .awburst(awburst),
        .wvalid(wvalid),
        .wdata(wdata),
        .wstrb(wstrb),
        .wlast(wlast),
        .awready(awready),
        .wready(wready),
        .bvalid(bvalid),
        .bresp(bresp),
        .bready(bready)
    );



    initial begin
        $dumpfile("AXI_main_tb.vcd");
        $dumpvars(0, AXI_main_tb);
    end
    // zegar
    initial a_clk = 1;
    always #5 a_clk = ~a_clk;

    initial begin
        // reset
        a_rst_n = 0;
        bready = 0;
        awvalid = 0; wvalid = 0;
        awaddr = 0; awlen = 0; awsize = 2'b01; awburst = 2'b01;
        wdata = 0; wstrb = 2'b11; wlast = 0;
        #20;
        awaddr = 16'hxxxx; awlen = 1'bx; awsize = 2'bxx; awburst = 2'bxx;
        a_rst_n = 1;
        //======================
        #20;
        //#1;
        awaddr = 16'h0A;
        awlen = 0; //czyli 1 dana
        awsize = 2'b01;
        awburst = 2'b01;
        awvalid = 1;
        //#;

        #10; //#10;
        awvalid = 0;
        awaddr = 16'hxxxx; awlen = 1'bx; awsize = 2'bxx; awburst = 2'bxx;
        
        wdata = 16'hABCD; 
        wstrb = 2'b11; 
        wvalid = 1; 
        wlast = 1;//wlast = 1;
        #10;
        // wdata = 16'hBBDD;
        // wlast = 1;
        // #10;
        wvalid = 0;
        wlast = 0;

        #10
        bready = 1;
        #10;
        bready = 0;

        #500;

        $finish;
    end
endmodule