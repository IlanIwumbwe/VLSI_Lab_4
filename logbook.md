### Memory self-test:
<img width="739" height="151" alt="image" src="https://github.com/user-attachments/assets/2483d0a4-f1cf-4a8a-885e-abb877daa62b" />

### Testbench:
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

Timing the design post route using `timeDesign -postRoute` yields:
```
 Reset EOS DB
Ignoring AAE DB Resetting ...
**WARN: (IMPEXT-3518):	The lower process node is set (using command 'setDesignMode') but the technology file for TQuantus extraction not specified. Therefore, going for postRoute (effortLevel low) extraction instead of recommended extractor 'TQuantus' for lower nodes. Use command 'set_analysis_view/update_rc_corner' to specify the technology file for TQuantus extraction to take place.
Extraction called for design 'memtest' of instances=1699 and nets=550 using extraction engine 'postRoute' at effort level 'low' .
PostRoute (effortLevel low) RC Extraction called for design memtest.
RC Extraction called in multi-corner(1) mode.
**WARN: (IMPEXT-3442):	The version of the capacitance table file being used is obsolete and is no longer recommended. For improved accuracy, generate the capacitance table file using the generateCapTbl command.
Process corner(s) are loaded.
 Corner: tsmc65_rc_corner_typ
extractDetailRC Option : -outfile /tmp/innovus_temp_27277_ee-mill1_ii122_RSidRS/memtest_27277_jTz5cr.rcdb.d -maxResLength 200  -extended
RC Mode: PostRoute -effortLevel low [Extended CapTable, RC Table Resistances]
      RC Corner Indexes            0   
Capacitance Scaling Factor   : 1.00000 
Coupling Cap. Scaling Factor : 1.00000 
Resistance Scaling Factor    : 1.00000 
Clock Cap. Scaling Factor    : 1.00000 
Clock Res. Scaling Factor    : 1.00000 
Shrink Factor                : 1.00000
Initializing multi-corner capacitance tables ... 
Initializing multi-corner resistance tables ...
Checking LVS Completed (CPU Time= 0:00:00.0  MEM= 1210.0M)
Extracted 10.0427% (CPU Time= 0:00:00.1  MEM= 1272.0M)
Extracted 20.0569% (CPU Time= 0:00:00.1  MEM= 1272.0M)
Extracted 30.0427% (CPU Time= 0:00:00.1  MEM= 1272.0M)
Extracted 40.0569% (CPU Time= 0:00:00.1  MEM= 1272.0M)
Extracted 50.0427% (CPU Time= 0:00:00.1  MEM= 1272.0M)
Extracted 60.0569% (CPU Time= 0:00:00.1  MEM= 1272.0M)
Extracted 70.0427% (CPU Time= 0:00:00.1  MEM= 1272.0M)
Extracted 80.0569% (CPU Time= 0:00:00.1  MEM= 1272.0M)
Extracted 90.0427% (CPU Time= 0:00:00.1  MEM= 1272.0M)
Extracted 100% (CPU Time= 0:00:00.1  MEM= 1272.0M)
Number of Extracted Resistors     : 7007
Number of Extracted Ground Cap.   : 6882
Number of Extracted Coupling Cap. : 7392
Filtering XCap in 'relativeAndCoupling' mode using values coupling_c_threshold=3fF, relative_c_threshold=0.03, and total_c_threshold=5fF.
 Corner: tsmc65_rc_corner_typ
Checking LVS Completed (CPU Time= 0:00:00.0  MEM= 1256.0M)
PostRoute (effortLevel low) RC Extraction DONE (CPU Time: 0:00:00.2  Real Time: 0:00:00.0  MEM: 1264.023M)
Starting SI iteration 1 using Infinite Timing Windows
#################################################################################
# Design Stage: PostRoute
# Design Name: memtest
# Design Mode: 65nm
# Analysis Mode: MMMC OCV 
# Parasitics Mode: SPEF/RCDB
# Signoff Settings: SI On 
#################################################################################
AAE_INFO: 1 threads acquired from CTE.
Calculate early delays in OCV mode...
Calculate late delays in OCV mode...
Start delay calculation (fullDC) (1 T). (MEM=1239.82)
Initializing multi-corner capacitance tables ... 
Initializing multi-corner resistance tables ...
AAE_INFO: 1 threads acquired from CTE.
Total number of fetched objects 543
AAE_INFO: Total number of nets for which stage creation was skipped for all views 0
AAE_INFO-618: Total number of nets in the design is 550,  98.5 percent of the nets selected for SI analysis
End delay calculation. (MEM=1294.12 CPU=0:00:00.1 REAL=0:00:00.0)
End delay calculation (fullDC). (MEM=1294.12 CPU=0:00:00.3 REAL=0:00:00.0)
Loading CTE timing window with TwFlowType 0...(CPU = 0:00:00.0, REAL = 0:00:00.0, MEM = 1294.1M)
Add other clocks and setupCteToAAEClockMapping during iter 1
Loading CTE timing window is completed (CPU = 0:00:00.0, REAL = 0:00:00.0, MEM = 1294.1M)
Starting SI iteration 2
AAE_INFO: 1 threads acquired from CTE.
Calculate early delays in OCV mode...
Calculate late delays in OCV mode...
Start delay calculation (fullDC) (1 T). (MEM=1236.04)
Glitch Analysis: View functional_typ -- Total Number of Nets Skipped = 0. 
Glitch Analysis: View functional_typ -- Total Number of Nets Analyzed = 543. 
Total number of fetched objects 543
AAE_INFO: Total number of nets for which stage creation was skipped for all views 0
AAE_INFO-618: Total number of nets in the design is 550,  15.3 percent of the nets selected for SI analysis
End delay calculation. (MEM=1242.2 CPU=0:00:00.0 REAL=0:00:00.0)
End delay calculation (fullDC). (MEM=1242.2 CPU=0:00:00.1 REAL=0:00:00.0)

------------------------------------------------------------
          timeDesign Summary                             
------------------------------------------------------------

Setup views included:
 functional_typ 

+--------------------+---------+---------+---------+
|     Setup mode     |   all   | reg2reg | default |
+--------------------+---------+---------+---------+
|           WNS (ns):| -0.093  | -0.093  |  0.350  |
|           TNS (ns):| -0.941  | -0.941  |  0.000  |
|    Violating Paths:|   17    |   17    |    0    |
|          All Paths:|   133   |   94    |   91    |
+--------------------+---------+---------+---------+

+----------------+-------------------------------+------------------+
|                |              Real             |       Total      |
|    DRVs        +------------------+------------+------------------|
|                |  Nr nets(terms)  | Worst Vio  |  Nr nets(terms)  |
+----------------+------------------+------------+------------------+
|   max_cap      |      0 (0)       |   0.000    |      0 (0)       |
|   max_tran     |      0 (0)       |   0.000    |      0 (0)       |
|   max_fanout   |      0 (0)       |     0      |      0 (0)       |
|   max_length   |      0 (0)       |     0      |      0 (0)       |
+----------------+------------------+------------+------------------+

Density: 21.880%
       (100.000% with Fillers)
Total number of glitch violations: 0
------------------------------------------------------------
Reported timing to dir ./timingReports
Total CPU time: 1.13 sec
Total Real time: 2.0 sec
Total Memory Usage: 1204.039062 Mbytes
Reset AAE Options
```

Timing post-routed design with self-designed ram block returns
```
 Reset EOS DB
Ignoring AAE DB Resetting ...
**WARN: (IMPEXT-3518):	The lower process node is set (using command 'setDesignMode') but the technology file for TQuantus extraction not specified. Therefore, going for postRoute (effortLevel low) extraction instead of recommended extractor 'TQuantus' for lower nodes. Use command 'set_analysis_view/update_rc_corner' to specify the technology file for TQuantus extraction to take place.
Extraction called for design 'memtest' of instances=8793 and nets=4319 using extraction engine 'postRoute' at effort level 'low' .
PostRoute (effortLevel low) RC Extraction called for design memtest.
RC Extraction called in multi-corner(1) mode.
**WARN: (IMPEXT-3442):	The version of the capacitance table file being used is obsolete and is no longer recommended. For improved accuracy, generate the capacitance table file using the generateCapTbl command.
Process corner(s) are loaded.
 Corner: tsmc65_rc_corner_typ
extractDetailRC Option : -outfile /tmp/innovus_temp_3361_ee-mill1_ii122_ZatUa5/memtest_3361_USACwr.rcdb.d -maxResLength 200  -extended
RC Mode: PostRoute -effortLevel low [Extended CapTable, RC Table Resistances]
      RC Corner Indexes            0   
Capacitance Scaling Factor   : 1.00000 
Coupling Cap. Scaling Factor : 1.00000 
Resistance Scaling Factor    : 1.00000 
Clock Cap. Scaling Factor    : 1.00000 
Clock Res. Scaling Factor    : 1.00000 
Shrink Factor                : 1.00000
Initializing multi-corner capacitance tables ... 
Initializing multi-corner resistance tables ...
Checking LVS Completed (CPU Time= 0:00:00.0  MEM= 1253.9M)
Extracted 10.0041% (CPU Time= 0:00:00.1  MEM= 1289.9M)
Extracted 20.0045% (CPU Time= 0:00:00.1  MEM= 1289.9M)
Extracted 30.0048% (CPU Time= 0:00:00.1  MEM= 1289.9M)
Extracted 40.0052% (CPU Time= 0:00:00.1  MEM= 1289.9M)
Extracted 50.0056% (CPU Time= 0:00:00.2  MEM= 1289.9M)
Extracted 60.006% (CPU Time= 0:00:00.2  MEM= 1289.9M)
Extracted 70.0063% (CPU Time= 0:00:00.2  MEM= 1289.9M)
Extracted 80.0067% (CPU Time= 0:00:00.2  MEM= 1289.9M)
Extracted 90.0071% (CPU Time= 0:00:00.3  MEM= 1289.9M)
Extracted 100% (CPU Time= 0:00:00.3  MEM= 1289.9M)
Number of Extracted Resistors     : 50231
Number of Extracted Ground Cap.   : 50464
Number of Extracted Coupling Cap. : 73636
Filtering XCap in 'relativeAndCoupling' mode using values coupling_c_threshold=3fF, relative_c_threshold=0.03, and total_c_threshold=5fF.
 Corner: tsmc65_rc_corner_typ
Checking LVS Completed (CPU Time= 0:00:00.0  MEM= 1273.9M)
PostRoute (effortLevel low) RC Extraction DONE (CPU Time: 0:00:00.5  Real Time: 0:00:01.0  MEM: 1281.859M)
Starting SI iteration 1 using Infinite Timing Windows
#################################################################################
# Design Stage: PostRoute
# Design Name: memtest
# Design Mode: 65nm
# Analysis Mode: MMMC OCV 
# Parasitics Mode: SPEF/RCDB
# Signoff Settings: SI On 
#################################################################################
AAE_INFO: 1 threads acquired from CTE.
Calculate early delays in OCV mode...
Calculate late delays in OCV mode...
Start delay calculation (fullDC) (1 T). (MEM=1281.86)
Initializing multi-corner capacitance tables ... 
Initializing multi-corner resistance tables ...
AAE_INFO: 1 threads acquired from CTE.
Total number of fetched objects 3784
AAE_INFO: Total number of nets for which stage creation was skipped for all views 0
AAE_INFO-618: Total number of nets in the design is 4319,  87.5 percent of the nets selected for SI analysis
End delay calculation. (MEM=1336.16 CPU=0:00:00.6 REAL=0:00:00.0)
End delay calculation (fullDC). (MEM=1336.16 CPU=0:00:00.8 REAL=0:00:01.0)
Loading CTE timing window with TwFlowType 0...(CPU = 0:00:00.0, REAL = 0:00:00.0, MEM = 1336.2M)
Add other clocks and setupCteToAAEClockMapping during iter 1
Loading CTE timing window is completed (CPU = 0:00:00.0, REAL = 0:00:00.0, MEM = 1336.2M)
Starting SI iteration 2
AAE_INFO: 1 threads acquired from CTE.
Calculate early delays in OCV mode...
Calculate late delays in OCV mode...
Start delay calculation (fullDC) (1 T). (MEM=1288.05)
Glitch Analysis: View functional_typ -- Total Number of Nets Skipped = 0. 
Glitch Analysis: View functional_typ -- Total Number of Nets Analyzed = 3784. 
Total number of fetched objects 3784
AAE_INFO: Total number of nets for which stage creation was skipped for all views 0
AAE_INFO-618: Total number of nets in the design is 4319,  0.8 percent of the nets selected for SI analysis
End delay calculation. (MEM=1294.2 CPU=0:00:00.0 REAL=0:00:00.0)
End delay calculation (fullDC). (MEM=1294.2 CPU=0:00:00.1 REAL=0:00:00.0)

------------------------------------------------------------
          timeDesign Summary                             
------------------------------------------------------------

Setup views included:
 functional_typ 

+--------------------+---------+---------+---------+
|     Setup mode     |   all   | reg2reg | default |
+--------------------+---------+---------+---------+
|           WNS (ns):|  0.291  |  0.291  |  0.343  |
|           TNS (ns):|  0.000  |  0.000  |  0.000  |
|    Violating Paths:|    0    |    0    |    0    |
|          All Paths:|   683   |   617   |   618   |
+--------------------+---------+---------+---------+

+----------------+-------------------------------+------------------+
|                |              Real             |       Total      |
|    DRVs        +------------------+------------+------------------|
|                |  Nr nets(terms)  | Worst Vio  |  Nr nets(terms)  |
+----------------+------------------+------------+------------------+
|   max_cap      |      0 (0)       |   0.000    |      0 (0)       |
|   max_tran     |      0 (0)       |   0.000    |      0 (0)       |
|   max_fanout   |      0 (0)       |     0      |      0 (0)       |
|   max_length   |      0 (0)       |     0      |      0 (0)       |
+----------------+------------------+------------+------------------+

Density: 51.589%
       (100.000% with Fillers)
Total number of glitch violations: 0
------------------------------------------------------------
Reported timing to dir ./timingReports
Total CPU time: 2.26 sec
Total Real time: 4.0 sec
Total Memory Usage: 1254.046875 Mbytes
Reset AAE Options
```




