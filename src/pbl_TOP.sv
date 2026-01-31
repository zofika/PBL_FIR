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

//--FIR--
wire [5:0] ile_wsp;   //z apb
wire [13:0] ile_probek;   // z apb
wire [14:0] ile_razy;  //zapb
wire [15:0] wsp_data;
wire start; // z apb
wire [15:0] probka; //z axi
wire [4:0] address_fir;  //do apb
wire fsm_mux_cdc; //do apb
wire pracuje; //do apb
wire done; //do apb
wire [12:0] a_probki_fir; //do axi
wire [12:0] a_probki_wyn_fir; //do axi
wire fsm_mux_wej; //do axi
wire fsm_mux_wyj;//do axi
wire [15:0] fir_probka_wynik;//do axi
wire fsm_wyj_wr;//do axi
//=============

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
    .a_rresp(a_rresp),
    .a_probka(probka),
    .a_fsm_mux_wej(fsm_mux_wej),
    .a_fsm_mux_wyj(fsm_mux_wyj),
    .a_fsm_wyj_wr(fsm_wyj_wr),
    .a_adres_probki_fir(a_probki_fir),
    .a_adres_probki_wyn_fir(a_probki_wyn_fir),
    .a_fir_probka_wynik(fir_probka_wynik)
);

//FIR_main
FIR_main u_fir(
    .clk(a_clk),
    .rst_n(a_rst_n),
    .f_ile_wsp(ile_wsp),
    .f_ile_probek(ile_probek),
    .f_ile_razy(ile_razy),
    .f_wsp_data(wsp_data),
    .f_start(start),
    .f_probka(probka),
    .f_adress_fir(address_fir),
    .f_fsm_mux_cdc(fsm_mux_cdc),
    .f_pracuje(pracuje),
    .f_done(done),
    .f_a_probki_fir(a_probki_fir),
    .f_a_probki_wyn_fir(a_probki_wyn_fir),
    .f_fsm_mux_wej(fsm_mux_wej),
    .f_fsm_mux_wyj(fsm_mux_wyj),
    .f_fir_probka_wynik(fir_probka_wynik),
    .f_fsm_wyj_wr(fsm_wyj_wr)
);

endmodule