#======================================================
#
# Synopsys Synthesis Scripts (Design Vision dctcl mode)
#
#======================================================
#======================================================
#  Set Libraries
#======================================================
set search_path {./../01_RTL \
				 
				 ./ \
				 ~iclabta01/umc018/Synthesis/ \
				 /usr/cad/umc018/Synthesis/ \
				 /usr/synthesis/libraries/syn/ \
				 /usr/synthesis/dw/}
				   
set synthetic_library {dw_foundation.sldb}
set link_library {* dw_foundation.sldb standard.sldb slow.db}
set target_library {slow.db}
#======================================================
# (A) Global Parameters
#======================================================
set DESIGN "CDC"
set SYNCHRONIZER "NDFF_syn"
set CYCLE1 14.1
set CYCLE2 2.5

set INPUT_DLY [expr 0.5*$CYCLE1]
set OUTPUT_DLY [expr 0.5*$CYCLE2]

#======================================================
# (B) Read RTL Code
#======================================================
# (B-1) analyze + elaborate
set hdlin_auto_save_templates TRUE
analyze -f sverilog $SYNCHRONIZER\.v 
elaborate $SYNCHRONIZER  
analyze -f sverilog $DESIGN\.sv 
elaborate $DESIGN  

# (B-2) read_sverilog
#read_sverilog $DESIGN\.v

# (B-3) set current design
current_design $SYNCHRONIZER
link
compile
set_dont_touch $SYNCHRONIZER

current_design $DESIGN
link

#======================================================
#  (C) Global Setting
#======================================================
set_wire_load_mode top
# set_operating_conditions -max WCCOM -min BCCOM
# set_wire_load_model -name umc18_wl10 -library slow

#======================================================
#  (D) Set Design Constraints
#======================================================

# (D-1) Setting Clock Constraints
create_clock -name clk_1 -period $CYCLE1 [get_ports clk_1] 
create_clock -name clk_2 -period $CYCLE2 [get_ports clk_2]

set_dont_touch_network             [all_clocks] 
set_fix_hold                       [all_clocks] 
set_clock_uncertainty       0.1    [all_clocks] 
# set_clock_latency   -source 0      [get_clocks clk]
# set_clock_latency           1      [get_clocks clk] 
set_input_transition        0.5    [all_inputs] 
set_clock_transition        0.1    [all_clocks] 

read_sdc $DESIGN\.sdc

# (D-2) Setting in/out Constraints
set_input_delay   -max  $INPUT_DLY  -clock clk_1   [all_inputs] ;  # set_up time check 
set_input_delay   -min  0           -clock clk_1   [all_inputs] ;  # hold   time check 
set_output_delay  -max  $OUTPUT_DLY -clock clk_2   [all_outputs] ; # set_up time check 
set_output_delay  -min  0           -clock clk_2   [all_outputs] ; # hold   time check 
set_input_delay 0 -clock clk_1 clk_1
set_input_delay 0 -clock clk_2 clk_2

set_input_delay 0 -clock clk_1 rst_n
#set_max_delay $CYCLE -from [all_inputs] -to [all_outputs]

# (D-3) Setting Design Environment
# set_driving_cell -library umc18io3v5v_slow -lib_cell P2C    -pin {Y}  [get_ports clk]
# set_driving_cell -library umc18io3v5v_slow -lib_cell P2C    -pin {Y}  [remove_from_collection [all_inputs] [get_ports clk]]
# set_load  [load_of "umc18io3v5v_slow/P8C/A"]       [all_outputs] ; # ~= 0.038
set_load 0.05 [all_outputs]

# (D-4) Setting DRC Constraint
#set_max_delay           0     ; # Optimize delay max effort                 
#set_max_area            0      ; # Optimize area max effort           
set_max_transition      3       [all_inputs]   ; # U18 LUT Max Transition Value  
set_max_capacitance     0.15    [all_inputs]   ; # U18 LUT Max Capacitance Value
set_max_fanout          10      [all_inputs]
# set_dont_use slow/JKFF*
#set_dont_touch [get_cells core_reg_macro]
#set hdlin_ff_always_sync_set_reset true

# (D-5) Report Clock skew
report_clock -skew clk_1
report_clock -skew clk_2

check_timing

#======================================================
#  (E) Optimization
#======================================================
check_design > Report/$DESIGN\.check
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]
set_fix_hold [all_clocks]
compile_ultra
#uniquify
#compile

#======================================================
#  (F) Output Reports 
#======================================================
report_design  >  Report/$DESIGN\.design
report_resource >  Report/$DESIGN\.resource

# report_timing -max_paths 1000 -path_type end >  Report/$DESIGN\.timing
report_timing -to u_FIFO_syn/u_dual_sram/A0 >  Report/$DESIGN\.timing
report_area -hierarchy >  Report/$DESIGN\.area
report_power > Report/$DESIGN\.power
report_clock > Report/$DESIGN\.clock
report_port >  Report/$DESIGN\.port
report_power >  Report/$DESIGN\.power
#report_reference > Report/$DESIGN\.reference

#======================================================
#  (G) Change Naming Rule
#======================================================
set bus_inference_style "%s\[%d\]"
set bus_naming_style "%s\[%d\]"
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed "a-z A-Z 0-9 _" -max_length 255 -type cell
define_name_rules name_rule -allowed "a-z A-Z 0-9 _[]" -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule


#======================================================
#  (H) Output Results
#======================================================
set verilogout_higher_designs_first true
write -format verilog -output Netlist/$DESIGN\_SYN.v -hierarchy
write -format ddc     -hierarchy -output $DESIGN\_SYN.ddc
write_sdf -version 3.0 -context verilog -load_delay cell Netlist/$DESIGN\_SYN.sdf -significant_digits 6
write_sdc Netlist/$DESIGN\_SYN.sdc

#======================================================
#  (I) Finish and Quit
#======================================================

report_area
report_timing 
exit
