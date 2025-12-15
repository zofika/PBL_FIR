module mux#(
    parameter WIDTH = 13,//14
)
(
    input wire clk,
    input wire [WIDTH-1:0] A_probka_FIR,
    input wire [WIDTH-1:0] a_address,
    input wire FSM_MUX,
    output logic [WIDTH-1:0] probka_address
);
 

always_ff @( posedge clk ) begin // jesli bez zegara always_comb 
   if(FSM_MUX) probka_address <= a_address;
   else probka_address <= A_probka_FIR;
end
 

endmodule