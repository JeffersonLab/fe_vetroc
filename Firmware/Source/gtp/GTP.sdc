## Generated SDC file "GTP.sdc"

## Copyright (C) 1991-2011 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 11.1 Build 216 11/23/2011 Service Pack 1 SJ Full Version"

## DATE    "Wed Jun 13 09:36:43 2012"

##
## DEVICE  "EP4SGX180KF40C3"
##

#**************************************************************
# Clock name alias
#**************************************************************

set clk_GXBPMADIRECT_DESERCLOCK	"*\gen_pma_direct:gxb_transceiver_pcs_inst|gxb_transceiver_pma_inst|gxb_transceiver_pma_alt4gxb_component|receive_pma*|deserclock[*]"
set clk_GCLK							"gtpclkrst_per_inst|pll250b|altpll_component|auto_generated|pll1|clk[0]"
set clk_SDRAM_AFIHALF				"nios_wrapper_inst|sopc_system_inst|sdram_0|pll0|upll_memphy|auto_generated|pll1|clk[4]"
set clk_SYSCLK_250					"gtpclkrst_per_inst|sysclkpll_inst|altpll_component|auto_generated|pll1|clk[0]"
set clk_SYSCLK_50						"gtpclkrst_per_inst|sysclkpll_inst|altpll_component|auto_generated|pll1|clk[1]"
set clk_TIGTP_100_N18				"tigtp_per_inst|tigtp_ser_wrapper_inst|tigtp_ser_inst|tigtp_ser_rx_inst|*:altlvds_rx_inst|auto_generated|pll|clk[2]"

#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3

#**************************************************************
# Create Clock
#**************************************************************
create_clock -name {CLK25_B}		-period 40.000 -waveform {0.000 20.000} { CLK25_B }
create_clock -name {CLK25_R}		-period 40.000 -waveform {0.000 20.000} { CLK25_R }
create_clock -name {CLK250_B}		-period 4.000 -waveform {0.000 4.000} { CLK250_B }
create_clock -name {CLK250_L}		-period 8.000 -waveform {0.000 4.000} { CLK250_L }
create_clock -name {CLK250_R}		-period 8.000 -waveform {0.000 4.000} { CLK250_R }
create_clock -name {CLK250_T}		-period 4.000 -waveform {0.000 2.000} { CLK250_T }
create_clock -name {RGMII_RXC}	-period 8.000 -waveform {0.000 4.000} [get_ports {RGMII_RXC}]
create_clock -name {v_RGMII_RXC}	-period 8.000 -waveform {0.000 4.000}
create_clock -name ETH_CLK			-period 8.000 [get_nets {nios_wrapper:nios_wrapper_inst|ETH_CLK}]

derive_pll_clocks	 -create_base_clocks

#**************************************************************
# Create Generated Clock
#**************************************************************

#**************************************************************
# Set Clock Latency
#**************************************************************

#**************************************************************
# Set Clock Uncertainty
#**************************************************************      

derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay 0.000 -max -clock [get_clocks {v_RGMII_RXC}] -add_delay [get_ports "RGMII_RXD[*] RGMII_RX_CTL"]
set_input_delay 0.000 -min -clock [get_clocks {v_RGMII_RXC}] -add_delay [get_ports "RGMII_RXD[*] RGMII_RX_CTL"]
set_input_delay 0.000 -max -clock [get_clocks {v_RGMII_RXC}] -clock_fall -add_delay [get_ports "RGMII_RXD[*] RGMII_RX_CTL"]
set_input_delay 0.000 -min -clock [get_clocks {v_RGMII_RXC}] -clock_fall -add_delay [get_ports "RGMII_RXD[*] RGMII_RX_CTL"]

#**************************************************************
# Set Output Delay
#**************************************************************

#set_output_delay -max 0.000 -clock [get_clocks {g_RGMII_TXC_0}]					[get_ports "RGMII_TXD[*] RGMII_TX_CTL"]
#set_output_delay -max 0.000 -clock [get_clocks {g_RGMII_TXC_0}] -clock_fall	[get_ports "RGMII_TXD[*] RGMII_TX_CTL"] -add_delay
#set_output_delay -min 0.000 -clock [get_clocks {g_RGMII_TXC_0}]					[get_ports "RGMII_TXD[*] RGMII_TX_CTL"] -add_delay
#set_output_delay -min 0.000 -clock [get_clocks {g_RGMII_TXC_0}] -clock_fall	[get_ports "RGMII_TXD[*] RGMII_TX_CTL"] -add_delay

#set_output_delay -max 0.000 -clock [get_clocks {g_RGMII_TXC_1}]					[get_ports "RGMII_TXD[*] RGMII_TX_CTL"] -add_delay
#set_output_delay -max 0.000 -clock [get_clocks {g_RGMII_TXC_1}] -clock_fall	[get_ports "RGMII_TXD[*] RGMII_TX_CTL"] -add_delay
#set_output_delay -min 0.000 -clock [get_clocks {g_RGMII_TXC_1}]					[get_ports "RGMII_TXD[*] RGMII_TX_CTL"] -add_delay
#set_output_delay -min 0.000 -clock [get_clocks {g_RGMII_TXC_1}] -clock_fall	[get_ports "RGMII_TXD[*] RGMII_TX_CTL"] -add_delay

#set_output_delay -max 0.000 -clock [get_clocks {g_RGMII_TXC_2}]					[get_ports "RGMII_TXD[*] RGMII_TX_CTL"] -add_delay
#set_output_delay -max 0.000 -clock [get_clocks {g_RGMII_TXC_2}] -clock_fall	[get_ports "RGMII_TXD[*] RGMII_TX_CTL"] -add_delay
#set_output_delay -min 0.000 -clock [get_clocks {g_RGMII_TXC_2}]					[get_ports "RGMII_TXD[*] RGMII_TX_CTL"] -add_delay
#set_output_delay -min 0.000 -clock [get_clocks {g_RGMII_TXC_2}] -clock_fall	[get_ports "RGMII_TXD[*] RGMII_TX_CTL"] -add_delay

#**************************************************************
# Set Clock Groups
#**************************************************************

#**************************************************************
# Set False Path
#**************************************************************

# DATA PATHS
set_false_path -from {gxbqsfp_per:gxbqsfp_per_inst|aurora_4lane_fd_str_wrapper:aurora_4lane_fd_str_wrapper_inst|aurora_4lane_fd_str:\gtx_quicksim_gen_false:aurora_4lane_fd_str_inst|aurora_4lane_fd_str_altera:gtx_wrapper_i|rx_analogreset[*]} -to {*}
set_false_path -from {gxbqsfp_per:gxbqsfp_per_inst|aurora_4lane_fd_str_wrapper:aurora_4lane_fd_str_wrapper_inst|aurora_4lane_fd_str:\gtx_quicksim_gen_false:aurora_4lane_fd_str_inst|aurora_4lane_fd_str_altera:gtx_wrapper_i|rx_digitalreset[*]} -to {*}
set_false_path -from {gxbqsfp_per:gxbqsfp_per_inst|aurora_4lane_fd_str_wrapper:aurora_4lane_fd_str_wrapper_inst|aurora_4lane_fd_str:\gtx_quicksim_gen_false:aurora_4lane_fd_str_inst|aurora_4lane_fd_str_altera:gtx_wrapper_i|tx_digitalreset[*]} -to {*}

set_false_path -from {gxbvxs_per:\gxbvxs_per_gen:*:gxbvxs_gen_true:gxbvxs_per_inst|aurora_5G_wrapper:aurora_5G_wrapper_inst|aurora_5G:\gtx_quicksim_gen_false:aurora_5G_inst|altera_aurora_5Gx2:gtx_wrapper_i|rx_analogreset[*]} -to {*}
set_false_path -from {gxbvxs_per:\gxbvxs_per_gen:*:gxbvxs_gen_true:gxbvxs_per_inst|aurora_5G_wrapper:aurora_5G_wrapper_inst|aurora_5G:\gtx_quicksim_gen_false:aurora_5G_inst|altera_aurora_5Gx2:gtx_wrapper_i|rx_digitalreset[*]} -to {*}
set_false_path -from {gxbvxs_per:\gxbvxs_per_gen:*:gxbvxs_gen_true:gxbvxs_per_inst|aurora_5G_wrapper:aurora_5G_wrapper_inst|aurora_5G:\gtx_quicksim_gen_false:aurora_5G_inst|altera_aurora_5Gx2:gtx_wrapper_i|tx_digitalreset[*]} -to {*}

# CLOCK TRANSFERS
set_false_path -from $clk_GCLK				-to [list $clk_GXBPMADIRECT_DESERCLOCK $clk_SDRAM_AFIHALF]
set_false_path -from $clk_SYSCLK_250		-to [list $clk_SDRAM_AFIHALF]
set_false_path -from $clk_SYSCLK_50			-to [list $clk_GCLK $clk_SDRAM_AFIHALF]
set_false_path -from $clk_SDRAM_AFIHALF	-to [list $clk_GCLK $clk_SYSCLK_250 $clk_SYSCLK_50 $clk_TIGTP_100_N18 RGMII_RXC ETH_CLK]
set_false_path -from $clk_TIGTP_100_N18	-to [list $clk_SDRAM_AFIHALF]
set_false_path -from RGMII_RXC				-to [list ETH_CLK $clk_SDRAM_AFIHALF]
set_false_path -from ETH_CLK					-to [list $clk_SYSCLK_250 $clk_SDRAM_AFIHALF RGMII_RXC]
set_false_path -from CLK250_T					-to [list $clk_SDRAM_AFIHALF]

set_false_path -setup -fall_from [get_clocks {v_RGMII_RXC}] -rise_to [get_clocks {RGMII_RXC}]
set_false_path -setup -rise_from [get_clocks {v_RGMII_RXC}] -fall_to [get_clocks {RGMII_RXC}]
set_false_path -hold  -rise_from [get_clocks {v_RGMII_RXC}] -rise_to [get_clocks {RGMII_RXC}]
set_false_path -hold  -fall_from [get_clocks {v_RGMII_RXC}] -fall_to [get_clocks {RGMII_RXC}]

set_false_path -from [get_registers {nios_wrapper:nios_wrapper_inst|reset_n_sreg[0]}] -to [get_registers *]

# false paths board configuration registers that are generally kept static

set_false_path -from [get_registers {trigger_per:trigger_per_inst|LATENCY_REG[*]}] -to [get_registers *]
set_false_path -from [get_registers {trigger_per:trigger_per_inst|CLUSTER_THR_REG[*]}] -to [get_registers *]
set_false_path -from [get_registers {trigger_per:trigger_per_inst|TRG_CTRL_REG[*]}] -to [get_registers *]

set_false_path -from [get_registers {sd_per:sd_per_inst|SCALER_LATCH_REG[0]}] -to [get_registers *]
set_false_path -from [get_registers {sd_per:sd_per_inst|PULSER_NCYCLES_REG[*]}] -to [get_registers *]

#**************************************************************
# Set Multicycle Path
#**************************************************************

set_multicycle_path -setup -end -rise_from [get_clocks v_RGMII_RXC] -rise_to [get_clocks RGMII_RXC] 0
set_multicycle_path -setup -end -fall_from [get_clocks v_RGMII_RXC] -fall_to [get_clocks RGMII_RXC] 0

#Only use this line for 5Gbps rate, not 2.5Gbps
#set_multicycle_path -setup -end -from [get_registers {*gen_pma_direct:gxb_transceiver_pcs_inst|tx_datain_pma[*]}] 2

#**************************************************************
# Set Maximum Delay
#**************************************************************

set_max_delay -from [get_registers *] -to [get_ports {ENET_PHY_MDIO}] 15.000
set_max_delay -from [get_ports {ENET_PHY_MDIO}] -to [get_registers *] 15.000

set_max_delay -from [get_ports {CODE_DATA[*] CONFIG_DATA[*]}] -to [get_registers *] 15.000
set_max_delay -from [get_registers *] -to [get_ports {CODE_DATA[*] CONFIG_DATA[*]}] 15.000
set_max_delay -from [get_registers *] -to [get_ports {CODE_ADDR[*] CONFIG_ADDR[*]}] 15.000
set_max_delay -from [get_registers *] -to [get_ports {CODE_NCE CONFIG_NCE}] 15.000
set_max_delay -from [get_registers *] -to [get_ports {CODE_NOE CONFIG_NOE}] 15.000
set_max_delay -from [get_registers *] -to [get_ports {CODE_NWE CONFIG_NWE}] 15.000
set_max_delay -from [get_registers *] -to [get_ports {CODE_NRST CONFIG_NRST}] 15.000

# NIOS <-> GTP PERIPHERAL BUS SLACK
set_max_delay -from [get_registers {nios_wrapper:nios_wrapper_inst|sopc_system:sopc_system_inst|gtp_regif:gtp_regif_0|BUS_WR}] -to [get_registers *] 40.000
set_max_delay -from [get_registers {nios_wrapper:nios_wrapper_inst|sopc_system:sopc_system_inst|gtp_regif:gtp_regif_0|BUS_RD}] -to [get_registers *] 40.000
set_max_delay -from [get_registers {nios_wrapper:nios_wrapper_inst|sopc_system:sopc_system_inst|gtp_regif:gtp_regif_0|BUS_ADDR[*]}] -to [get_registers *] 40.000
set_max_delay -from [get_registers {nios_wrapper:nios_wrapper_inst|sopc_system:sopc_system_inst|gtp_regif:gtp_regif_0|BUS_DIN[*]}] -to [get_registers *] 40.000
set_max_delay -from [get_registers *] -to [get_registers {nios_wrapper:nios_wrapper_inst|sopc_system:sopc_system_inst|gtp_regif:gtp_regif_0|BUS_ACK_Q[0]}] 40.000
set_max_delay -from [get_registers {*.DOUT[*]}] -to [get_registers {nios_wrapper:nios_wrapper_inst|sopc_system:sopc_system_inst|gtp_regif:gtp_regif_0|avs_s0_readdata[*]}] 40.000

#**************************************************************
# Set Minimum Delay
#**************************************************************

#**************************************************************
# Set Input Transition
#**************************************************************
