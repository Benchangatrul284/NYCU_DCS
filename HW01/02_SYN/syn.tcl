#======================================================
#
# Synopsys Synthesis Scripts (Design Vision dctcl mode)
#
#======================================================

#======================================================
#  Set Libraries
#======================================================

set search_path {  ./../01_RTL \
                   ~iclabta01/umc018/Synthesis/ \
				   /usr/cad/umc018/Synthesis/ \
                   /usr/synthesis/libraries/syn/ \ 
                   /usr/synthesis/dw/ }

set synthetic_library {dw_foundation.sldb}
set link_library {* dw_foundation.sldb standard.sldb slow.db }
set target_library {slow.db}

#======================================================
#  Global Parameters
#======================================================
set DESIGN "CT"
set MAX_Delay 12

#======================================================
#  Read RTL Code
#======================================================
#set hdlin_auto_save_templates TRUE
read_sverilog {CT.sv}
current_design CT

#======================================================
#  Global Setting
#======================================================

#======================================================
#  Set Design Constraints
#======================================================
set_load 0.05 [all_outputs]
set_max_delay $MAX_Delay -from [all_inputs] -to [all_outputs]
set_dont_use slow/JKFF*

#======================================================
#  Optimization
#======================================================
uniquify
set_wire_load_mode top
set_fix_multiple_port_nets -all -buffer_constants
compile_ultra

#======================================================
#  Output Reports 
#======================================================
report_timing >  Report/CT\.timing
report_area >  Report/CT\.area
report_resource >  Report/CT\.resource
check_design > Report/CT\.check

#======================================================
#  Change Naming Rule
#======================================================
set bus_inference_style "%s\[%d\]"
set bus_naming_style "%s\[%d\]"
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed "a-z A-Z 0-9 _" -max_length 255 -type cell
define_name_rules name_rule -allowed "a-z A-Z 0-9 _[]" -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
change_names -hierarchy -rules name_rule

#======================================================
#  Output Results
#======================================================
set verilogout_higher_designs_first true
write -format verilog -output Netlist/CT\_SYN.v -hierarchy
write_sdf -version 3.0 -context verilog -load_delay cell Netlist/CT\_SYN.sdf -significant_digits 6
write_sdc Netlist/CT\_SYN.sdc

#======================================================
#  Finish and Quit
#======================================================
report_area
report_timing
exit
