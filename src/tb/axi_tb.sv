//`timescale 1ns/1ps
module axi_tb;
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
    axi uut(
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
        .bready(bready),
        .a_address_wr(a_address_wr),
        .a_data_out(a_data_out),
        .a_wr(a_wr),
        .state_w_out(state_w)
    );

    initial begin
        $dumpfile("axi_tb.vcd");
        $dumpvars(0, axi_tb);
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
        awlen = 1; //czyli 1 dana
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
        wlast = 0;//wlast = 1;
        #10;
        wdata = 16'hBBDD;
        wlast = 1;
        #10;
        wvalid = 0;
        wlast = 0;

        #10
        bready = 1;
        #10;
        bready = 0;


//         #10;
//         //adres
//         awaddr = 16'h1000; awlen = 0; awsize = 2'b01; awburst = 2'b00;
//         awvalid = 1;
//         #10;
//         awaddr = 16'hxxxx; awlen = 1'bx; awsize = 2'bxx; awburst = 2'bxx;
//         awvalid = 0;
//         // dane
//         wdata = 16'hABCD; wstrb = 2'b11; wvalid = 1; wlast = 1;
//         #10;
//         wvalid = 0;
//         wlast = 0;

//         // czekamy na BVALID
//         //wait (bvalid == 1);
//         #10;
//         bready = 1;
//          #10;
// bready = 0;
//         // wysyłamy adres
//         awaddr = 16'h0005; awlen = 0; awsize = 2'b01; awburst = 2'b00;
//         awvalid = 1;
//         #10;
//         awvalid = 0;

//         // wysyłamy dane
//         wdata = 16'hAAAA; wstrb = 2'b11; wvalid = 1; wlast = 1;
//         #10;
//         wvalid = 0;

//         // czekamy na BVALID
//         //wait (bvalid == 1);
//         #10;
//         bready = 1;
        #500;

        $finish;
    end
endmodule