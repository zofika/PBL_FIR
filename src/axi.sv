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


typedef enum logic [1:0] { 
    w_IDLE = 2'b00,
    w_DATA,
    w_END
} fsm_zapis;
fsm_zapis state_w;
fsm_zapis next_state_w;

assign state_w_out = state_w;

//kanaly ----------------------------------
//Zapis  //adres,data,resp
always @(posedge a_clk) begin
    if(!a_rst_n) begin
        awaddr_reg <= '0;
        awlen_reg <= '0;
        awsize_reg <= '0;
        awburst_reg <= '0;

        state_w <= w_IDLE;
    end else begin
        state_w <= next_state_w;
    end
end
// logic [63:0] mask = {
//     {8{wstrb[7]}}, {8{wstrb[6]}}, {8{wstrb[5]}}, {8{wstrb[4]}},
//     {8{wstrb[3]}}, {8{wstrb[2]}}, {8{wstrb[1]}}, {8{wstrb[0]}}
// };
always_comb begin
    next_state_w = state_w;
    
    a_wr = '0;
    a_data_out = '0;
    a_address_wr = '0;

    awready = 1'b0; //awready <= 1'b0;
    wready = 1'b0;
    bresp = '0;
    bvalid = '0;



    case(state_w)
        w_IDLE: begin
            awready = 1'b1; //w tym stanie chce to miec na 1.
            if(awvalid && awready) begin //jezeli pojawi sie handsahe
                next_state_w = w_DATA;//kolejny stan
                //awready = 1'b0; //na zero
                awaddr_reg = awaddr;  // zapisz adres
                awlen_reg = awlen;
                awsize_reg = awsize;
                awburst_reg = awburst;
            end
        end
        w_DATA: begin
            wready = 1'b1;
            if(wvalid && wready) begin
                //Odczyt danej + sygnały do zapisu do RAM wej
                a_wr = '1;
                a_address_wr = awaddr_reg;
                a_data_out = wdata;// & mask;
                //if(wstrb[0]) a_data_out[7:0] = wdata[7:0];
                //if(wstrb[1]) a_data_out[15:8] = wdata[15:8];
                //Dodac wiecej jak cos - nie dziala

                if(wlast) begin //Jeśli już to była ostatnia dana.
                    next_state_w = w_END;
                end else begin
                    if(awburst_reg == 2'b01) begin //ten jeden rodzaj narazie
                        awaddr_reg = awaddr_reg + 1'b1;
                    end
                    next_state_w = w_DATA;
                end
            end
        end
        w_END: begin
            bvalid = 1'b1;
            if(bready && bvalid) begin
                next_state_w = w_IDLE;
                bresp = 2'b01;//01 żeby coś było widać
            end
        end
        default: state_w = w_IDLE;
    endcase
end

//Odczyt




// always @(posedge a_clk) begin
//     if(!a_rst_n) begin
//         awready <= 1'b0; //awready <= 1'b0;
//         wready <= 1'b0;
//         bresp <= '0;
//         bvalid <= '0;
//         state_w <= w_IDLE;

//         awaddr_reg <= '0;
//         awlen_reg <= '0;
//         awsize_reg <= '0;
//         awburst_reg <= '0;
//         a_wr <= '0;
//         a_data_out <= '0;
//         a_address_wr <= '0;
//     end else begin

//         bresp <= '0;
//         bvalid <= '0;
//         wready <= '0;
//         awready <= '0;  //?
//         a_address_wr <= '0;
//         a_data_out <= '0;
//         a_wr <= '0;

//         //FSM
//         //$display("state_w w w_IDLE jestem %t , %b",$time, state_w);
//         //$display("%t State after: %d", $time, state_w);

//         case(state_w)
//         w_IDLE: begin
//             awready <= 1'b1;
//             //bvalid <= 1'b0;

//             if(awvalid && awready) begin //handshake
//                 $display("HANDSHAKE w_IDLE at time %t", $time);
//                 awaddr_reg <= awaddr[address_out_SIZE-1:0]; //adres
//                 awlen_reg <= awlen;
//                 awsize_reg <= awsize;
//                 awburst_reg <= awburst;
//                 //awready <= 1'b0;
//                 state_w <= w_DATA;// w_DATA;
//                 wready <= 1'b1;
//                 awready = 1'b0;
//                 $display("state_w w w_IDLE jestem %t %b", $time, state_w);
//                 //$display("wready 0 %t %b", $time, wready);
//             end
//         end
//         w_DATA: begin
//             //awready <= 1'b0;
//             wready <= 1'b1;
//             //awready <= 1'b0;
//             //$display("wready 1 %t %b", $time, wready);
//             if(wvalid && wready) begin //handshake
//                 $display("wready 2 %t %b", $time, wready);
//                 $display("HANDSHAKE w_DATA at time %t", $time);
//                 a_wr <= '1;
//                 a_address_wr <= awaddr_reg;
//                 //a_data_out <= wdata[data_out_SIZE-1:0];  //data_out 16bitowy
//                 if(wstrb[0]) a_data_out[7:0] <= wdata[7:0];
//                 if(wstrb[1]) a_data_out[15:8] <= wdata[15:8];
//                 //Dodac wiecej jak cos

//                 if(wlast || awlen_reg == 1'b0) begin //ostatni juz (wszystkie dane juz przeslane - koniec)
//                     wready <= 1'b0;
//                     state_w <= w_END;
//                     bvalid <= 1'b1;
//                     bresp <= 2'b00;
//                 end else begin //dalej burst
//                     if(awburst_reg == 2'b01) begin //ten jeden rodzaj narazie
//                         awaddr_reg <= awaddr_reg + 1'b1;
//                     end
//                     awlen_reg <= awlen_reg - 1'b1;
//                 end
//             end
//         end
//         w_END: begin
//             //wready <= 1'b0;
//             //bvalid <= 1'b1;
//             //bresp <= 2'b00;//jakies bledy potem tez
//             if(bready && bvalid) begin
//                 //bvalid <= 1'b0;
//                 state_w <= w_IDLE;
//                 awready <= 1'b1;
//             end
//         end
//         default: state_w <= w_IDLE;
//         endcase
//     end
// end



endmodule