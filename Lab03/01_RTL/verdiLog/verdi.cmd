debExit
t "/RAID2/COURSE/dcs/dcs037/Lab03/01_RTL/PATTERN.sv" \
          "/RAID2/COURSE/dcs/dcs037/Lab03/01_RTL/SIPO.sv" \
          "/RAID2/COURSE/dcs/dcs037/Lab03/01_RTL/TESTBED.sv" "-sv" -path \
          {/RAID2/COURSE/dcs/dcs037/Lab03/01_RTL}
nsMsgSelect -range {0 0-0} {0-0}
wvCreateWindow
nsMsgSwitchTab -tab general
debImport "/RAID2/COURSE/dcs/dcs037/Lab03/01_RTL/PATTERN.sv" \
          "/RAID2/COURSE/dcs/dcs037/Lab03/01_RTL/SIPO.sv" \
          "/RAID2/COURSE/dcs/dcs037/Lab03/01_RTL/TESTBED.sv" "-sv" -path \
          {/RAID2/COURSE/dcs/dcs037/Lab03/01_RTL}
wvCreateWindow
wvSetPosition -win $_nWave3 {("G1" 0)}
wvOpenFile -win $_nWave3 {/RAID2/COURSE/dcs/dcs037/Lab03/01_RTL/SIPO.fsdb}
schCreateWindow -delim "." -win $_nSchema1 -scope "TESTBED"
schFit -win $_nSchema4
schSelect -win $_nSchema4 -inst "I_SIPO"
wvAddSignal -win $_nWave3 "/TESTBED/p_out\[3:0\]" "/TESTBED/out_valid" \
           "/TESTBED/s_in" "/TESTBED/in_valid" "/TESTBED/rst_n" "/TESTBED/clk"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 6)}
wvSetPosition -win $_nWave3 {("G1" 6)}
verdiDockWidgetMaximize -dock windowDock_nWave_3
debExit
