////////////////////////////////////////////////////////////////////////
//   główny moduł dla AXI.
//   Do testów w cocoTB
///////////////////////////////////////////////////////////////////////

module AXI_main(
    input wire a_clk,
    input wire a_rst_n,
    input wire [31:0] awaddr,
    input wire awvalid,
    output logic awready,
    input wire [3:0] awlen,//[7:0]
    input wire [2:0] awsize,
    input wire [1:0] awburst,
    input wire wvalid,
    output logic wready,
    input wire wlast,
    input wire [63:0] wdata,
    input wire [7:0] wstrb,
    output logic bvalid,
    input wire bready,
    output logic [1:0] bresp,
    input wire arvalid,
    output logic arready,
    input wire [31:0] araddr,
    input wire [2:0] arsize,
    input wire [1:0] arburst,
    input wire [3:0] arlen,//[7:0]
    output logic rvalid,
    input wire rready,
    output logic rlast,
    output logic [63:0] rdata,
    output logic [1:0] rresp

    //sygnały z FSM(z FIR'a) jeszcze tu beda

);

//Parametry
localparam Data_size_out = 16;
localparam Address_size_out = 13;
localparam Data_size_in = 21;
localparam Address_size_out2 = 13;
localparam Szerokosc_mux_wej = 13;

localparam RAM_addr_WIDTH_wej = 13;
localparam RAM_data_WIDTH_wej = 16;

localparam RAM_addr_WIDTH_wyj = 13;
localparam RAM_data_WIDTH_wyj = 16;

localparam RAM_addr_WIDTH_wsp = 13;
localparam RAM_data_WIDTH_wsp = 16;
//----
wire [Address_size_out-1:0] axi_adres_zapisu;
wire [Data_size_out-1:0] axi_data_out;
wire axi_wr;
wire [Data_size_out-1:0] axi_probka;
wire [Address_size_out2-1:0] axi_address_odczytu;
wire [Data_size_in-1:0] axi_data_in;

wire [Szerokosc_mux_wej-1:0] Adres_probki_FIR;//(A_probki_FIR)
wire sel_FSM_mux_wej;
wire [Szerokosc_mux_wej-1:0] probka_address_in;


//---
//TESTOWE do usuniecia
    //TESTY
wire [1:0] state_w_out;

assign sel_FSM_mux_wej = 1'b0;
assign Adres_probki_FIR = '0;
//---

//AXI
axi #(
    .data_out_SIZE(Data_size_out),
    .address_out_SIZE(Address_size_out),
    .data_in_SIZE(Data_size_in),
    .address_out2_SIZE(Address_size_out2)
) u_axi (
    .a_clk(a_clk),
    .a_rst_n(a_rst_n),
    .awaddr(awaddr),
    .awvalid(awvalid),
    .awready(awready),
    .awlen(awlen),
    .awsize(awsize),
    .awburst(awburst),
    .wvalid(wvalid),
    .wready(wready),
    .wlast(wlast),
    .wdata(wdata),
    .wstrb(wstrb),
    .bvalid(bvalid),
    .bready(bready),
    .bresp(bresp),
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
    .rresp(rresp),
    .a_address_wr(axi_adres_zapisu),
    .a_data_out(axi_data_out),
    .a_wr(axi_wr),
    .probka(axi_probka),
    .a_address_rd(axi_address_odczytu),
    .a_data_in(axi_data_in),
    .state_w_out(state_w_out)//TESTOWE do usuniecia
);
//MUX'y
//MUX_AXI_wej
//data_out = (sel) ? data_a : data_b;
multiplekser #(
    .WIDTH(Szerokosc_mux_wej)
) mux_axi_wej (
    .data_a(Adres_probki_FIR),//z FSM
    .data_b(axi_adres_zapisu),//z axi
    .sel(sel_FSM_mux_wej),
    .data_out(probka_address_in)
);
//MUX_AXI_wyj


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

endmodule