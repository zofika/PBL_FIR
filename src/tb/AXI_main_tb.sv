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

    reg arvalid;
    wire arready;
    logic [31:0] araddr;
    logic [2:0] arsize;
    logic [1:0] arburst;
    logic [3:0] arlen;
    logic rvalid;
    logic rready;
    logic rlast;
    logic [63:0] rdata;
    logic [1:0] rresp;


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
        .bready(bready),
        .arvalid(arvalid),
        .arready(arready),
        .araddr(araddr),
        .arsize(arsize),
        .arburst(arburst),
        .arlen(arlen),
        .rvalid(rvalid),
        .rready(rready),
        .rlast(rlast),
        .rdata(rdata),
        .rresp(rresp)
    );



    initial begin
        $dumpfile("AXI_main_tb.vcd");
        $dumpvars(0, AXI_main_tb);
    end
    // zegar
    initial a_clk = 1;
    always #5 a_clk = ~a_clk;


    initial begin
        //======================
        //zapis

        //reset
        a_rst_n = 0;
        bready = 0;
        awvalid = 0; wvalid = 0;
        awaddr = 0; awlen = 0; awsize = 2'b01; awburst = 2'b01;
        wdata = 0; wstrb = 2'b01; wlast = 0;
        #20;
        awaddr = 16'hxxxx; awlen = 1'bx; awsize = 2'bxx; awburst = 2'bxx;
        a_rst_n = 1;
        //======================
        #20;
        //#1;
        awaddr = 16'h0A;
        awlen = 2; //czyli 1 dana   2
        awsize = 2'b01;
        awburst = 2'b01;
        #4;
        awvalid = 1;
        wait(awready == 1) begin
            // #10 arvalid = 0;
            awvalid = 1;
            //#10;
        end
        //#6;
        //#10;
        //#;
        $display("dana adres 0. %t, %h",$time ,uut.RAM_wej.adres);
        #10; //#10;
        #1;
        awvalid = 0;
        awaddr = 16'hxxxx; awlen = 1'bx; awsize = 2'bxx; awburst = 2'bxx;

        #40;

        wdata = 16'hABCD; 
        //wstrb = 2'b01; 
        wvalid = 1; 
        wlast = 0; //;0
        $display("dana A. %t, %b",$time ,uut.RAM_wej.pamiec_RAM[16'h0A]);
        $display("dana adres A. %t, %h",$time ,uut.RAM_wej.adres);
        //wlast = 1;//wlast = 1;
        #9;
        //#10;
        #1;
        wvalid = 1;//1;
        wdata = 16'hFDDF; //FDDF;
        wlast = 0;
        #10;
        wvalid = 1;
        wdata = 16'hFAFA; //FDDF;
        wlast = 1;
        $display("dana adres B. %t, %h",$time ,uut.RAM_wej.adres);
        #1;
        $display("dana B. %t, %h",$time ,uut.RAM_wej.pamiec_RAM[16'h0A]);
$display("dana adres B 2. %t, %h",$time ,uut.RAM_wej.adres);

       // #10;
       // $display("dana B, %b",uut.RAM_wej.pamiec_RAM[5'd11]);
       // wdata = 16'hBBDD;
       // wlast = 1;
        #9;
        $display("dana adres B 3. %t, %h",$time ,uut.RAM_wej.adres);
        wvalid = 0;
        $display("dana B2. %t, %h",$time ,uut.RAM_wej.pamiec_RAM[16'h0B]);
       wlast = 0;
        #20;
        bready = 1;
        // wait(bvalid == 1) begin
        //     // #10 arvalid = 0;
        //     bready = 1;
        //     //#10;
        // end
        #10;
         bready = 0;
         $display("dana C. %t, %h",$time ,uut.RAM_wej.pamiec_RAM[16'h0B]);
        #10;
        //======================
        uut.RAM_wyj.pamiec_RAM[5'd1] = 16'h0001;
        uut.RAM_wyj.pamiec_RAM[5'd2] = 16'h0002;
        uut.RAM_wyj.pamiec_RAM[5'd3] = 16'h0003;
        uut.RAM_wyj.pamiec_RAM[5'd4] = 16'h0004;
        uut.RAM_wyj.pamiec_RAM[5'd5] = 16'h0005;
        uut.RAM_wyj.pamiec_RAM[5'd6] = 16'h0006;
        uut.RAM_wyj.pamiec_RAM[5'd7] = 16'h0007;
        uut.RAM_wyj.pamiec_RAM[5'd8] = 16'h0008;
        //odczyt
         #50;
        //a_rst_n = 0;
        rready  = 0;
        arvalid = 0;
        araddr  = 0;
        arlen   = 0;
        arsize  = 3'bxxx;
        arburst = 2'b01;
        #20;
        //a_rst_n = 1;

        // 1 READ
        #20;
        //araddr  = 16'h0A;//32'h0000_000A;
        araddr  = 16'b0010000000000001;//32'h0000_000A;
        arlen   = 2;
        #9
        arvalid = 1;
        #11;
        arvalid = 0;
        #9; arvalid = 0;
        for (int i=0; i<arlen+1; i++) begin
        // czekamy, aż rvalid = 1 w danym cyklu zegara
        @(posedge a_clk);
        wait(rvalid == 1);  // dopiero gdy slave wystawi dane

        // ustawiamy handshake na cały takt
        rready <= 1;

        // czekamy jeden pełen takt
        @(posedge a_clk);

        // koniec handshake
        rready <= 0;
        end



//=========================
//=========================
//=========================
//=========================



        //#10; arvalid = 0;
//         wait(arready == 1) begin
//             // #10 arvalid = 0;
//             arvalid = 0;
//         end
//         #10;
//         araddr  = 32'h0000_000B;

// for (int i=0; i<arlen+1; i++) begin
//     // czekamy, aż rvalid = 1 w danym cyklu zegara
//     @(posedge a_clk);
//     wait(rvalid == 1);  // dopiero gdy slave wystawi dane

//     // ustawiamy handshake na cały takt
//     rready <= 1;

//     // czekamy jeden pełen takt
//     @(posedge a_clk);

//     // koniec handshake
//     rready <= 0;
// end


//  rready <= 1;
//  #40;
//   rready <= 0;





        // repeat(arlen+1) begin
        //     wait(rvalid == 1) begin
        //         // #10 arvalid = 0;
        //         rready = 1;
        //         #10;
        //     end
        //     rready = 0;
        //     //#20;
        // end
        //arvalid = 0;
        // rready = 1;
        // #10;
        // rready =0;



        // #50;
        // rready  = 0;
        // arvalid = 0;
        // araddr  = 0;
        // arlen   = 0;
        // arsize  = 3'bxxx;
        // arburst = 2'bxx;
        // #20;
        // // 1 READ
        // #10;
        // araddr  = 32'h0000_000A;
        // arvalid = 1;

        // #10;
        // arvalid = 0;
        // rready = 1;
        // #10;
        // rready =0;

        #500;

        $finish;
    end

endmodule