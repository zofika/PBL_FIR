////////////////////////////////////////////////////////////////////////
//   główny moduł dla APB.
//   Do testów w cocoTB
///////////////////////////////////////////////////////////////////////

module APB_main (
    // APB# sygnały od mastera
    input  logic        PCLK,
    input  logic        PRESETn,

    input  logic [31:0] PADDR,
    input  logic        PSELx,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [31:0] PWDATA,

    output logic        PREADY,
    output logic [31:0] PRDATA,
    output logic        PSLVERR,

    //do testow
    input logic clk_b,
    input logic rst_n,

    input logic FSM_MUX_CDC,

    output logic Start,
    input logic pracuje,
    input logic DONE,

    output logic [5:0]  Ile_wsp,
    output logic [13:0] Ile_probek
);
    
// sygnały wewnętrzne apb <-> cdc
logic [5:0] p_address;
logic [15:0] p_data;
logic        p_wr;
logic [15:0] p_data_back;

//sygnały wewnętrzne cdc <-> reszta
logic [5:0]  CDC_A;
logic [15:0] CDC_data;
logic        CDC_wr;
logic [15:0] data_back;

//sygnały wewnętrzne dekoder <-> reszta
logic        Dekoder_MUX;
logic [4:0]  address_RAM;
logic        wr_RAM;
logic [2:0]  nr_Rejestru;
logic        wr_Rej;

//sygnały MUX_DEKODER
logic [15:0] Rej_out;  //sygnał z rejestrów kontrolnych
logic [15:0] wsp_data; //sygnał z RAM współczynników

//sygnały MUX_CDC_wsp
logic [4:0] wsp_address_in; //adres do RAM współczynników
logic [4:0] address_FIR;    //adres z FSM
//logic       FSM_MUX_CDC;    //sygnał z FSM do wyboru adresu

//APB
apb apb0(
    .PCLK      (PCLK     ),
    .PRESETn   (PRESETn  ),
    .PADDR     (PADDR    ),
    .PSELx     (PSELx    ),
    .PENABLE   (PENABLE  ),
    .PWRITE    (PWRITE   ),
    .PWDATA    (PWDATA   ),
    .PREADY    (PREADY   ),
    .PRDATA    (PRDATA   ),
    .PSLVERR   (PSLVERR  ),
    // tutaj dalej porty do podmodułów
    .p_address (p_address),
    .p_data    (p_data    ),
    .p_wr      (p_wr      ),
    .p_data_back(p_data_back)
);

// //CDC
// cdc_module cdc_module0(
//     clk_a     (PCLK),
//     rst_n     (rst_n), //reset z domeny B???

//     .p_address (p_address),
//     .p_data    (p_data    ),
//     .p_wr      (p_wr      ),
//     .p_data_back(p_data_back),

//     clk_b      (clk_b),

//     .CDC_A     (CDC_A    ),
//     .CDC_data  (CDC_data ),
//     .CDC_wr    (CDC_wr   ),
//     .data_back (data_back)
// )
//  DLA TESTÓW POMIJAĆ CDC
assign CDC_A    = p_address;
assign CDC_data = p_data;
assign CDC_wr   = p_wr;
assign p_data_back = data_back;

//Dekoder
decoder decoder0(
    .CDC_A(CDC_A),
    .CDC_wr(CDC_wr),

    .Dekoder_MUX(Dekoder_MUX),
    .address_RAM(address_RAM),
    .wr_RAM(wr_RAM),
    .nr_Rejestru(nr_Rejestru),
    .wr_Rej(wr_Rej)
);

//MUX_DEKODER
always_comb begin
    if (Dekoder_MUX) begin
        data_back = Rej_out;//rejestry kontrolne
    end else begin
        data_back = wsp_data;//RAM wspolczynnikow
    end
end

//MUX_CDC_wsp
always_comb begin
    if(FSM_MUX_CDC) begin
        wsp_address_in = address_RAM;
    end else begin
        wsp_address_in = address_FIR; 
    end
end

// to jest ten AND na schemacie
assign wr_RAM_in = wr_RAM && !pracuje; //sygnał zapisu do RAM tylko gdy FSM NIE pracuje

//RAM (tutaj jest jeszcze ten AND - ale może bez niego?)
ram ram0(
    .clk        (clk_b),
    .wr      (wr_RAM_in), 
    .adres    (wsp_address_in),
    .data    (CDC_data),
    .data_out   (wsp_data)
);

//Rejestry sterujace
ctrl_registers rejestry_ster0(
    .clk_b        (clk_b),
    .rst_n      (rst_n),

    .CDC_data   (CDC_data),
    .nr_Rejestru(nr_Rejestru),
    .wr_Rej     (wr_Rej),
    .Rej_out    (Rej_out),
    .Start      (Start),
    .Pracuje    (pracuje),
    .DONE       (DONE),

    .Ile_wsp    (Ile_wsp),
    .Ile_probek (Ile_probek)
);

endmodule
