////////////////////////////////////////////////////////////////////////
//   główny moduł dla AXI.
//   Do testów w cocoTB
///////////////////////////////////////////////////////////////////////

module AXI_main(
    // input wire a_clk,
    // input wire a_rst_n,
    // input wire [31:0] awaddr,
    // input wire awvalid,
    // output logic awready,
    // input wire [3:0] awlen,//[7:0]
    // input wire [2:0] awsize,
    // input wire [1:0] awburst,
    // input wire wvalid,
    // output logic wready,
    // input wire wlast,
    // input wire [63:0] wdata,
    // input wire [7:0] wstrb,
    // output logic bvalid,
    // input wire bready,
    // output logic [1:0] bresp,
    // input wire arvalid,
    // output logic arready,
    // input wire [31:0] araddr,
    // input wire [2:0] arsize,
    // input wire [1:0] arburst,
    // input wire [3:0] arlen,//[7:0]
    // output logic rvalid,
    // input wire rready,
    // output logic rlast,
    // output logic [63:0] rdata,
    // output logic [1:0] rresp
    input wire a_clk,
    input wire a_rst_n,
    input wire [31:0] a_awaddr,
    input wire a_awvalid,//a_awvalid,a_AWVALID   wire
    output logic a_awready,
    input wire [7:0] a_awlen,//[7:0]
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
    input wire [7:0] a_arlen,//[7:0]
    output logic a_rvalid,
    input wire a_rready,
    output logic a_rlast,
    output logic [63:0] a_rdata,
    output logic [1:0] a_rresp,
    //sygnały z FIR
    output logic [15:0] a_probka,
    input wire a_fsm_mux_wej,
    input wire a_fsm_mux_wyj,
    input wire a_fsm_wyj_wr,
    input wire [12:0] a_adres_probki_fir,
    input wire [12:0] a_adres_probki_wyn_fir,
    input wire [15:0] a_fir_probka_wynik
);

//Parametry
localparam Data_size_out = 16;
localparam Address_size_out = 13;
localparam Data_size_in = 16;//21;
localparam Address_size_out2 = 13;
localparam Szerokosc_mux_wej = 13;
localparam Szerokosc_mux_wyj = 13;

localparam RAM_addr_WIDTH_wej = 13;
localparam RAM_data_WIDTH_wej = 16;

localparam RAM_addr_WIDTH_wyj = 13;
localparam RAM_data_WIDTH_wyj = 16;//21;

localparam RAM_addr_WIDTH_wsp = 13;
localparam RAM_data_WIDTH_wsp = 16;

localparam WIDTH_adres_write = 14;
localparam WIDTH_adres_read = 15;


//----
wire [Address_size_out-1:0] axi_adres_zapisu;
wire [Data_size_out-1:0] axi_data_out;
wire axi_wr;
wire [Data_size_out-1:0] axi_probka;
wire [Address_size_out2-1:0] axi_address_odczytu;
wire [Data_size_in-1:0] axi_data_in;

// wire [Szerokosc_mux_wej-1:0] Adres_probki_FIR;//(A_probki_FIR)
// wire sel_FSM_mux_wej;
wire [Szerokosc_mux_wej-1:0] probka_address_in;
wire [Szerokosc_mux_wyj-1:0] probka_address_out;
// wire sel_FSM_mux_wyj;

// wire in_FSM_wyj_wr;
// wire [Data_size_in-1:0] in_FIR_probka_wynik;

//---
//TESTOWE do usuniecia

// assign sel_FSM_mux_wej = 1'b0;
// assign Adres_probki_FIR = '0;
// assign sel_FSM_mux_wyj = 1'b0;
// assign in_FSM_wyj_wr = 1'b0;
// assign in_FIR_probka_wynik = '0;
//---

assign a_probka = axi_probka;

//AXI
axi #(
    .data_out_SIZE(Data_size_out),
    .address_out_SIZE(Address_size_out),
    .data_in_SIZE(Data_size_in),
    .address_out2_SIZE(Address_size_out2),
    .WIDTH_adres_write(WIDTH_adres_write),
    .WIDTH_adres_read(WIDTH_adres_read)
) u_axi (
    .a_clk(a_clk),
    .a_rst_n(a_rst_n),
    .awaddr(a_awaddr),
    .awvalid(a_awvalid),
    .awready(a_awready),
    .awlen(a_awlen),
    .awsize(a_awsize),
    .awburst(a_awburst),
    .wvalid(a_wvalid),
    .wready(a_wready),
    .wlast(a_wlast),
    .wdata(a_wdata),
    .wstrb(a_wstrb),
    .bvalid(a_bvalid),
    .bready(a_bready),
    .bresp(a_bresp),
    .arvalid(a_arvalid),
    .arready(a_arready),
    .araddr(a_araddr),
    .arsize(a_arsize),
    .arburst(a_arburst),
    .arlen(a_arlen),
    .rvalid(a_rvalid),
    .rready(a_rready),
    .rlast(a_rlast),
    .rdata(a_rdata),
    .rresp(a_rresp),
    .a_address_wr(axi_adres_zapisu),
    .a_data_out(axi_data_out),
    .a_wr(axi_wr),
    .probka(axi_probka),
    .a_address_rd(axi_address_odczytu),
    .a_data_in(axi_data_in)
);
//MUX'y
//MUX_AXI_wej
//data_out = (sel) ? data_a : data_b;
multiplekser #(
    .WIDTH(Szerokosc_mux_wej)
) mux_axi_wej (
    .data_a(a_adres_probki_fir),//z FSM
    .data_b(axi_adres_zapisu),//z axi
    .sel(a_fsm_mux_wej),
    .data_out(probka_address_in)
);
//MUX_AXI_wyj
multiplekser #(
    .WIDTH(Szerokosc_mux_wyj)
) mux_axi_wyj (
    .data_a(a_adres_probki_wyn_fir),//z FSM
    .data_b(axi_address_odczytu),//z axi
    .sel(a_fsm_mux_wyj),
    .data_out(probka_address_out)
);

//RAM (wej)
ram #(
    .ADDR_WIDTH(RAM_addr_WIDTH_wej),
    .DATA_WIDTH(RAM_data_WIDTH_wej)
) RAM_wej (
    .clk(a_clk),
    .adres(probka_address_in),
    .data(axi_data_out),
    .wr(axi_wr),
    .data_out(axi_probka)//axi_probka też potem do FIR idzie.
);

//RAM (wyj)
ram #(
    .ADDR_WIDTH(RAM_addr_WIDTH_wyj),
    .DATA_WIDTH(RAM_data_WIDTH_wyj)
) RAM_wyj (
    .clk(a_clk),
    .adres(probka_address_out),
    .data(a_fir_probka_wynik),
    .wr(a_fsm_wyj_wr),
    .data_out(axi_data_in)//axi_probka też potem do FIR idzie.
);

endmodule