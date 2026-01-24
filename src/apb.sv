module apb (
    // APB3 clock & reset
    input  logic        PCLK,
    input  logic        PRESETn,

    // APB3 address & control
    input  logic [31:0] PADDR,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [31:0] PWDATA,

    // APB3 response
    output logic        PREADY,
    output logic [31:0] PRDATA,
    output logic        PSLVERR,

    // Internal peripheral interface (jak na rysunku)
    output logic [5:0]  p_address,
    output logic [15:0] p_data,
    output logic        p_wr,
    input  logic [15:0] p_data_back
);

    logic rd_waiting; //sygnał wait-state dla odczytu

    initial begin
        $dumpfile("apb_dump_cocotb.vcd");
        $dumpvars(0, apb);
    end

    assign PSLVERR = 1'b0; // Brak błędów slave

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PRDATA    <= 32'b0;
            PREADY    <= 1'b0;
            p_address <= 6'b0;
            p_data    <= 16'b0;
            p_wr      <= 1'b0;

            rd_waiting   <= 1'b1;
        end else begin
            p_wr   <= 1'b0; // domyślnie 0 (impuls)
            PREADY <= 1'b0;
            
            // WRITE without wait state, T2 (access phase)
            if (PSEL && PWRITE && !PENABLE) begin
                p_address <= PADDR[5:0];
                p_data    <= PWDATA[15:0];
                PREADY    <= 1'b1; //dane przyjęte
                p_wr      <= 1'b1; //impuls zapisu
            end

            // READ 
            if (PSEL && !PWRITE && !PENABLE) begin
                p_address <= PADDR[5:0]; //zapamiętaj adres
            end else if (PSEL && !PWRITE && PENABLE && rd_waiting) begin
                PREADY <= 1'b0; //niegotowy
                rd_waiting <= 1'b0;
            end else if (PSEL && !PWRITE && PENABLE && !rd_waiting) begin
                PREADY <= 1'b1; //gotowy
                PRDATA <= {16'b0, p_data_back};
                rd_waiting <= 1'b1;
            end
        end
    end

endmodule
