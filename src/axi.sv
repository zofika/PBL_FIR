////////////////////////////////////////////////////////////////////////
//   AXI
//
//  szerokosci max narazie, bez dostosowywania
///////////////////////////////////////////////////////////////////////

module axi#(
    parameter data_out_SIZE = 16, //rozm. danych do RAM wej.
    parameter address_out_SIZE = 13, //rozm. adresu do RAM wej.
    parameter data_in_SIZE = 21, //rozm. danych z RAM wyj.
    parameter address_out2_SIZE = 13 //rozm. adresu do RAM wyj.
)(
    //zegar i reset
    input wire a_clk,
    input wire a_rst_n,

    //Kanal zapisu - adres
    input wire [31:0] awaddr,
    input wire awvalid,
    output logic awready,
    input wire [3:0] awlen,//[7:0]
    input wire [2:0] awsize,
    input wire [1:0] awburst,

    //Kanal zapisu - data
    input wire wvalid,
    output logic wready,
    input wire wlast,
    input wire [63:0] wdata,
    input wire [7:0] wstrb,

    //Kanal zapisu - odpowiedz
    output logic bvalid,
    input wire bready,
    output logic [1:0] bresp,

    //Kanal odczytu - adres
    input wire arvalid,
    output logic arready,
    input wire [31:0] araddr,
    input wire [2:0] arsize,
    input wire [1:0] arburst,
    input wire [3:0] arlen,//[7:0]

    //Kanal odczytu - data
    output logic rvalid,
    input wire rready,
    output logic rlast,
    output logic [63:0] rdata,
    output logic [1:0] rresp,

    //Reszta
    //RAM wej
    output logic [address_out_SIZE-1:0] a_address_wr,
    output logic [data_out_SIZE-1:0] a_data_out,
    output logic a_wr,
    input wire [data_out_SIZE-1:0] probka,
    //RAM wyj
    output logic [address_out2_SIZE-1:0] a_address_rd,
    input wire [data_in_SIZE-1:0] a_data_in,

    //TESTY
    output logic [1:0] state_w_out
);

//potrzebne rejestry
logic [address_out_SIZE-1:0] awaddr_reg; //przechowanie adresu dla bursta
logic [3:0] awlen_reg;
logic [2:0] awsize_reg;
logic [1:0] awburst_reg;
//logic [data_out_SIZE-1:0] awdata_reg;

logic [(address_out_SIZE)-1:0] araddr_reg; //+1 bo to idzie do RAM wej albo do wyj... dekoder bedzie
logic araddr_reg_MSB;//do wyboru
logic [2:0] arsize_reg;
logic [1:0] arbursts_reg;
logic [3:0] arlen_reg;


logic ram_wr_r;
logic [address_out_SIZE-1:0] ram_addr_r;
logic [data_out_SIZE-1:0] ram_data_r;

typedef enum logic [2:0] { 
    w_IDLE = 3'b000,
    w_DATA_handshake,
    w_DATA,
    w_DATA_address,
    w_END 
} fsm_zapis;
fsm_zapis state_w;
fsm_zapis next_state_w;
//assign state_w_out = state_w; // TEST

typedef enum logic [1:0] { 
    r_IDLE = 2'b00,
    r_DATA_handshake,
    r_DATA,
    r_DATA_address
} fsm_odczyt;
fsm_odczyt state_r;
fsm_odczyt next_state_r;
//assign state_w_out = state_r; // TEST

// ----------------------------------
//kanaly ----------------------------------
//Zapis  //adres,data,resp
/*
bresp coś z tym też?(ogolnie odpowiedzi)
co z tym size?
awburst_reg wersje różne
if(wlast) dodać || licznik brursta do zera.
*/
logic pierwszy_adres;
logic pierwszy_burst;
always @(posedge a_clk) begin
    if(!a_rst_n) begin
        awaddr_reg <= '0;
        awlen_reg <= '0;
        awsize_reg <= '0;
        awburst_reg <= '0;

        pierwszy_adres <= 1'b0;
        pierwszy_burst <= 1'b0;

        //awdata_reg <= '0;

        state_w <= w_IDLE;
    end else begin
        state_w <= next_state_w;

        //Dostep do RAM - ZAPIS
        a_wr <= ram_wr_r;
        a_address_wr <= ram_addr_r;//ram_addr_r;  awaddr_reg
        //strobe
        //a_data_out <= ram_data_r;
        a_data_out <= '0;
        if(wstrb[0]) a_data_out[7:0] <= ram_data_r[7:0];
        if(wstrb[1]) a_data_out[15:8] <= ram_data_r[15:8];

        if(next_state_w == w_DATA_handshake) begin
            awaddr_reg <= awaddr;// - 1'b1;  // zapisz adres
            awlen_reg <= awlen + 1'b1;
            awsize_reg <= awsize;
            awburst_reg <= awburst;

            pierwszy_adres <= 1'b0;
            pierwszy_burst <= 1'b0;

            //awdata_reg <= wdata;
        end

        if(next_state_w == w_DATA && wvalid) begin//!pierwszy_adres next_state_w == w_DATA
            pierwszy_adres <= 1'b1;
            pierwszy_burst <= 1'b1;
            if(awburst_reg == 2'b01 ) begin //ten jeden rodzaj narazie if(awburst_reg == 2'b01) begin
            //&& pierwszy_adres
                awaddr_reg <= awaddr_reg + 1'b1;
                
            end
            //awdata_reg <= wdata;
            if(awlen_reg != 4'b0000 ) begin
                //&& pierwszy_burst
                awlen_reg <= awlen_reg - 1'b1;
            end
        end
    end
end

always_comb begin
    next_state_w = state_w;
    
    //a_wr = '0;
    ram_wr_r = '0;
    //a_data_out = '0;
    ram_data_r = '0;
    //a_address_wr = '0;
    ram_addr_r = '0;

    awready = 1'b0; //awready <= 1'b0;
    wready = 1'b0;
    bresp = 2'b01;//error jakis
    bvalid = '0;

    //pierwszy_adres = 1'b0;

    case(state_w)
        w_IDLE: begin
            //awready = 1'b1;
            if(awvalid) begin //jezeli pojawi sie handsahe
                next_state_w = w_DATA_handshake;//kolejny stan w_DATA_handshake
            end else
                next_state_w = w_IDLE;
        end
        w_DATA_handshake: begin
            if(awvalid)
                awready = 1'b1;
            next_state_w = w_DATA;
            //a_address_wr = awaddr_reg;
            // ram_addr_r = awaddr_reg;
            // ram_data_r = wdata;
        end

        w_DATA: begin
            wready = 1'b1;
            if(wvalid) begin
                //Odczyt danej + sygnały do zapisu do RAM wej
                //a_wr = '1;
                ram_wr_r = '1;
                //a_address_wr = awaddr_reg;
                ram_addr_r = awaddr_reg;
                //a_data_out = wdata;//wdata;awdata_reg// & mask;
                ram_data_r = wdata;                 
            end else begin
                next_state_w = w_DATA;
                //next_state_w = w_DATA_handshake;
            end
            if(awlen_reg == 4'b0000) begin //Jeśli już to była ostatnia dana.
                next_state_w = w_END;
            end else
                next_state_w = w_DATA;   
        end

        w_DATA_address: begin
            //a_address_wr = awaddr_reg;
            next_state_w = w_DATA;
        end        
        w_END: begin //resp
            bvalid = 1'b1;
            bresp = 2'b00;//OKEY
            if(bready) begin
                //bvalid = 1'b1;
                next_state_w = w_IDLE;
                //bresp = 2'b00;//OKEY
            end else begin
                next_state_w = w_END;
            end
        end
        default: next_state_w = w_IDLE;
    endcase
end
// ------------------------------------------------------------------------------------------------------
//Odczyt //adres,data
always @(posedge a_clk) begin
    if(!a_rst_n) begin
        araddr_reg <= '0;
        arlen_reg <= '0;
        arsize_reg <= '0;
        arbursts_reg <= '0;

        state_r <= r_IDLE;
    end else begin
        state_r <= next_state_r;
        if(next_state_r == r_DATA_handshake) begin
            araddr_reg <= araddr[address_out_SIZE-1:0];
            araddr_reg_MSB <= araddr[address_out_SIZE];
            arlen_reg <= arlen;//0=>1 dana, 1=> 2,... + 1'b1
            arsize_reg <= arsize;
            arbursts_reg <= arburst;
        end
        if(next_state_r == r_DATA_address /*&& rready*/) begin
            
            if(arbursts_reg == 2'b01) begin
                araddr_reg <= araddr_reg + 1'b1;//INC
            end

            if(arlen_reg != 4'b0000) begin
                arlen_reg <= arlen_reg - 1'b1;
            end

        end
    end
end
always_comb begin   //always_comb
    next_state_r = state_r;
    
    a_address_wr = '0;
    a_address_rd = '0;

    arready = 1'b0;

    rdata = '0;
    rlast = '0;
    rresp = 2'b10;//jakis error
    rvalid = 1'b0;

    case(state_r)
        r_IDLE: begin
            //arready = 1'b1;
            if(arvalid) begin
                next_state_r = r_DATA_handshake;
            end else begin
                next_state_r = r_IDLE;
            end
        end
        r_DATA_handshake: begin //zapisz Adres. 1 raz
            arready = 1'b1;
            next_state_r = r_DATA;
            case(araddr_reg_MSB)
                1'b0: a_address_wr = araddr_reg;
                1'b1: a_address_rd = araddr_reg;
            endcase
            //a_address_wr = araddr_reg; //tutaj wysylam pierwszy adres juz, zeby potem odrazu moglem odczytac dana jakas.
        end
        r_DATA: begin 
            //wystawiam daną i valid.
            //rdata = probka;
            case(araddr_reg_MSB)
                1'b0: rdata = probka;
                1'b1: rdata = a_data_in;
            endcase
            rvalid = 1'b1;
            rresp = 2'b00; //OKAY
            if(arlen_reg == 4'b0000) begin //ostatnia dana juz.
                rlast = 1'b1;
            end
            //dane wysawione teraz czekam na ready od mastera
            if(rready) begin //jest
                if(arlen_reg == 4'b0000) begin
                    next_state_r = r_IDLE;
                end else begin
                    next_state_r = r_DATA_address;
                end
            end else begin //nie ma
                next_state_r = r_DATA; //petla ale bez nowego adresu
                //a_address_wr = araddr_reg;
                case(araddr_reg_MSB)
                    1'b0: a_address_wr = araddr_reg;
                    1'b1: a_address_rd = araddr_reg;
                endcase                
            end
            //a_address_wr = araddr_reg;//zawsze daje adres tutaj
            case(araddr_reg_MSB)
                1'b0: a_address_wr = araddr_reg;
                1'b1: a_address_rd = araddr_reg;
            endcase            
        end
        r_DATA_address: begin
            //po odczycie przez mastera, nowy adres, czekamy 1 takt na dane z ram
            rvalid = 1'b0;
            //a_address_wr = araddr_reg;
            case(araddr_reg_MSB)
                1'b0: a_address_wr = araddr_reg;
                1'b1: a_address_rd = araddr_reg;
            endcase
            next_state_r = r_DATA;
        end
        default: next_state_r = r_IDLE;
    endcase
end

endmodule