#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Thu Oct 30 13:37:32 2025                
#                                                     
#######################################################

#@(#)CDS: Innovus v18.10-p002_1 (64bit) 05/29/2018 19:19 (Linux 2.6.18-194.el5)
#@(#)CDS: NanoRoute 18.10-p002_1 NR180522-1057/18_10-UB (database version 2.30, 418.7.1) {superthreading v1.46}
#@(#)CDS: AAE 18.10-p004 (64bit) 05/29/2018 (Linux 2.6.18-194.el5)
#@(#)CDS: CTE 18.10-p003_1 () May 15 2018 10:23:07 ( )
#@(#)CDS: SYNTECH 18.10-a012_1 () Apr 19 2018 01:27:21 ( )
#@(#)CDS: CPE v18.10-p005
#@(#)CDS: IQRC/TQRC 18.1.1-s118 (64bit) Fri Mar 23 17:23:45 PDT 2018 (Linux 2.6.18-194.el5)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
win
set init_verilog OUTPUTS/memtest_synth.v
set init_top_cell memtest
set init_lef_file {/usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tcbn65lpbwp7t_141a/lef/tcbn65lpbwp7t_9lmT2.lef /usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tphn65lpnv2od3_sl_200b/mt_2/9lm/lef/tphn65lpnv2od3_sl_9lm.lef /usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tpbn65v_200b/wb/9m/9M_6X2Z/lef/tpbn65v_9lm.lef ./ts1n65lpll32x32m4_220a/LEF/ts1n65lpll32x32m4_220a_5m.lef}
set init_mmmc_file ./mmmc_timing.tcl
set init_gnd_net VSS
set init_pwr_net VDD
setDesignMode -process 65
init_design
set init_verilog OUTPUTS/memtest_synth.v
set init_top_cell memtest
set init_lef_file {  /usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tcbn65lpbwp7t_141a/lef/tcbn65lpbwp7t_9lmT2.lef  /usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tphn65lpnv2od3_sl_200b/mt_2/9lm/lef/tphn65lpnv2od3_sl_9lm.lef  /usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tpbn65v_200b/wb/9m/9M_6X2Z/lef/tpbn65v_9lm.lef  /home/ii122/Lab3/ts1n65lpll32x32m4_220a/LEF/ts1n65lpll32x32m4_220a_5m.lef  }
set init_mmmc_file ./mmmc_timing.tcl
set init_gnd_net VSS
set init_pwr_net VDD
setDesignMode -process 65
init_design
floorPlan -r 0.5 0.6 5 5 5 5
globalNetConnect VSS -type pgpin -pin VSS -all -override
globalNetConnect VDD -type pgpin -pin VDD -all -override
globalNetConnect VDD -type tiehi -pin VDD -all -override
globalNetConnect VSS -type tielo -pin VSS -all -override
addHaloToBlock 5 5 5 5 *
addRing -width 1 -spacing 0.5 -offset 0.5 -layer {top M1 bottom M1 left M2 right M2} -center 1 -nets {VSS VDD}
sroute -nets {VSS VDD} -allowJogging true -allowLayerChange true -blockPin useLef -connect {blockPin padPin padRing corePin floatingStripe}
addWellTap -cell TAPCELLBWP7T -prefix welltap -cellInterval 60 -checkerBoard
timeDesign -prePlace -expandedViews -outDir ./REPORTS/prePlace -prefix prePlace
setPlaceMode -place_global_place_io_pins true
place_opt_design
setTieHiLoMode -maxFanout 10 -maxDistance 50
addTieHiLo -cell {TIEHBWP7T TIELBWP7T}
timeDesign -preCTS -outDir REPORTS/preCTS -prefix preCTS
set_ccopt_property buffer_cells {CKBD0BWP7T CKBD1BWP7T CKBD2BWP7T CKBD3BWP7T CKBD4BWP7T CKBD6BWP7T CKBD8BWP7T CKBD10BWP7T CKBD12BWP7T}
set_ccopt_property inverter_cells {CKND0BWP7T CKND1BWP7T CKND2BWP7T CKND3BWP7T CKND4BWP7T CKND6BWP7T CKND8BWP7T CKND10BWP7T CKND12BWP7T}
set_ccopt_property target_max_trans 130ps
set_ccopt_property target_skew 200ps
set_ccopt_property max_fanout 20
setOptMode -usefulSkew true
setOptMode -usefulSkewCCOpt extreme
create_ccopt_clock_tree_spec -file REPORTS/ctsspec.tcl
get_ccopt_clock_trees
ccopt_check_and_flatten_ilms_no_restore
create_ccopt_clock_tree -name clk -source clk -no_skew_group
set_ccopt_property target_max_trans_sdc -delay_corner corner_typ -early -clock_tree clk 0.050
set_ccopt_property target_max_trans_sdc -delay_corner corner_typ -late -clock_tree clk 0.050
set_ccopt_property clock_period -pin clk 1
create_ccopt_skew_group -name clk/CONSTRAINTS -sources clk -auto_sinks
set_ccopt_property include_source_latency -skew_group clk/CONSTRAINTS true
set_ccopt_property extracted_from_clock_name -skew_group clk/CONSTRAINTS clk
set_ccopt_property extracted_from_constraint_mode_name -skew_group clk/CONSTRAINTS CONSTRAINTS
set_ccopt_property extracted_from_delay_corners -skew_group clk/CONSTRAINTS {corner_typ corner_typ}
check_ccopt_clock_tree_convergence
get_ccopt_property auto_design_state_for_ilms
ccopt_design -check_prerequisites
ccopt_design
optDesign -postCTS -setup -hold -outDir REPORTS/postCTSOptTiming
timeDesign -postCTS -expandedViews -outDir REPORTS/postCTS -prefix postCTS
report_ccopt_clock_trees -file REPORTS/postCTS/clock_trees.rpt
report_ccopt_skew_groups -file REPORTS/postCTS/skew_groups.rpt
routeDesign
setAnalysisMode -analysisType onChipVariation -skew true -clockPropagation sdcControl
optDesign -postRoute -setup
optDesign -postRoute -hold
addFiller -cell {FILL1BWP7T FILL2BWP7T FILL4BWP7T FILL8BWP7T FILL16BWP7T FILL32BWP7T FILL64BWP7T} -doDRC
verifyConnectivity
verify_drc -limit 100000
timeDesign -postRoute -expandedViews -outDir REPORTS/postRoute -prefix postRoute
saveDesign ./SAVES/memtest_done.enc
saveNetlist OUTPUTS/memtest_soc.v
write_sdf OUTPUTS/${DESIGN}.sdf 
write_lef_abstract OUTPUTS/memtest.lef -stripePin
do_extract_model OUTPUTS/${DESIGN}.lib  -view functional_typ
extractRC -outfile memtest.cap
rcOut -spef OUTPUTS/memtest.spef
fit
fit
