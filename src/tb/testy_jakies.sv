

module testy_jakies;

    logic [5:0] CDC_A;
    logic       CDC_wr;

    logic       Dekoder_MUX;
    logic [4:0] address_RAM;
    logic       wr_RAM;
    logic [2:0] nr_Rejestru;
    logic       wr_Rej;

    localparam adres_W = 5;
    localparam data_W = 16;
    // sygnały
    logic clk;
    logic clk_a;
    logic wr_mem;
    logic [adres_W-1:0] adres;
    logic [data_W-1:0] dane;
    logic [data_W-1:0] out;


    logic [15:0] data_back;
    logic wsp_addres_in;

    reg rst_n;

    reg  [15:0] CDC_data;

    reg         Pracuje;
    reg         DONE;

    wire [15:0] Rej_out;
    wire        Start;
    wire [5:0]  Ile_wsp;
    wire [13:0] Ile_probek;

    reg  [5:0]  p_address;
    reg  [15:0] p_data;
    reg         p_wr;
    wire [15:0] p_data_back;


    cdc_module dutcdc (
        .clk_a(clk_a),
        .clk_b(clk),
        .rst_n(rst_n),

        .p_address(p_address),
        .p_data(p_data),
        .p_wr(p_wr),
        .p_data_back(p_data_back),

        .CDC_A(CDC_A),
        .CDC_data(CDC_data),
        .CDC_wr(CDC_wr),
        .data_back(data_back)
    );
    
    decoder dut (
    .CDC_A(CDC_A),
    .CDC_wr(CDC_wr),
    .Dekoder_MUX(Dekoder_MUX),
    .address_RAM(address_RAM),
    .wr_RAM(wr_RAM),
    .nr_Rejestru(nr_Rejestru),
    .wr_Rej(wr_Rej)
    );

        // instancja modułu
    ram #(
        .ADDR_WIDTH(adres_W),
        .DATA_WIDTH(data_W)
    ) DUT (
        .clk(clk),
        .wr(wr_RAM),//wr_mem
        .adres(address_RAM),//adres
        .data(CDC_data),
        .data_out(out)
    );


    ctrl_registers dutreg (
        .clk_b(clk),
        .rst_n(rst_n),
        .CDC_data(CDC_data),
        .nr_Rejestru(nr_Rejestru),
        .wr_Rej(wr_Rej),
        .Rej_out(Rej_out),
        .Start(Start),
        .Pracuje(Pracuje),
        .DONE(DONE),
        .Ile_wsp(Ile_wsp),
        .Ile_probek(Ile_probek)
    );

    multiplekser #(.WIDTH(16)) duta (
        .data_a(Rej_out),
        .data_b(out),
        .sel(Dekoder_MUX),
        .data_out(data_back)
    );


initial begin
    $dumpfile("testy_jakies.vcd");
    $dumpvars(0, testy_jakies);
end

initial clk = 1;
always #5 clk = ~clk;

initial clk_a = 1;
always #10 clk_a = ~clk_a;

initial begin
//                    3'b000: rej[0] <= CDC_data; // START
                    // 3'b011: rej[3] <= CDC_data; // ile_wsp
                    // 3'b100: rej[4] <= CDC_data; // ile_probek

    rst_n = 0;
    //CDC_A = 6'b000000;
    //CDC_wr = 1'b0;
    //CDC_data = 16'd0;

    p_address = 6'b000000;
    p_data = 16'd0;
    p_wr = 1'b0;
    

    Pracuje = 0;
    DONE = 0;
    #10;
    rst_n = 1;

    

    #10;
    p_address = 6'b000011;
    p_wr = 1'b0;
    p_data = 16'd5;
    #10;
    p_address = 6'b000101;
    p_wr = 1'b0;
    p_data = 16'd10;


    // p_data = 16'd0;
    // p_address = 6'b000011;
    // p_wr = 1'b0;
    // #30; //zapis rej kontr
    // p_data = 16'd1;
    // p_address = 6'b100000;
    // p_wr = 1'b1;
    // #10;
    // p_data = 16'd32;
    // p_address = 6'b100011;
    // p_wr = 1'b1;
    // #10;
    // p_data = 16'd100;
    // p_address = 6'b100100;
    // p_wr = 1'b1;
    // #30; //odczyt rej kontr
    // p_data = 16'd1;
    // p_address = 6'b100000;
    // p_wr = 1'b0;
    // #10;
    // p_data = 16'd21;
    // p_address = 6'b100011;
    // p_wr = 1'b0;
    // #10;
    // p_data = 16'd33;
    // p_address = 6'b100100;
    // p_wr = 1'b0;

    #100;
    $finish;
end

/*
    #10;
    //CDC_A = 6'b000011;
    CDC_wr = 1'b1;
    CDC_data = 16'd5;
    #30;
    CDC_data = 16'd0;
    //CDC_A = 6'b000011;
    CDC_wr = 1'b0;
    #30; //zapis rej kontr
    CDC_data = 16'd1;
    //CDC_A = 6'b100000;
    CDC_wr = 1'b1;
    #10;
    CDC_data = 16'd32;
    //CDC_A = 6'b100011;
    CDC_wr = 1'b1;
    #10;
    CDC_data = 16'd100;
    //CDC_A = 6'b100100;
    CDC_wr = 1'b1;
    #30; //odczyt rej kontr
    CDC_data = 16'd1;
    //CDC_A = 6'b100000;
    CDC_wr = 1'b0;
    #10;
    CDC_data = 16'd21;
    //CDC_A = 6'b100011;
    CDC_wr = 1'b0;
    #10;
    CDC_data = 16'd33;
    //CDC_A = 6'b100100;
    CDC_wr = 1'b0;
*/

    // ctrl_registers dut (
    //     .clk_b(clk_b),
    //     .rst_n(rst_n),
    //     .CDC_data(CDC_data),
    //     .nr_Rejestru(nr_Rejestru),
    //     .wr_Rej(wr_Rej),
    //     .Rej_out(Rej_out),
    //     .Start(Start),
    //     .Pracuje(Pracuje),
    //     .DONE(DONE),
    //     .Ile_wsp(Ile_wsp),
    //     .Ile_probek(Ile_probek)
    // );

endmodule