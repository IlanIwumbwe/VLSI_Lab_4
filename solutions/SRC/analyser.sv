module analyser#(
    parameter SEED = 32'hFFFFFFFF
)
(
    input logic          clk,        // clock
    input logic          rst,        // reset
    input logic [31:0]  input_signal,
    input logic en,	
    
    output logic [31:0]  data_out    // pseudo-random output
);

logic [32:1]     sreg;

always_ff @ (posedge clk, posedge rst)
    if (rst)
        sreg <= SEED;
    else if (en)
    	sreg <= {sreg[31:1], sreg[1] ^ sreg[2] ^ sreg[22] ^ sreg[32]} ^ input_signal;
    else
	sreg <= sreg;

assign data_out = sreg;
endmodule 

