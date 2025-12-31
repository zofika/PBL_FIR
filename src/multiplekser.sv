// 1 moduł MUX z parametrami

module multiplekser#(
    parameter WIDTH = 16
)(
    input wire [WIDTH-1:0] data_a,
    input wire [WIDTH-1:0] data_b,
    input wire sel,
    output logic [WIDTH-1:0] data_out
);

assign data_out = (sel) ? data_a : data_b;

endmodule


//Stary mux_AXI.sv
// module mux#(
//     parameter WIDTH = 13,//14
// )
// (
//     input wire clk,
//     input wire [WIDTH-1:0] A_probka_FIR,
//     input wire [WIDTH-1:0] a_address,
//     input wire FSM_MUX,
//     output logic [WIDTH-1:0] probka_address
// );
 

// always_ff @( posedge clk ) begin // jesli bez zegara always_comb 
//    if(FSM_MUX) probka_address <= a_address;
//    else probka_address <= A_probka_FIR;
// end
 

// endmodule