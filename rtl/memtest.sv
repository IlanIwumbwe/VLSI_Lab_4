`timescale 1ns/1ps

module memtest (
    input logic clk,
    input logic rst,
    input logic [31:0] ref_sig,
    input logic test,
    output logic go
);

    logic ctrl;
    logic sig_ctrl;
    logic [4:0] addr;
    logic [15:0] data;
    logic [31:0] mem_out;
    logic [31:0] sig;

    Counter counter(
        .clk(clk),
        .rst(rst),
        .en(~sig_ctrl),
        .count(addr)
    );

    Control control(
        .clk(clk),
        .rst(rst),
        .test(test),
	.ctrl(ctrl),    // control signal HIGH for write, LOW for read
	.sig_ctrl(sig_ctrl)    
); 

    PRBS16 prbs(
        .clk(clk),
        .rst(rst),
        .en(ctrl),
        .data_out(data)
    );

    TS1N65LPLL32X32M4 mem32x32( 
        .CLK(clk), 
        .CEB(1'b0), 
        .WEB(~ctrl),
        .A(addr), 
        .D({data,data}), 
        .BWEB(32'h0000_0000),
        .Q(mem_out),
        .TSEL(2'b01)
    );

    analyser signature(
	.clk(clk),
	.rst(rst),
	.input_signal(mem_out),
	.en(sig_ctrl),
 	.data_out(sig)
    );

    assign go = (sig == ref_sig);

endmodule
