proc add_wave_breadthwiserecursive { instance_name prev_group_option } {
	set filterinst [list \
		"dsp48_edslope_inst" "xfifo_*" "iobuf*" "obuf*" "ibuf*" "ICAP_*" "STARTUP_*" \
		"PerBusCtrl_*" \
		"pll_atx_*" "sysclkpll_inst" "pll250b" "dcfifo*" "scfifo*" "altlvds_*" \
		"gxbconfig_per_inst_*" "altddio_*" \
		"sdp_ram_*" "tdp_ram_*" \
		"IODELAY*" "UIDELAYCTRL*" "sd_ctrl_inst" "xDataRxBuf*" "Ujtag_prom_top_V2" \
		"UPU_RST_CLKEN" "UAT25040_TOP" "PLL_ADV*" "BUFG*" "UCLK_*" \
		"DSP48*" "PlayBack16_WV_inst" "UIBUF*" "RAMB18_*" \
	]

	# Should be a list something like "/top/inst (MOD1)"
	set breadthwise_instances [find instances $instance_name/*]
 	append breadthwise_instances " "
 	append breadthwise_instances [find blocks $instance_name/*]

	# IFF there are items itterate through them breadthwise
	foreach inst $breadthwise_instances {
		# Separate "/top/inst"  from "(MOD1)"
		set inst_path [lindex [split $inst " "] 0]

		# Get just the end word after last "/"
		set gname     [lrange [split $inst_path "/"] end end]
		set skip 0
		foreach filter $filterinst {
			if {[string match -nocase $filter $gname] == 1} {
				set skip 1
			}
		}

		if {$skip == 0} {
			# Recursively call this routine with next level to investigate
			add_wave_breadthwiserecursive  "$inst_path"  "$prev_group_option -group $gname" 
		} else {
			echo "skipping instance: $instance_name/$gname"
		}
	}

	# Skip trying to add Block unit types to wave
	set instance_names [find instances $instance_name]
	if {[llength $instance_names]==0} {
		return
	}
	# Avoid including your top level /* as we already have /top/*
	if { $instance_name != "" } {
		# Echo the wave add command, but you can turn this off
		# echo add wave -noupdate $prev_group_option -group local "$instance_name/*"

		set CMD "add wave -noupdate $prev_group_option -group . $instance_name/*"
		eval $CMD
	}

	# Return up the recursing stack
	return
}

proc add_wave_run {} {
	add_wave_breadthwiserecursive "/hps_tb" ""
	wave refresh
	return
}

proc restart_and_run {} {
	restart
	run
}
