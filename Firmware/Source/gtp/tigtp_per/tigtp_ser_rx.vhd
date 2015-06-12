library ieee;
use ieee.std_logic_1164.all;

library unisim;

library altera_mf;

entity tigtp_ser_rx is
	generic(
		FPGA		: string := "VIRTEX5"
	);
	port(
		CLK_REF			: in std_logic;
		CLK_REF_5X		: in std_logic;

		RX_RESET			: in std_logic;
		PLL_RESET		: in std_logic;
		RX_FIFO_RESET	: in std_logic;

		DLYCE				: in std_logic;
		DLYINC			: in std_logic;
		DLYRST			: in std_logic;
		BITSLIP			: in std_logic;

		RX_CLK			: out std_logic;
		RX_LOCKED		: out std_logic;
		RX_ERROR			: out std_logic;
		RX_DATA			: out std_logic_vector(7 downto 0);
		RX_K				: out std_logic;

		RXD				: in std_logic
	);
end tigtp_ser_rx;

architecture synthesis of tigtp_ser_rx is
	component decoder_8b10b is
		port(
			CLK			: in std_logic;
			DIN_ENA		: in std_logic;
			DIN_DAT		: in std_logic_vector(9 downto 0);
			DIN_RD		: in std_logic;
			DOUT_VAL		: out std_logic := '0';
			DOUT_KERR	: out std_logic := '0';
			DOUT_DAT		: out std_logic_vector(7 downto 0) := "00000000";
			DOUT_K		: out std_logic := '0';
			DOUT_RDERR	: out std_logic := '0';
			DOUT_RDCOMB	: out std_logic;
			DOUT_RDREG	: out std_logic := '0'
		);
	end component;

	component ISERDES is
		generic(
			DDR_CLK_EDGE			: string := "SAME_EDGE_PIPELINED";
			INIT_BITSLIPCNT		: bit_vector(3 downto 0) := "0000";
			INIT_CE					: bit_vector(1 downto 0) := "00";
			INIT_RANK1_PARTIAL	: bit_vector(4 downto 0) := "00000";
			INIT_RANK2				: bit_vector(5 downto 0) := "000000";
			INIT_RANK3				: bit_vector(5 downto 0) := "000000";
			SERDES					: boolean := TRUE;
			SRTYPE					: string := "ASYNC";
			BITSLIP_ENABLE			: boolean := false;
			DATA_RATE				: string := "DDR";
			DATA_WIDTH				: integer := 4;
			INIT_Q1					: bit := '0';
			INIT_Q2					: bit := '0';
			INIT_Q3					: bit := '0';
			INIT_Q4					: bit := '0';
			INTERFACE_TYPE			: string := "MEMORY";
			IOBDELAY					: string := "NONE";
			IOBDELAY_TYPE			: string := "DEFAULT";
			IOBDELAY_VALUE			: integer := 0;
			NUM_CE					: integer := 2;
			SERDES_MODE				: string := "MASTER";
			SRVAL_Q1					: bit := '0';
			SRVAL_Q2					: bit := '0';
			SRVAL_Q3					: bit := '0';
			SRVAL_Q4					: bit := '0'
		);
		port(
			O							: out std_ulogic;
			Q1							: out std_ulogic;
			Q2							: out std_ulogic;
			Q3							: out std_ulogic;
			Q4							: out std_ulogic;
			Q5							: out std_ulogic;
			Q6							: out std_ulogic;
			SHIFTOUT1				: out std_ulogic;
			SHIFTOUT2				: out std_ulogic;
			BITSLIP					: in std_ulogic;
			CE1						: in std_ulogic;
			CE2						: in std_ulogic;
			CLK						: in std_ulogic;
			CLKDIV					: in std_ulogic;
			D							: in std_ulogic;
			DLYCE						: in std_ulogic;
			DLYINC					: in std_ulogic;
			DLYRST					: in std_ulogic;
			OCLK						: in std_ulogic;
			REV						: in std_ulogic;
			SHIFTIN1					: in std_ulogic;
			SHIFTIN2					: in std_ulogic;
			SR							: in std_ulogic
		);
	end component;

	component altlvds_rx
		generic(
			buffer_implementation						: STRING;
			cds_mode											: STRING;
			common_rx_tx_pll								: STRING;
			data_align_rollover							: NATURAL;
			data_rate										: STRING;
			deserialization_factor						: NATURAL;
			dpa_initial_phase_value						: NATURAL;
			dpll_lock_count								: NATURAL;
			dpll_lock_window								: NATURAL;
			enable_clock_pin_mode						: STRING;
			enable_dpa_align_to_rising_edge_only	: STRING;
			enable_dpa_calibration						: STRING;
			enable_dpa_fifo								: STRING;
			enable_dpa_initial_phase_selection		: STRING;
			enable_dpa_mode								: STRING;
			enable_dpa_pll_calibration					: STRING;
			enable_soft_cdr_mode							: STRING;
			implement_in_les								: STRING;
			inclock_boost									: NATURAL;
			inclock_data_alignment						: STRING;
			inclock_period									: NATURAL;
			inclock_phase_shift							: NATURAL;
			input_data_rate								: NATURAL;
			intended_device_family						: STRING;
			lose_lock_on_one_change						: STRING;
			lpm_hint											: STRING;
			lpm_type											: STRING;
			number_of_channels							: NATURAL;
			outclock_resource								: STRING;
			pll_operation_mode							: STRING;
			pll_self_reset_on_loss_lock				: STRING;
			port_rx_channel_data_align					: STRING;
			port_rx_data_align							: STRING;
			refclk_frequency								: STRING;
			registered_data_align_input				: STRING;
			registered_output								: STRING;
			reset_fifo_at_first_lock					: STRING;
			rx_align_data_reg								: STRING;
			sim_dpa_is_negative_ppm_drift				: STRING;
			sim_dpa_net_ppm_variation					: NATURAL;
			sim_dpa_output_clock_phase_shift			: NATURAL;
			use_coreclock_input							: STRING;
			use_dpll_rawperror							: STRING;
			use_external_pll								: STRING;
			use_no_phase_shift							: STRING;
			x_on_bitslip									: STRING;
			clk_src_is_pll									: STRING
		);
		port(
			rx_in							: in std_logic_vector(0 downto 0);
			rx_inclock					: in std_logic;
			rx_reset						: in std_logic_vector(0 downto 0);
			pll_areset					: in std_logic;
			rx_channel_data_align	: in std_logic_vector (0 downto 0);
			rx_dpa_locked				: out std_logic_vector (0 downto 0);
			rx_fifo_reset				: in std_logic_vector (0 downto 0);
			rx_locked					: out std_logic;
			rx_out						: out std_logic_vector (9 downto 0);
			rx_outclock					: out std_logic 
		);
	end component;

	signal DOUT_KERR		: std_logic;
	signal DOUT_RDERR		: std_logic;
	signal DOUT_RDREG		: std_logic;
	signal DIN_DAT			: std_logic_vector(9 downto 0);
	signal RX_CLK_i		: std_logic;
begin

	RX_CLK <= RX_CLK_i;

	RX_ERROR <= DOUT_KERR or DOUT_RDERR;

	decoder_8b10b_inst: decoder_8b10b
		port map(
			CLK			=> RX_CLK_i,
			DIN_ENA		=> '1',
			DIN_DAT		=> DIN_DAT,
			DIN_RD		=> DOUT_RDREG,
			DOUT_VAL		=> OPEN,
			DOUT_KERR	=> DOUT_KERR,
			DOUT_DAT		=> RX_DATA,
			DOUT_K		=> RX_K,
			DOUT_RDERR	=> DOUT_RDERR,
			DOUT_RDCOMB	=> OPEN,
			DOUT_RDREG	=> DOUT_RDREG
		);

	tx_serdes_eps4_gen: if FPGA = "STRATIX4" generate
		altlvds_rx_inst: altlvds_rx
			generic map(
				buffer_implementation						=> "RAM",
				cds_mode											=> "UNUSED",
				common_rx_tx_pll								=> "ON",
				data_align_rollover							=> 10,
				data_rate										=> "1000.0 Mbps",
				deserialization_factor						=> 10,
				dpa_initial_phase_value						=> 0,
				dpll_lock_count								=> 0,
				dpll_lock_window								=> 0,
				enable_clock_pin_mode						=> "UNUSED",
				enable_dpa_align_to_rising_edge_only	=> "OFF",
				enable_dpa_calibration						=> "ON",
				enable_dpa_fifo								=> "UNUSED",
				enable_dpa_initial_phase_selection		=> "OFF",
				enable_dpa_mode								=> "ON",
				enable_dpa_pll_calibration					=> "OFF",
				enable_soft_cdr_mode							=> "OFF",
				implement_in_les								=> "OFF",
				inclock_boost									=> 0,
				inclock_data_alignment						=> "EDGE_ALIGNED",
				inclock_period									=> 4000,
				inclock_phase_shift							=> 0,
				input_data_rate								=> 1000,
				intended_device_family						=> "Stratix IV",
				lose_lock_on_one_change						=> "UNUSED",
				lpm_hint											=> "CBX_MODULE_PREFIX=iserdes_eps4",
				lpm_type											=> "altlvds_rx",
				number_of_channels							=> 1,
				outclock_resource								=> "AUTO",
				pll_operation_mode							=> "UNUSED",
				pll_self_reset_on_loss_lock				=> "UNUSED",
				port_rx_channel_data_align					=> "PORT_USED",
				port_rx_data_align							=> "PORT_UNUSED",
				refclk_frequency								=> "UNUSED",
				registered_data_align_input				=> "UNUSED",
				registered_output								=> "ON",
				reset_fifo_at_first_lock					=> "UNUSED",
				rx_align_data_reg								=> "UNUSED",
				sim_dpa_is_negative_ppm_drift				=> "OFF",
				sim_dpa_net_ppm_variation					=> 0,
				sim_dpa_output_clock_phase_shift			=> 0,
				use_coreclock_input							=> "OFF",
				use_dpll_rawperror							=> "OFF",
				use_external_pll								=> "OFF",
				use_no_phase_shift							=> "ON",
				x_on_bitslip									=> "ON",
				clk_src_is_pll									=> "off"
			)
			port map(
				rx_in(0)						=> RXD,
				rx_inclock					=> CLK_REF,
				rx_reset(0)					=> RX_RESET,
				pll_areset					=> PLL_RESET,
				rx_channel_data_align(0)=> BITSLIP,
				rx_fifo_reset(0)			=> RX_FIFO_RESET,
				rx_dpa_locked(0)			=> RX_LOCKED,
				rx_locked					=> open,
				rx_out(0)					=> DIN_DAT(9),
				rx_out(1)					=> DIN_DAT(8),
				rx_out(2)					=> DIN_DAT(7),
				rx_out(3)					=> DIN_DAT(6),
				rx_out(4)					=> DIN_DAT(5),
				rx_out(5)					=> DIN_DAT(4),
				rx_out(6)					=> DIN_DAT(3),
				rx_out(7)					=> DIN_DAT(2),
				rx_out(8)					=> DIN_DAT(1),
				rx_out(9)					=> DIN_DAT(0),
				rx_outclock					=> RX_CLK_i
			);
	end generate;

	tx_serdes_v5_gen: if FPGA = "VIRTEX5" generate
		signal SHIFTOUT1		: std_logic;
		signal SHIFTOUT2		: std_logic;
	begin
		RX_CLK_i <= CLK_REF;
		RX_LOCKED <= '1';

		ISERDES_inst_master: ISERDES
			generic map(
				BITSLIP_ENABLE	=> TRUE,
				DATA_RATE		=> "DDR",
				DATA_WIDTH		=> 10,
				INTERFACE_TYPE	=> "NETWORKING",
				IOBDELAY			=> "IFD",
				IOBDELAY_TYPE	=> "VARIABLE",
				IOBDELAY_VALUE	=> 0,
				NUM_CE			=> 2,
				SERDES_MODE		=> "MASTER"
			)
			port map(
				O				=> open,
				Q1				=> DIN_DAT(9),
				Q2				=> DIN_DAT(8),
				Q3				=> DIN_DAT(7),
				Q4				=> DIN_DAT(6),
				Q5				=> DIN_DAT(5),
				Q6				=> DIN_DAT(4),
				SHIFTOUT1	=> SHIFTOUT1,
				SHIFTOUT2	=> SHIFTOUT2,
				BITSLIP		=> BITSLIP,
				CE1			=>	'1',
				CE2			=> '1',
				CLK			=> CLK_REF_5X,
				CLKDIV		=> CLK_REF,
				D				=> RXD,
				DLYCE			=> DLYCE,
				DLYINC		=> DLYINC,
				DLYRST		=> DLYRST,
				OCLK			=> '0',
				REV			=> '0',
				SHIFTIN1		=> '0',
				SHIFTIN2		=> '0',
				SR				=> RX_RESET
			);

		ISERDES_inst_slave: ISERDES
			generic map(
				BITSLIP_ENABLE	=> TRUE,
				DATA_RATE		=> "DDR",
				DATA_WIDTH		=> 10,
				INTERFACE_TYPE	=> "NETWORKING",
				IOBDELAY			=> "IFD",
				IOBDELAY_TYPE	=> "VARIABLE",
				IOBDELAY_VALUE	=> 0,
				NUM_CE			=> 2,
				SERDES_MODE		=> "SLAVE"
			)
			port map(
				O				=> open,
				Q1				=> open,
				Q2				=> open,
				Q3				=> DIN_DAT(3),
				Q4				=> DIN_DAT(2),
				Q5				=> DIN_DAT(1),
				Q6				=> DIN_DAT(0),
				SHIFTOUT1	=> open,
				SHIFTOUT2	=> open,
				BITSLIP		=> BITSLIP,
				CE1			=>	'1',
				CE2			=> '1',
				CLK			=> CLK_REF_5X,
				CLKDIV		=> CLK_REF,
				D				=> '0',
				DLYCE			=> '0',
				DLYINC		=> '0',
				DLYRST		=> '0',
				OCLK			=> '0',
				REV			=> '0',
				SHIFTIN1		=> SHIFTOUT1,
				SHIFTIN2		=> SHIFTOUT2,
				SR				=> RX_RESET
			);
	end generate;

end synthesis;
