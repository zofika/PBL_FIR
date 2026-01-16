

module licznik_petli(
    input clk,
    input rst_n,
    input reset_petla,
    input petla_en,
    input zapisz_wsp,
    input [5:0] wsp, //32 -> 5 bitow
    output logic full,
    output logic [4:0] adres // 0..31 4bity
);

logic [5:0] wsp_max;

always_ff @(posedge clk) begin
    if(!rst_n) begin
        wsp_max <= '0;
        adres <= '0;
        full <= '0;
    end else begin
        full <= '0;
        if(petla_en && !full) begin
            if(adres == (wsp_max - 1'b1)) begin
                //koniec
                full <= 1'b1;
                adres <= '0;
            end else
                adres <= adres + 1'b1;
        end else begin
            if(zapisz_wsp) begin
                wsp_max <= wsp; 
            end
            if(reset_petla) begin
                adres <= '0;
            end
        end
    end
end

endmodule