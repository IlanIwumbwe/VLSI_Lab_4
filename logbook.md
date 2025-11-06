# VLSI Lab 4 Logbook - Self-test system

![](https://github.com/ELEC70142-VLSI-Coursework/Lab_4/blob/main/diagrams/cct_2.jpg)


## Add signature generator

<img width="1027" height="379" alt="image" src="https://github.com/user-attachments/assets/750e14d5-30fc-413c-a886-34bdb6a8b32b" />

```sv
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
```

## Modify NCVerilog testbench to check signatures

```sv
`timescale 1ns/1ps

module memtest_tb();

    localparam TESTS = 4;
    localparam CLK_PERIOD = 10;
    localparam PRBS_SEED = 16'hFFFF; 
    localparam SIG_SEED = 32'hFFFFFFFF;

    logic clk;
    logic rst;
    logic [31:0] dut_data;
    logic [15:0] mdl_data;
    logic test;
    logic [31:0] shift_data;     
    logic [31:0] ref_sig;

    logic go;
    string res;

    logic WRITE=0;

    always #(CLK_PERIOD/2) clk=~clk;


    memtest dut(
        .rst (rst),
        .clk (clk),
  	.ref_sig(ref_sig),
        .test(test),
	.go(go)	
    );



    initial begin
        // reset clock
        clk <= 1 ; rst <= 1;
        #(CLK_PERIOD) rst <= 0;


        mdl_data = PRBS_SEED;
        shift_data = SIG_SEED; 
        // Wait two cycles to sync the reading
        repeat(2) @(posedge clk);

        for (int i = 0; i < TESTS ; i++) begin
            // Memory write
            WRITE = 1;
            test = 0;
            repeat(32) @(posedge clk);



            // Memory read
            WRITE = 0;
            for(int j = 0; j < 32; j++) begin
		@(posedge clk);
                                 
            test = 1;

		shift_data = sig32(shift_data) ^ {mdl_data, mdl_data};
		
                mdl_data = prbs16(mdl_data);
		ref_sig = shift_data;

                $display("T: %d #:%2d MDL: %H\t go:  %d\n", $time,j, mdl_data, go);
            end
        end

        $finish(2);

    end

    // function for a 16bit PRBS
    function automatic [15:0] prbs16(input [15:0] seed);
        prbs16 = {seed[14:0], seed[15] ^ seed[14] ^ seed[12] ^ seed[3]};

    endfunction

   function automatic [31:0] sig32(input [31:0] seed);
        sig32 = {seed[30:0], seed[31] ^ seed[21] ^ seed[1] ^ seed[0]};
   endfunction

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(3, memtest_tb, dut);
    end

endmodule
```

## Memory self-test in GTKWave


<img width="739" height="151" alt="image" src="https://github.com/user-attachments/assets/2483d0a4-f1cf-4a8a-885e-abb877daa62b" />



## Challenge: comparing memory compiler SRAM with register manual register implementation



Timing the design post route using `timeDesign -postRoute` yields:


```
+--------------------+---------+---------+---------+
|     Setup mode     |   all   | reg2reg | default |
+--------------------+---------+---------+---------+
|           WNS (ns):| -0.093  | -0.093  |  0.350  |
|           TNS (ns):| -0.941  | -0.941  |  0.000  |
|    Violating Paths:|   17    |   17    |    0    |
|          All Paths:|   133   |   94    |   91    |
+--------------------+---------+---------+---------+
```

Timing post-routed design with self-designed ram block returns

```
+--------------------+---------+---------+---------+
|     Setup mode     |   all   | reg2reg | default |
+--------------------+---------+---------+---------+
|           WNS (ns):|  0.291  |  0.291  |  0.343  |
|           TNS (ns):|  0.000  |  0.000  |  0.000  |
|    Violating Paths:|    0    |    0    |    0    |
|          All Paths:|   683   |   617   |   618   |
+--------------------+---------+---------+---------+
```




