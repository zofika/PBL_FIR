module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/AXI_main.fst");
    $dumpvars(0, AXI_main);
end
endmodule
