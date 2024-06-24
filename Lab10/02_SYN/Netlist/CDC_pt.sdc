###################################################################

# Created by write_sdc on Tue Apr  2 13:34:51 2024

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_wire_load_mode top
set_load -pin_load 0.05 [get_ports out_valid]
set_load -pin_load 0.05 [get_ports {out_data[4]}]
set_load -pin_load 0.05 [get_ports {out_data[3]}]
set_load -pin_load 0.05 [get_ports {out_data[2]}]
set_load -pin_load 0.05 [get_ports {out_data[1]}]
set_load -pin_load 0.05 [get_ports {out_data[0]}]
create_clock [get_ports clk_1]  -period 14.1  -waveform {0 7.05}
create_clock [get_ports clk_2]  -period 2.5  -waveform {0 1.25}
set_false_path   -from [get_clocks clk_1]  -to [get_clocks clk_2]
set_false_path   -from [get_clocks clk_2]  -to [get_clocks clk_1]
set_input_delay -clock clk_1  0  [get_ports clk_1]
set_input_delay -clock clk_2  0  [get_ports clk_2]
set_input_delay -clock clk_1  0  [get_ports rst_n]
set_input_delay -clock clk_1  7.05  [get_ports in_valid]
set_input_delay -clock clk_1  7.05  [get_ports {in_data[7]}]
set_input_delay -clock clk_1  7.05  [get_ports {in_data[6]}]
set_input_delay -clock clk_1  7.05  [get_ports {in_data[5]}]
set_input_delay -clock clk_1  7.05  [get_ports {in_data[4]}]
set_input_delay -clock clk_1  7.05  [get_ports {in_data[3]}]
set_input_delay -clock clk_1  7.05  [get_ports {in_data[2]}]
set_input_delay -clock clk_1  7.05  [get_ports {in_data[1]}]
set_input_delay -clock clk_1  7.05  [get_ports {in_data[0]}]
set_output_delay -clock clk_2  1.25  [get_ports out_valid]
set_output_delay -clock clk_2  1.25  [get_ports {out_data[4]}]
set_output_delay -clock clk_2  1.25  [get_ports {out_data[3]}]
set_output_delay -clock clk_2  1.25  [get_ports {out_data[2]}]
set_output_delay -clock clk_2  1.25  [get_ports {out_data[1]}]
set_output_delay -clock clk_2  1.25  [get_ports {out_data[0]}]
