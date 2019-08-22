#written by Alan Bannon
#based off of work by Erik Brunvand and many other users on edaboard forums

#set <items> to your project settings and files 

#Set the search paths to the libraries and the HDL files
set_attribute hdl_search_path {<path to hdl files>} 
set_attribute lib_search_path {<path to lib files>}
set_attribute lib_search_path {<path to lib files>}
set_attribute library [list <lib files>]
set_attribute information_level 6 

#optional. Comment this line if you accept blacboxes
set_attribute hdl_error_on_blackbox true 


#Uncomment one of the next lines for specific files, or all files in a directory
#set myFiles [list <hdl files>]; # 
#set myFiles [glob -directory <path to hdl files> *.v];

set basename <name of top level module>;
set myClk clk <clock name>;
set myPeriod_ps <clock period (ps)>;
set myInDelay_ns <delay from clock to inputs valid (ps)>;
set myOutDelay_ns <delay from clock to output valid (ps)>;
set runname <name appended to output files>;



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
