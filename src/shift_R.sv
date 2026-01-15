

module shift_R(
    input clk,
    input rst_n,
    input [15:0] probka_in,
    output logic [15:0] out,
    input nowa_shift,
    input reset_shift,
    input [4:0] adres //0..31
);

// logic [15:0] reg_shift [0:31];
logic [31:0][15:0] reg_shift;

always_ff @(posedge clk) begin
    if(!rst_n) begin
        reg_shift <= '0;
    end else begin

        if(reset_shift) begin
            reg_shift <= '0;
        end
        if(nowa_shift) begin
            reg_shift <= {reg_shift[31:0], probka_in};//..  {probka_in, reg_shift[31:1]};//..
            // +  tutaj trzeba wypelniac na koniec zeramii... albo w ram wej beda zera albo tutaj cos wymyslec
        end
    end
end

assign out = reg_shift[adres];

endmodule