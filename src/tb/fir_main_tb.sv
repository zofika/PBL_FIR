

module fir_main_tb;

logic clk;
logic rst_n;
logic [5:0] f_ile_wsp;
logic [13:0] f_ile_probek;
logic [15:0] f_wsp_data;
logic f_start;
logic [15:0] f_probka;
logic [4:0] f_adress_fir;
logic f_fsm_mux_cdc;
logic f_pracuje;
logic f_done;
logic [12:0] f_a_probki_fir;
logic f_fsm_mux_wej;
logic f_fsm_mux_wyj;
logic [20:0] f_fir_probka_wynik;
logic f_fsm_wyj_wr;

//fir
FIR_main u_fir(
    .clk(clk),
    .rst_n(rst_n),
    .f_ile_wsp(f_ile_wsp),
    .f_ile_probek(f_ile_probek),
    .f_wsp_data(f_wsp_data),
    .f_start(f_start),
    .f_probka(f_probka),
    .f_adress_fir(f_adress_fir),
    .f_fsm_mux_cdc(f_fsm_mux_cdc),
    .f_pracuje(f_pracuje),
    .f_done(f_done),
    .f_a_probki_fir(f_a_probki_fir),
    .f_fsm_mux_wej(f_fsm_mux_wej),
    .f_fsm_mux_wyj(f_fsm_mux_wyj),
    .f_fir_probka_wynik(f_fir_probka_wynik),
    .f_fsm_wyj_wr(f_fsm_wyj_wr)
);

//ramy
ram #(
    .ADDR_WIDTH(5),
    .DATA_WIDTH(16)
) wsp_ram (
    .clk(clk),
    .wr(1'b0),//wr_mem
    .adres(f_adress_fir),//adres
    .data(16'd0),
    .data_out(f_wsp_data)
);
ram #(
    .ADDR_WIDTH(13),
    .DATA_WIDTH(16)
) probk_ram (
    .clk(clk),
    .wr(1'b0),//wr_mem
    .adres(f_a_probki_fir),//adres
    .data(16'd0),
    .data_out(f_probka)
);
logic [15:0] meh;
ram #(
    .ADDR_WIDTH(13),
    .DATA_WIDTH(16)
) probk_ram_wyn (
    .clk(clk),
    .wr(f_fsm_wyj_wr),//wr_mem
    .adres(f_a_probki_fir),//adres
    .data(f_fir_probka_wynik[15:0]),
    .data_out(meh)
);


initial clk = 1;
always #5 clk = ~clk;

initial begin
    $dumpfile("fir_main_tb.vcd");
    $dumpvars(0, fir_main_tb);
end


initial begin

    //wsp
    //testyyy
    // wsp_ram.pamiec_RAM[0] = 16'hA000;
    // wsp_ram.pamiec_RAM[1] = 16'hB000;
    // wsp_ram.pamiec_RAM[2] = 16'hC000;
    // wsp_ram.pamiec_RAM[0] = 16'h000A;
    // wsp_ram.pamiec_RAM[1] = 16'h000B;
    // wsp_ram.pamiec_RAM[2] = 16'h000C;
    wsp_ram.pamiec_RAM[0] = 16'b1100000000000000;
    wsp_ram.pamiec_RAM[1] = 16'b0100000000000000;
    wsp_ram.pamiec_RAM[2] = 16'b1100000000000000;
    //---
    // wsp_ram.pamiec_RAM[0] = 16'b0100000000000000;
    // wsp_ram.pamiec_RAM[1] = 16'b0100000000000000;
    // wsp_ram.pamiec_RAM[2] = 16'b0100000000000000;
    wsp_ram.pamiec_RAM[3] = 16'b1111111111111111;

    f_ile_wsp = 3; //ile wsp
    //probki
    // probk_ram.pamiec_RAM[0] = 16'b0000000000000001;
    // probk_ram.pamiec_RAM[1] = 16'b0000000000000010;
    // probk_ram.pamiec_RAM[2] = 16'b0000000000000011;
    // probk_ram.pamiec_RAM[3] = 16'b0000000000000100;
    probk_ram.pamiec_RAM[0] = 16'b0010000000000000;
    probk_ram.pamiec_RAM[1] = 16'b0010000000000000;
    probk_ram.pamiec_RAM[2] = 16'b0010000000000000;
    probk_ram.pamiec_RAM[3] = 16'b0010000000000000;
    probk_ram.pamiec_RAM[4] = 16'b1111111111111111;

    f_ile_probek = 3; // ile probek

    
    rst_n = 0;
    f_start = 0;
    #10;
    rst_n = 1;
    #40;
    f_start = 1;
    #10;
    f_start = 0;

    #10;

    #500;
    $finish;
end

endmodule