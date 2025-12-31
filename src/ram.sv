// jeden modul RAM z paramterami.

module ram#(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 16
)
(
    input wire clk,
    input wire [ADDR_WIDTH-1:0] adres,
    input wire [DATA_WIDTH-1:0] data,
    input wire wr,
    output logic [DATA_WIDTH-1:0] data_out
);

logic [DATA_WIDTH-1:0] pamiec_RAM [0:(1<<ADDR_WIDTH)-1];

always_ff @( posedge clk ) begin : Ram
    if(wr) pamiec_RAM[adres] <= data;
    else data_out <= pamiec_RAM[adres];
end

//assign data_out = pamiec_RAM[adres];

endmodule