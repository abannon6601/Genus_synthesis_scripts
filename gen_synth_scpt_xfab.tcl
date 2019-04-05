#Set the search paths to the libraries and the HDL files
set_attribute hdl_search_path {./local_test_git/Verilog_SAR/src/DDR3} 
set_attribute lib_search_path {./.xkit/20190318_151159/xc018/diglibs/D_CELLS/liberty_MOSST/PVT_1_80V_range}
set_attribute library [list D_CELLS_MOSST_fast_1_98V_125C.lib]
set_attribute information_level 6 
set_attribute hdl_error_on_blackbox true

#set myFiles [list *.v]  ;# All HDL files

set myFiles [glob -directory ./local_test_git/Verilog_SAR/src/DDR3 *.v]

set basename top   		 ;# name of top level module
set myClk clk                    ;# clock name
set myPeriod_ps 16000             ;# Clock period in ps
set myInDelay_ns 1000            ;# delay from clock to inputs valid
set myOutDelay_ns 10000           ;# delay from clock to output valid
set runname gen_test             ;# name appended to output files



#RUN AND OUTPUT


#Analyze and Elaborate the Design File
read_hdl -sv ${myFiles}
elaborate

# Apply Constraints and generate clocks
set clock [define_clock -period ${myPeriod_ps} -name ${myClk} [clock_ports]]	
external_delay -input $myInDelay_ns -clock ${myClk} [find / -port ports_in/*]
external_delay -output $myOutDelay_ns -clock ${myClk} [find / -port ports_out/*]

# check that the design is OK so far
check_design -unresolved
report timing -lint

# Synthesize the design to the target library
synthesize -to_mapped -effort medium

# Write out the reports
report timing > ${basename}_${runname}_timing.rep
report gates  > ${basename}_${runname}_cell.rep
report power  > ${basename}_${runname}_power.rep

# Write out the structural Verilog and sdc files
write_hdl -mapped >  ${basename}_${runname}.v
write_sdc >  ${basename}_${runname}.sdc

# show result
gui_raise
