#**************************************************************
# Create Clock
#**************************************************************
create_clock -period 30.000 -name CLKPRGC -waveform {0.000 16.667} [get_ports CLKPRGC]
create_clock -period 8.000 -name CLK125F_P -waveform {0.000 4.000} [get_ports CLK125F_P]
create_clock -period 8.000 -name CLKLOOP_I -waveform {0.000 4.000} [get_ports CLKLOOP_I]

#**************************************************************
# Create Generated Clock
#**************************************************************

# Rename
create_generated_clock -name SYSCLK_50    [get_pins clkrst_per_inst/sysclkpll_inst/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name SYSCLK_125   [get_pins clkrst_per_inst/sysclkpll_inst/mmcm_adv_inst/CLKOUT1]
create_generated_clock -name GCLK_125     [get_pins clkrst_per_inst/gclkpll_inst/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name GCLK_500     [get_pins clkrst_per_inst/gclkpll_inst/mmcm_adv_inst/CLKOUT1]
create_generated_clock -name GCLK_250     [get_pins clkrst_per_inst/gclkpll_inst/mmcm_adv_inst/CLKOUT2]
create_generated_clock -name USERCLK [get_pins eventbuilder_per_inst/evtbuilderfull_inst/sramfifo_inst/sramcntrl_inst/sramclk_inst/mmcme2_base_inst/CLKOUT0]

#**************************************************************
# False Paths
#**************************************************************

#**************************************************************
# IO Constraints
#**************************************************************
