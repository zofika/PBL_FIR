////////////////////////////////////////////////////////////////////////
//   główny moduł dla naszego projektu.
///////////////////////////////////////////////////////////////////////

module pbl_TOP(
    //axi
    input wire a_clk,
    input wire a_rst_n,
    input wire [31:0] a_awaddr,
    input wire a_awvalid,
    output logic a_awready,
    input wire [7:0] a_awlen,
    input wire [2:0] a_awsize,
    input wire [1:0] a_awburst,
    input wire a_wvalid,
    output logic a_wready,
    input wire a_wlast,
    input wire [63:0] a_wdata,
    input wire [7:0] a_wstrb,
    output logic a_bvalid,
    input wire a_bready,
    output logic [1:0] a_bresp,
    input wire a_arvalid,
    output logic a_arready,
    input wire [31:0] a_araddr,
    input wire [2:0] a_arsize,
    input wire [1:0] a_arburst,
    input wire [7:0] a_arlen,
    output logic a_rvalid,
    input wire a_rready,
    output logic a_rlast,
    output logic [63:0] a_rdata,
    output logic [1:0] a_rresp
    
    //apb

);
//==================
// ZEGARY
//DOMENA A - apb:

//DOMENA B - axi:
//a_clk
//==================



//APB_main


//AXI_main
AXI_main u_axi(
    .a_clk(a_clk),
    .a_rst_n(a_rst_n),
    .a_awaddr(a_awaddr),
    .a_awvalid(a_awvalid),
    .a_awready(a_awready),
    .a_awlen(a_awlen),
    .a_awsize(a_awsize),
    .a_awburst(a_awburst),
    .a_wvalid(a_wvalid),
    .a_wready(a_wready),
    .a_wlast(a_wlast),
    .a_wdata(a_wdata),
    .a_wstrb(a_wstrb),
    .a_bvalid(a_bvalid),
    .a_bready(a_bready),
    .a_bresp(a_bresp),
    .a_arvalid(a_arvalid),
    .a_arready(a_arready),
    .a_araddr(a_araddr),
    .a_arsize(a_arsize),
    .a_arburst(a_arburst),
    .a_arlen(a_arlen),
    .a_rvalid(a_rvalid),
    .a_rready(a_rready),
    .a_rlast(a_rlast),
    .a_rdata(a_rdata),
    .a_rresp(a_rresp)
    //sygnały z FSM(z FIR'a) jeszcze tu beda

);

//FIR_main


endmodule