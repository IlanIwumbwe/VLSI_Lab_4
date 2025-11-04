####################################################################
##
##          INNOVUS PnR FLOW SCRIPT
## 
####################################################################

####################################################################
## Design Variables Setup
####################################################################

#Top-level module name
set DESIGN memtest
set VERILOG_FILES [list OUTPUTS/memtest_synth.v]
set SDC_FILE OUTPUTS/memtest_synth.sdc
set MEMORY_FOLDER ./ts1n65lpll32x32m4_220a


#Top-level module name
set DESIGN memtest                                  ;# top-level module name
set VERILOG_FILES [list OUTPUTS/memtest_synth.v]    ;# output synthsis task
set SDC_FILE OUTPUTS/memtest_synth.sdc              ;# specify constraints for PnR

# Set Floorplan parameters (unit in um)
set CORE_ASPECT_RATIO 0.4                         ;# square layout
set CORE_UTILIZATION 0.6                          ;# 40% for routing of signal & power
set COREGAP 5                                     ;# gap from power ring to core

# Set Power Ring parameters (in um)
# The power ring is a rectangular area around the core that provides power and ground connections.
set POWER_RING_WIDTH 1                            ;# width of wire
set POWER_RING_SPACING 0.5                         ;# spacing between wires
set POWER_RING_OFFSET 0.5                          ;# distance from core boundary

####################################################################
## Environment Setup
####################################################################

# Setup PnR environment and say where library can be found
set init_verilog ${VERILOG_FILES}
set init_top_cell ${DESIGN}
set init_lef_file [list \
        /usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tcbn65lpbwp7t_141a/lef/tcbn65lpbwp7t_9lmT2.lef \
        /usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tphn65lpnv2od3_sl_200b/mt_2/9lm/lef/tphn65lpnv2od3_sl_9lm.lef \
        /usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tpbn65v_200b/wb/9m/9M_6X2Z/lef/tpbn65v_9lm.lef \
        ${MEMORY_FOLDER}/LEF/ts1n65lpll32x32m4_220a_5m.lef \
    ]                                           ;# use these abstract standard cell for PnR
set init_mmmc_file "./mmmc_timing.tcl"            ;# specify corner conditions the chip operates under (i.e. temperature, voltages etc.)
set init_gnd_net {VSS}
set init_pwr_net {VDD}

setDesignMode -process 65
init_design

#####################################################################
## Floorplan Setup  
#####################################################################

# Plan how the overall layout, particularly where power wires go
floorplan -r ${CORE_ASPECT_RATIO} ${CORE_UTILIZATION} ${COREGAP} ${COREGAP} ${COREGAP} ${COREGAP} 
globalNetConnect VSS -type pgpin -pin VSS -all -override
globalNetConnect VDD -type pgpin -pin VDD -all -override
globalNetConnect VDD -type tiehi -pin VDD -all -override
globalNetConnect VSS -type tielo -pin VSS -all -override


# Place memory macro
placeInstance memtest/mem32x32 8 8 R180

# Add power ring
addRing -width ${POWER_RING_WIDTH} -spacing ${POWER_RING_SPACING} -offset ${POWER_RING_OFFSET} -layer {top M1 bottom M1 left M2 right M2} -center 1 -nets {VSS VDD}

## Add power ring and halo around each macro block if needed
addRing -around each_block -type block_rings -width 0.5 -spacing 0.3 -offset 0.3 -layer {top M1 bottom M1 left M2 right M2} -nets { VSS VDD }
addHaloToBlock -allBlock 5 2 2 2

# Special routing for power and ground nets
sroute -nets {VSS VDD} -allowJogging true -allowLayerChange true -blockPin useLef -connect {blockPin padPin padRing corePin floatingStripe}

# Insert well taps to prevent latch up
addWellTap -cell TAPCELLBWP7T -prefix welltap -cellInterval 60 -checkerBoard

timeDesign -prePlace -expandedViews -outDir ./REPORTS/prePlace -prefix prePlace

####################################################################
## Placement 
####################################################################

# Placement 
setPlaceMode -place_global_place_io_pins true 
place_opt_design 
setTieHiLoMode -maxFanout 10 -maxDistance 50
addTieHiLo -cell "TIEHBWP7T TIELBWP7T" 
timeDesign -preCTS -outDir REPORTS/preCTS -prefix preCTS

####################################################################
## Clock Tree Synthesis 
####################################################################

# specify clock properties
set_ccopt_property buffer_cells {CKBD0BWP7T CKBD1BWP7T CKBD2BWP7T CKBD3BWP7T CKBD4BWP7T CKBD6BWP7T CKBD8BWP7T CKBD10BWP7T CKBD12BWP7T}
set_ccopt_property inverter_cells {CKND0BWP7T CKND1BWP7T CKND2BWP7T CKND3BWP7T CKND4BWP7T CKND6BWP7T CKND8BWP7T CKND10BWP7T CKND12BWP7T}
set_ccopt_property target_max_trans 130ps
set_ccopt_property target_skew 200ps
set_ccopt_property max_fanout 20

setOptMode -usefulSkew true
setOptMode -usefulSkewCCOpt extreme

# clock tree synthesis (CTS)
create_ccopt_clock_tree_spec -file REPORTS/ctsspec.tcl
source REPORTS/ctsspec.tcl
ccopt_design -check_prerequisites
ccopt_design

# post clock tree sythesis optimization
optDesign -postCTS -setup -hold -outDir REPORTS/postCTSOptTiming
timeDesign -postCTS -expandedViews -outDir REPORTS/postCTS -prefix postCTS
report_ccopt_clock_trees -file REPORTS/postCTS/clock_trees.rpt
report_ccopt_skew_groups -file REPORTS/postCTS/skew_groups.rpt

####################################################################
## Routing 
####################################################################

routeDesign                         ;# this does the routing
## Set analysis on on-chip variation (OCV) mode 
setAnalysisMode -analysisType onChipVariation -skew true -clockPropagation sdcControl
optDesign -postRoute -setup
optDesign -postRoute -hold

####################################################################
## Signoff 
####################################################################

addFiller -cell {FILL1BWP7T FILL2BWP7T FILL4BWP7T FILL8BWP7T FILL16BWP7T FILL32BWP7T FILL64BWP7T} -doDRC

verifyConnectivity
verify_drc -limit 100000

timeDesign -postRoute -expandedViews -outDir REPORTS/postRoute -prefix postRoute

## Saving the design
saveDesign ./SAVES/${DESIGN}_done.enc

####################################################################
## Export Design
####################################################################

## Export final netlist to Verilog format
saveNetlist OUTPUTS/[format "%s_layout.v" $DESIGN]

## Export delay information to SDF format
write_sdf OUTPUTS/${DESIGN}.sdf 

## Exporting the design to LEF format
write_lef_abstract OUTPUTS/${DESIGN}.lef -stripePin

# Builds a Liberty (.lib) format model for the top cell, which is the timing model
do_extract_model OUTPUTS/${DESIGN}.lib  -view functional_typ

## Export parasitics to SPEF format
extractRC -outfile ${DESIGN}.cap
rcOut -spef OUTPUTS/${DESIGN}.spef

## Exporting the design to GDSII format
streamOut OUTPUTS/${DESIGN}.gds -structureName ${DESIGN} \
    -mode ALL \
    -attachInstanceName 13 -attachNetName 13 \
    -dieAreaAsBoundary \
    -merge [list "${MEMORY_FOLDER}/GDSII/ts1n65lpll32x32m4_220a.gds"] \
    -mapFile "/usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Back_End/lef/tcbn65lpbwp7t_141a/techfiles/gds2.map"
