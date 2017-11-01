set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period 20.000 -name CLKPRGC -waveform {0.000 10.000} [get_ports CLKPRGC]
create_clock -period 8.000 -name CLK125F_P -waveform {0.000 4.000} [get_ports CLK125F_P]
create_clock -period 8.000 -name CLKLOOP_I -waveform {0.000 4.000} [get_ports CLKLOOP_I]
create_clock -period 8.000 -name CLKREFA_P -waveform {0.000 4.000} [get_ports CLKREFA_P]

#**************************************************************
# Overrides - to be fixed on next H/W version...
#**************************************************************
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets eventbuilder_per_inst/evtbuilderfull_inst/sramfifo_inst/sramcntrl_inst/sramclk_inst/CLKIN1]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clkrst_per_inst/sysclkpll_inst/CLK_50MHZ_IBUFG]
#set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets clkrst_per_inst/gclkpll_inst/CLKIN1]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clkrst_per_inst/sysclkpll_inst/CLKIN1]
#**************************************************************
# Create Generated Clock
#**************************************************************

# Rename
create_generated_clock -name SYSCLK_50 [get_pins clkrst_per_inst/sysclkpll_inst/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name SYSCLK_125 [get_pins clkrst_per_inst/sysclkpll_inst/mmcm_adv_inst/CLKOUT1]
create_generated_clock -name GCLK_125 [get_pins clkrst_per_inst/gclkpll_inst/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name GCLK_500 [get_pins clkrst_per_inst/gclkpll_inst/mmcm_adv_inst/CLKOUT1]
create_generated_clock -name GCLK_250 [get_pins clkrst_per_inst/gclkpll_inst/mmcm_adv_inst/CLKOUT2]
create_generated_clock -name USERCLK [get_pins eventbuilder_per_inst/evtbuilderfull_inst/sramfifo_inst/sramcntrl_inst/sramclk_inst/mmcme2_base_inst/CLKOUT0]

#**************************************************************
# False Paths
#**************************************************************

set_false_path -from [get_clocks -of_objects [get_pins clkrst_per_inst/gclkpll_inst/mmcm_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins clkrst_per_inst/sysclkpll_inst/mmcm_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins clkrst_per_inst/sysclkpll_inst/mmcm_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins clkrst_per_inst/gclkpll_inst/mmcm_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins eventbuilder_per_inst/evtbuilderfull_inst/sramfifo_inst/sramcntrl_inst/sramclk_inst/mmcme2_base_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins clkrst_per_inst/sysclkpll_inst/mmcm_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins clkrst_per_inst/sysclkpll_inst/mmcm_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins eventbuilder_per_inst/evtbuilderfull_inst/sramfifo_inst/sramcntrl_inst/sramclk_inst/mmcme2_base_inst/CLKOUT0]]

#**************************************************************
# IO Constraints
#**************************************************************

set_property IOSTANDARD LVCMOS33 [get_ports PMEMD0]
set_property IOSTANDARD LVCMOS33 [get_ports PMEMD1]
set_property IOSTANDARD LVCMOS33 [get_ports PMEMD2]
set_property IOSTANDARD LVCMOS33 [get_ports PMEMD3]
set_property DRIVE 4 [get_ports PMEMD0]
set_property DRIVE 4 [get_ports PMEMD1]
set_property DRIVE 4 [get_ports PMEMD2]
set_property DRIVE 4 [get_ports PMEMD3]
set_property PULLUP true [get_ports PMEMD0]
set_property PULLUP true [get_ports PMEMD1]
set_property PULLUP true [get_ports PMEMD2]
set_property PULLUP true [get_ports PMEMD3]

set_property IOSTANDARD LVCMOS33 [get_ports {FP6OE FP6SEL FP7OE FP7SEL {FPGAOUT[*]} {LEDA[*]} PMEMCE_N TOKENFO TRIGFO SDLINKF STATA_OUT BUSY_OUT PCLKLOAD PCLKOUT1 PCLKOUT2 PCLKSIN1 PCLKSIN2 PCSWCFG}]
set_property DRIVE 4 [get_ports {FP6OE FP6SEL FP7OE FP7SEL {FPGAOUT[*]} {LEDA[*]} PMEMCE_N TOKENFO TRIGFO SDLINKF STATA_OUT BUSY_OUT PCLKLOAD PCLKOUT1 PCLKOUT2 PCLKSIN1 PCLKSIN2 PCSWCFG}]

set_property IOSTANDARD LVCMOS33 [get_ports {{VMERA[*]} {VMERC[*]} {VMERD[*]} {VMERZ[*]} {FPAIN[*]} {FPBIN[*]} {FPCIN[*]} {FPDIN[*]} {FP6ID[*]} {FP7ID[*]} {FPGAIN[*]} TOKENFI SYNCFI TRIG1F TRIG2F STATA_IN STATB_IN CLKPRGC {SWA[*]} SWM1 CLKSELX1 CLKSELX2}]
set_property PULLUP true [get_ports {VMERA[28]}]
set_property PULLUP true [get_ports {VMERA[27]}]
set_property PULLUP true [get_ports {VMERA[26]}]
set_property PULLUP true [get_ports {VMERA[25]}]
set_property PULLUP true [get_ports {VMERA[24]}]
set_property PULLUP true [get_ports {VMERA[23]}]
set_property PULLUP true [get_ports {VMERA[22]}]
set_property PULLUP true [get_ports {VMERA[21]}]
set_property PULLUP true [get_ports {VMERA[20]}]
set_property PULLUP true [get_ports {VMERA[19]}]
set_property PULLUP true [get_ports {VMERA[18]}]
set_property PULLUP true [get_ports {VMERA[17]}]
set_property PULLUP true [get_ports {VMERA[16]}]
set_property PULLUP true [get_ports {VMERA[15]}]
set_property PULLUP true [get_ports {VMERA[14]}]
set_property PULLUP true [get_ports {VMERA[13]}]
set_property PULLUP true [get_ports {VMERA[12]}]
set_property PULLUP true [get_ports {VMERA[11]}]
set_property PULLUP true [get_ports {VMERA[10]}]
set_property PULLUP true [get_ports {VMERA[9]}]
set_property PULLUP true [get_ports {VMERA[8]}]
set_property PULLUP true [get_ports {VMERA[7]}]
set_property PULLUP true [get_ports {VMERA[6]}]
set_property PULLUP true [get_ports {VMERA[5]}]
set_property PULLUP true [get_ports {VMERA[4]}]
set_property PULLUP true [get_ports {VMERA[3]}]
set_property PULLUP true [get_ports {VMERA[2]}]
set_property PULLUP true [get_ports {VMERA[1]}]
set_property PULLUP true [get_ports {VMERC[28]}]
set_property PULLUP true [get_ports {VMERC[27]}]
set_property PULLUP true [get_ports {VMERC[26]}]
set_property PULLUP true [get_ports {VMERC[25]}]
set_property PULLUP true [get_ports {VMERC[24]}]
set_property PULLUP true [get_ports {VMERC[23]}]
set_property PULLUP true [get_ports {VMERC[22]}]
set_property PULLUP true [get_ports {VMERC[21]}]
set_property PULLUP true [get_ports {VMERC[20]}]
set_property PULLUP true [get_ports {VMERC[19]}]
set_property PULLUP true [get_ports {VMERC[18]}]
set_property PULLUP true [get_ports {VMERC[17]}]
set_property PULLUP true [get_ports {VMERC[16]}]
set_property PULLUP true [get_ports {VMERC[15]}]
set_property PULLUP true [get_ports {VMERC[14]}]
set_property PULLUP true [get_ports {VMERC[13]}]
set_property PULLUP true [get_ports {VMERC[12]}]
set_property PULLUP true [get_ports {VMERC[11]}]
set_property PULLUP true [get_ports {VMERC[10]}]
set_property PULLUP true [get_ports {VMERC[9]}]
set_property PULLUP true [get_ports {VMERC[8]}]
set_property PULLUP true [get_ports {VMERC[7]}]
set_property PULLUP true [get_ports {VMERC[6]}]
set_property PULLUP true [get_ports {VMERC[5]}]
set_property PULLUP true [get_ports {VMERC[4]}]
set_property PULLUP true [get_ports {VMERC[3]}]
set_property PULLUP true [get_ports {VMERC[2]}]
set_property PULLUP true [get_ports {VMERC[1]}]
set_property PULLUP true [get_ports {VMERD[8]}]
set_property PULLUP true [get_ports {VMERD[7]}]
set_property PULLUP true [get_ports {VMERD[6]}]
set_property PULLUP true [get_ports {VMERD[5]}]
set_property PULLUP true [get_ports {VMERD[4]}]
set_property PULLUP true [get_ports {VMERD[3]}]
set_property PULLUP true [get_ports {VMERD[2]}]
set_property PULLUP true [get_ports {VMERD[1]}]
set_property PULLUP true [get_ports {VMERZ[16]}]
set_property PULLUP true [get_ports {VMERZ[15]}]
set_property PULLUP true [get_ports {VMERZ[14]}]
set_property PULLUP true [get_ports {VMERZ[13]}]
set_property PULLUP true [get_ports {VMERZ[12]}]
set_property PULLUP true [get_ports {VMERZ[11]}]
set_property PULLUP true [get_ports {VMERZ[10]}]
set_property PULLUP true [get_ports {VMERZ[9]}]
set_property PULLUP true [get_ports {VMERZ[8]}]
set_property PULLUP true [get_ports {VMERZ[7]}]
set_property PULLUP true [get_ports {VMERZ[6]}]
set_property PULLUP true [get_ports {VMERZ[5]}]
set_property PULLUP true [get_ports {VMERZ[4]}]
set_property PULLUP true [get_ports {VMERZ[3]}]
set_property PULLUP true [get_ports {VMERZ[2]}]
set_property PULLUP true [get_ports {VMERZ[1]}]
set_property PULLUP true [get_ports {FPBIN[32]}]
set_property PULLUP true [get_ports {FPBIN[31]}]
set_property PULLUP true [get_ports {FPBIN[30]}]
set_property PULLUP true [get_ports {FPBIN[29]}]
set_property PULLUP true [get_ports {FPBIN[28]}]
set_property PULLUP true [get_ports {FPBIN[27]}]
set_property PULLUP true [get_ports {FPBIN[26]}]
set_property PULLUP true [get_ports {FPBIN[25]}]
set_property PULLUP true [get_ports {FPBIN[24]}]
set_property PULLUP true [get_ports {FPBIN[23]}]
set_property PULLUP true [get_ports {FPBIN[22]}]
set_property PULLUP true [get_ports {FPBIN[21]}]
set_property PULLUP true [get_ports {FPBIN[20]}]
set_property PULLUP true [get_ports {FPBIN[19]}]
set_property PULLUP true [get_ports {FPBIN[18]}]
set_property PULLUP true [get_ports {FPBIN[17]}]
set_property PULLUP true [get_ports {FPBIN[16]}]
set_property PULLUP true [get_ports {FPBIN[15]}]
set_property PULLUP true [get_ports {FPBIN[14]}]
set_property PULLUP true [get_ports {FPBIN[13]}]
set_property PULLUP true [get_ports {FPBIN[12]}]
set_property PULLUP true [get_ports {FPBIN[11]}]
set_property PULLUP true [get_ports {FPBIN[10]}]
set_property PULLUP true [get_ports {FPBIN[9]}]
set_property PULLUP true [get_ports {FPBIN[8]}]
set_property PULLUP true [get_ports {FPBIN[7]}]
set_property PULLUP true [get_ports {FPBIN[6]}]
set_property PULLUP true [get_ports {FPBIN[5]}]
set_property PULLUP true [get_ports {FPBIN[4]}]
set_property PULLUP true [get_ports {FPBIN[3]}]
set_property PULLUP true [get_ports {FPBIN[2]}]
set_property PULLUP true [get_ports {FPBIN[1]}]
set_property PULLUP true [get_ports {FPDIN[32]}]
set_property PULLUP true [get_ports {FPDIN[31]}]
set_property PULLUP true [get_ports {FPDIN[30]}]
set_property PULLUP true [get_ports {FPDIN[29]}]
set_property PULLUP true [get_ports {FPDIN[28]}]
set_property PULLUP true [get_ports {FPDIN[27]}]
set_property PULLUP true [get_ports {FPDIN[26]}]
set_property PULLUP true [get_ports {FPDIN[25]}]
set_property PULLUP true [get_ports {FPDIN[24]}]
set_property PULLUP true [get_ports {FPDIN[23]}]
set_property PULLUP true [get_ports {FPDIN[22]}]
set_property PULLUP true [get_ports {FPDIN[21]}]
set_property PULLUP true [get_ports {FPDIN[20]}]
set_property PULLUP true [get_ports {FPDIN[19]}]
set_property PULLUP true [get_ports {FPDIN[18]}]
set_property PULLUP true [get_ports {FPDIN[17]}]
set_property PULLUP true [get_ports {FPDIN[16]}]
set_property PULLUP true [get_ports {FPDIN[15]}]
set_property PULLUP true [get_ports {FPDIN[14]}]
set_property PULLUP true [get_ports {FPDIN[13]}]
set_property PULLUP true [get_ports {FPDIN[12]}]
set_property PULLUP true [get_ports {FPDIN[11]}]
set_property PULLUP true [get_ports {FPDIN[10]}]
set_property PULLUP true [get_ports {FPDIN[9]}]
set_property PULLUP true [get_ports {FPDIN[8]}]
set_property PULLUP true [get_ports {FPDIN[7]}]
set_property PULLUP true [get_ports {FPDIN[6]}]
set_property PULLUP true [get_ports {FPDIN[5]}]
set_property PULLUP true [get_ports {FPDIN[4]}]
set_property PULLUP true [get_ports {FPDIN[3]}]
set_property PULLUP true [get_ports {FPDIN[2]}]
set_property PULLUP true [get_ports {FPDIN[1]}]
set_property PULLUP true [get_ports {FP6ID[2]}]
set_property PULLUP true [get_ports {FP6ID[1]}]
set_property PULLUP true [get_ports {FP6ID[0]}]
set_property PULLUP true [get_ports {FP7ID[2]}]
set_property PULLUP true [get_ports {FP7ID[1]}]
set_property PULLUP true [get_ports {FP7ID[0]}]

set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[19]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[18]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[17]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[16]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[15]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[14]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMA[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports MEMCE2]
set_property IOSTANDARD LVCMOS25 [get_ports MEMCLK]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[17]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[16]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[15]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[14]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {MEMD[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports MEMLDB]
set_property IOSTANDARD LVCMOS25 [get_ports MEMRWB]
set_property IOSTANDARD LVCMOS25 [get_ports CLKLOOP_O]
set_property IOSTANDARD LVCMOS25 [get_ports CLKLOOP_I]
set_property DRIVE 8 [get_ports {MEMA[19]}]
set_property DRIVE 8 [get_ports {MEMA[18]}]
set_property DRIVE 8 [get_ports {MEMA[17]}]
set_property DRIVE 8 [get_ports {MEMA[16]}]
set_property DRIVE 8 [get_ports {MEMA[15]}]
set_property DRIVE 8 [get_ports {MEMA[14]}]
set_property DRIVE 8 [get_ports {MEMA[13]}]
set_property DRIVE 8 [get_ports {MEMA[12]}]
set_property DRIVE 8 [get_ports {MEMA[11]}]
set_property DRIVE 8 [get_ports {MEMA[10]}]
set_property DRIVE 8 [get_ports {MEMA[9]}]
set_property DRIVE 8 [get_ports {MEMA[8]}]
set_property DRIVE 8 [get_ports {MEMA[7]}]
set_property DRIVE 8 [get_ports {MEMA[6]}]
set_property DRIVE 8 [get_ports {MEMA[5]}]
set_property DRIVE 8 [get_ports {MEMA[4]}]
set_property DRIVE 8 [get_ports {MEMA[3]}]
set_property DRIVE 8 [get_ports {MEMA[2]}]
set_property DRIVE 8 [get_ports {MEMA[1]}]
set_property DRIVE 8 [get_ports {MEMA[0]}]
set_property DRIVE 8 [get_ports MEMCE2]
set_property DRIVE 8 [get_ports MEMCLK]
set_property DRIVE 8 [get_ports {MEMD[17]}]
set_property DRIVE 8 [get_ports {MEMD[16]}]
set_property DRIVE 8 [get_ports {MEMD[15]}]
set_property DRIVE 8 [get_ports {MEMD[14]}]
set_property DRIVE 8 [get_ports {MEMD[13]}]
set_property DRIVE 8 [get_ports {MEMD[12]}]
set_property DRIVE 8 [get_ports {MEMD[11]}]
set_property DRIVE 8 [get_ports {MEMD[10]}]
set_property DRIVE 8 [get_ports {MEMD[9]}]
set_property DRIVE 8 [get_ports {MEMD[8]}]
set_property DRIVE 8 [get_ports {MEMD[7]}]
set_property DRIVE 8 [get_ports {MEMD[6]}]
set_property DRIVE 8 [get_ports {MEMD[5]}]
set_property DRIVE 8 [get_ports {MEMD[4]}]
set_property DRIVE 8 [get_ports {MEMD[3]}]
set_property DRIVE 8 [get_ports {MEMD[2]}]
set_property DRIVE 8 [get_ports {MEMD[1]}]
set_property DRIVE 8 [get_ports {MEMD[0]}]
set_property DRIVE 8 [get_ports MEMLDB]
set_property DRIVE 8 [get_ports MEMRWB]
set_property DRIVE 8 [get_ports CLKLOOP_O]
set_property PULLUP true [get_ports {MEMD[17]}]
set_property PULLUP true [get_ports {MEMD[16]}]
set_property PULLUP true [get_ports {MEMD[15]}]
set_property PULLUP true [get_ports {MEMD[14]}]
set_property PULLUP true [get_ports {MEMD[13]}]
set_property PULLUP true [get_ports {MEMD[12]}]
set_property PULLUP true [get_ports {MEMD[11]}]
set_property PULLUP true [get_ports {MEMD[10]}]
set_property PULLUP true [get_ports {MEMD[9]}]
set_property PULLUP true [get_ports {MEMD[8]}]
set_property PULLUP true [get_ports {MEMD[7]}]
set_property PULLUP true [get_ports {MEMD[6]}]
set_property PULLUP true [get_ports {MEMD[5]}]
set_property PULLUP true [get_ports {MEMD[4]}]
set_property PULLUP true [get_ports {MEMD[3]}]
set_property PULLUP true [get_ports {MEMD[2]}]
set_property PULLUP true [get_ports {MEMD[1]}]
set_property PULLUP true [get_ports {MEMD[0]}]

set_property IOSTANDARD LVDS_25 [get_ports CLK125F_P]
set_property IOSTANDARD LVDS_25 [get_ports CLK125F_N]

set_property IOSTANDARD LVCMOS33 [get_ports {{A[*]} {D[*]}}]
set_property DRIVE 4 [get_ports {{A[*]} {D[*]}}]
set_property PULLUP true [get_ports {A[31]}]
set_property PULLUP true [get_ports {A[30]}]
set_property PULLUP true [get_ports {A[29]}]
set_property PULLUP true [get_ports {A[28]}]
set_property PULLUP true [get_ports {A[27]}]
set_property PULLUP true [get_ports {A[26]}]
set_property PULLUP true [get_ports {A[25]}]
set_property PULLUP true [get_ports {A[24]}]
set_property PULLUP true [get_ports {A[23]}]
set_property PULLUP true [get_ports {A[22]}]
set_property PULLUP true [get_ports {A[21]}]
set_property PULLUP true [get_ports {A[20]}]
set_property PULLUP true [get_ports {A[19]}]
set_property PULLUP true [get_ports {A[18]}]
set_property PULLUP true [get_ports {A[17]}]
set_property PULLUP true [get_ports {A[16]}]
set_property PULLUP true [get_ports {A[15]}]
set_property PULLUP true [get_ports {A[14]}]
set_property PULLUP true [get_ports {A[13]}]
set_property PULLUP true [get_ports {A[12]}]
set_property PULLUP true [get_ports {A[11]}]
set_property PULLUP true [get_ports {A[10]}]
set_property PULLUP true [get_ports {A[9]}]
set_property PULLUP true [get_ports {A[8]}]
set_property PULLUP true [get_ports {A[7]}]
set_property PULLUP true [get_ports {A[6]}]
set_property PULLUP true [get_ports {A[5]}]
set_property PULLUP true [get_ports {A[4]}]
set_property PULLUP true [get_ports {A[3]}]
set_property PULLUP true [get_ports {A[2]}]
set_property PULLUP true [get_ports {A[1]}]
set_property PULLUP true [get_ports {A[0]}]
set_property PULLUP true [get_ports {D[31]}]
set_property PULLUP true [get_ports {D[30]}]
set_property PULLUP true [get_ports {D[29]}]
set_property PULLUP true [get_ports {D[28]}]
set_property PULLUP true [get_ports {D[27]}]
set_property PULLUP true [get_ports {D[26]}]
set_property PULLUP true [get_ports {D[25]}]
set_property PULLUP true [get_ports {D[24]}]
set_property PULLUP true [get_ports {D[23]}]
set_property PULLUP true [get_ports {D[22]}]
set_property PULLUP true [get_ports {D[21]}]
set_property PULLUP true [get_ports {D[20]}]
set_property PULLUP true [get_ports {D[19]}]
set_property PULLUP true [get_ports {D[18]}]
set_property PULLUP true [get_ports {D[17]}]
set_property PULLUP true [get_ports {D[16]}]
set_property PULLUP true [get_ports {D[15]}]
set_property PULLUP true [get_ports {D[14]}]
set_property PULLUP true [get_ports {D[13]}]
set_property PULLUP true [get_ports {D[12]}]
set_property PULLUP true [get_ports {D[11]}]
set_property PULLUP true [get_ports {D[10]}]
set_property PULLUP true [get_ports {D[9]}]
set_property PULLUP true [get_ports {D[8]}]
set_property PULLUP true [get_ports {D[7]}]
set_property PULLUP true [get_ports {D[6]}]
set_property PULLUP true [get_ports {D[5]}]
set_property PULLUP true [get_ports {D[4]}]
set_property PULLUP true [get_ports {D[3]}]
set_property PULLUP true [get_ports {D[2]}]
set_property PULLUP true [get_ports {D[1]}]
set_property PULLUP true [get_ports {D[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {A_CLKAB A_CLKBA A_DIR A_LE A_OE_N D_CLKAB D_CLKBA D_DIR D_LE D_OE_N SYSRST_EN SYSFAIL_EN BUSY_EN BUSRQ_EN RETRY_OE WRITE_EN AS_EN BERR_EN BG3OUT_EN DS0_EN DS1_EN DTACK_EN DTACK_FPGA IACK_EN IACK_O_EN {IRQ_N[*]} IRQOE_N}]
set_property DRIVE 4 [get_ports {A_CLKAB A_CLKBA A_DIR A_LE A_OE_N D_CLKAB D_CLKBA D_DIR D_LE D_OE_N SYSRST_EN SYSFAIL_EN BUSY_EN BUSRQ_EN RETRY_OE WRITE_EN AS_EN BERR_EN BG3OUT_EN DS0_EN DS1_EN DTACK_EN DTACK_FPGA IACK_EN IACK_O_EN {IRQ_N[*]} IRQOE_N}]

set_property IOSTANDARD LVCMOS33 [get_ports {{AM[*]} SYSRESET_N SYSFAIL_N BUSY_N RETRY_N WRITE_N AS_N BERR_N BG3IN_N DS0_N DS1_N DTACK_N {GA_N[*]} GAP_N IACK_I_N IACK_N}]

set_property PACKAGE_PIN AB5 [get_ports {MEMA[0]}]
set_property PACKAGE_PIN AC3 [get_ports {MEMA[1]}]
set_property PACKAGE_PIN AC4 [get_ports {MEMA[2]}]
set_property PACKAGE_PIN Y7 [get_ports {MEMA[3]}]
set_property PACKAGE_PIN AB7 [get_ports {MEMA[4]}]
set_property PACKAGE_PIN AA7 [get_ports {MEMA[5]}]
set_property PACKAGE_PIN AA10 [get_ports {MEMA[6]}]
set_property PACKAGE_PIN Y10 [get_ports {MEMA[7]}]
set_property PACKAGE_PIN V8 [get_ports {MEMA[8]}]
set_property PACKAGE_PIN V9 [get_ports {MEMA[9]}]
set_property PACKAGE_PIN V4 [get_ports {MEMA[10]}]
set_property PACKAGE_PIN AC2 [get_ports {MEMA[11]}]
set_property PACKAGE_PIN AC1 [get_ports {MEMA[12]}]
set_property PACKAGE_PIN AB2 [get_ports {MEMA[13]}]
set_property PACKAGE_PIN AB1 [get_ports {MEMA[14]}]
set_property PACKAGE_PIN Y2 [get_ports {MEMA[15]}]
set_property PACKAGE_PIN Y1 [get_ports {MEMA[16]}]
set_property PACKAGE_PIN W1 [get_ports {MEMA[17]}]
set_property PACKAGE_PIN W10 [get_ports {MEMA[18]}]
set_property PACKAGE_PIN V7 [get_ports {MEMA[19]}]
set_property PACKAGE_PIN AC6 [get_ports MEMCE2]
set_property PACKAGE_PIN AA8 [get_ports MEMCLK]
set_property PACKAGE_PIN W9 [get_ports MEMLDB]
set_property PACKAGE_PIN Y8 [get_ports MEMRWB]




set_property PACKAGE_PIN AA5 [get_ports CLK125F_P]
set_property PACKAGE_PIN Y6 [get_ports CLKLOOP_O]
set_property PACKAGE_PIN W5 [get_ports CLKLOOP_I]
set_property PACKAGE_PIN AP31 [get_ports {FIBERICK}]
set_property PACKAGE_PIN AN28 [get_ports {FIBERICKB}]
set_property PACKAGE_PIN AP30 [get_ports {FIBERIDATA}]
set_property PACKAGE_PIN AN29 [get_ports {FIBERIDATAB}]
set_property PACKAGE_PIN AM29 [get_ports {FIBERRST}]
set_property PACKAGE_PIN AH24 [get_ports {FIBERRSTB}]

set_property PACKAGE_PIN AP25 [get_ports {MODINTA}]
set_property PACKAGE_PIN AN26 [get_ports {MODINTB}]
set_property PACKAGE_PIN AP26 [get_ports {MODPRSTA}]
set_property PACKAGE_PIN AN27 [get_ports {MODPRSTB}]
set_property PACKAGE_PIN Y27 [get_ports PMEMCE_N]
set_property PACKAGE_PIN V26 [get_ports PMEMD2]
set_property PACKAGE_PIN V27 [get_ports PMEMD3]
set_property PACKAGE_PIN AC8 [get_ports {SYNCODEI_N}]
set_property PACKAGE_PIN AC9 [get_ports {SYNCODEI_P}]
set_property PACKAGE_PIN AB9 [get_ports {SYNCODEO_N}]
set_property PACKAGE_PIN AB10 [get_ports {SYNCODEO_P}]
set_property PACKAGE_PIN AL29 [get_ports {TIAMSEL}]
set_property PACKAGE_PIN AF23 [get_ports {TIBMSEL}]

