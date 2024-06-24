verdiWindowResize -win $_Verdi_1 "8" "31" "853" "679"
debImport "/RAID2/COURSE/dcs/dcs037/Lab01/01_RTL/Comb.sv" \
          "/RAID2/COURSE/dcs/dcs037/Lab01/01_RTL/PATTERN.sv" \
          "/RAID2/COURSE/dcs/dcs037/Lab01/01_RTL/TESTBED.sv" "-sv" -path \
          {/RAID2/COURSE/dcs/dcs037/Lab01/01_RTL}
srcDeselectAll -win $_nTrace1
srcHBSelect "TESTBED.I_Comb" -win $_nTrace1
srcSetScope -win $_nTrace1 "TESTBED.I_Comb" -delim "."
srcHBSelect "TESTBED.I_Comb" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "num_xor" -line 28 -pos 1 -win $_nTrace1
srcTraceDriver "TESTBED.I_Comb.num_xor\[3:0\]" -win $_nTrace1
srcTraceLoad "TESTBED.I_Comb.num_xor\[3:0\]" -win $_nTrace1
nsMsgCollapseItem -tab trace -index {0}
nsMsgCollapseItem -tab trace -index {1}
nsMsgExpandItem -tab trace -index {0}
nsMsgExpandItem -tab trace -index {1}
nsMsgCollapseItem -tab trace -index {0}
