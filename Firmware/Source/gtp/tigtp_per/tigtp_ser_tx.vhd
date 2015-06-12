library ieee;
use ieee.std_logic_1164.all;

library unisim;

library altera_mf;

entity tigtp_ser_tx is
	generic(
		FPGA		: string := "VIRTEX5"
	);
	port(
		CLK_REF		: in std_logic;
		CLK_REF_5X	: in std_logic;
		PLL_RESET	: in std_logic;

		TX_CLK		: out std_logic;
		TX_DATA		: in std_logic_vector(7 downto 0);
		TX_K			: in std_logic;

		TXD			: out std_logic
	);
end tigtp_ser_tx;

architecture synthesis of tigtp_ser_tx is
	component encoder_8b10b is
		port(
			CLK			: in std_logic;

			KIN_ENA		: in std_logic;
			EIN_ENA		: in std_logic;
			EIN_DAT		: in std_logic_vector(7 downto 0);
			EIN_RD		: in std_logic;

			EOUT_VAL		: out std_logic;
			EOUT_DAT		: out std_logic_vector(9 downto 0);
			EOUT_RDCOMB	: out std_logic;
			EOUT_RDREG	: out std_logic
		);
	end component;

	component OSERDES is
		generic(
			DDR_CLK_EDGE			: string	:= "SAME_EDGE";
			INIT_LOADCNT			: bit_vector(3 downto 0) := "0000";
			INIT_ORANK1				: bit_vector(5 downto 0) := "000000";
			INIT_ORANK2_PARTIAL	: bit_vector(3 downto 0) := "0000";
			INIT_TRANK1				: bit_vector(3 downto 0) := "0000";
			SERDES					: boolean := TRUE;
			SRTYPE					: string	:= "ASYNC";
			DATA_RATE_OQ			: string	:= "DDR";
			DATA_RATE_TQ			: string	:= "DDR";
			DATA_WIDTH				: integer	:= 4;
			INIT_OQ					: bit := '0';
			INIT_TQ					: bit := '0';
			SERDES_MODE				: string	:= "MASTER";
			SRVAL_OQ					: bit := '0';
			SRVAL_TQ					: bit := '0';
			TRISTATE_WIDTH			: integer := 4
		);
		port(
			OQ				: out std_ulogic;
			SHIFTOUT1	: out std_ulogic;
			SHIFTOUT2	: out std_ulogic;
			TQ				: out std_ulogic;
			CLK			: in std_ulogic;
			CLKDIV		: in std_ulogic;
			D1				: in std_ulogic;
			D2				: in std_ulogic;
			D3				: in std_ulogic;
			D4				: in std_ulogic;
			D5				: in std_ulogic;
			D6				: in std_ulogic;
			OCE			: in std_ulogic;
			REV			: in std_ulogic;
			SHIFTIN1		: in std_ulogic;
			SHIFTIN2		: in std_ulogic;
			SR				: in std_ulogic;
			T1				: in std_ulogic;
			T2				: in std_ulogic;
			T3				: in std_ulogic;
			T4				: in std_ulogic;
			TCE			: in std_ulogic
		);
	end component;

	component altlvds_tx
		generic(
			center_align_msb					: string;
			common_rx_tx_pll					: string;
			coreclock_divide_by				: natural;
			data_rate							: string;
			deserialization_factor			: natural;
			differential_drive				: natural;
			enable_clock_pin_mode			: string;
			implement_in_les					: string;
			inclock_boost						: natural;
			inclock_data_alignment			: string;
			inclock_period						: natural;
			inclock_phase_shift				: natural;
			intended_device_family			: string;
			lpm_hint								: string;
			lpm_type								: string;
			multi_clock							: string;
			number_of_channels				: natural;
			outclock_alignment				: string;
			outclock_divide_by				: natural;
			outclock_duty_cycle				: natural;
			outclock_multiply_by				: natural;
			outclock_phase_shift				: natural;
			outclock_resource					: string;
			output_data_rate					: natural;
			pll_compensation_mode			: string;
			pll_self_reset_on_loss_lock	: string;
			preemphasis_setting				: natural;
			refclk_frequency					: string;
			registered_input					: string;
			use_external_pll					: string;
			use_no_phase_shift				: string;
			vod_setting							: natural;
			clk_src_is_pll						: string
		);
		port(
			tx_in				: in std_logic_vector(9 downto 0);
			tx_inclock		: in std_logic;
			pll_areset		: in std_logic;
			tx_coreclock	: out std_logic;
			tx_out			: out std_logic_vector(0 downto 0)
		);
	end component;

	signal EOUT_DAT		: std_logic_vector(9 downto 0);
	signal EOUT_RDREG		: std_logic;
	signal TX_CLK_i		: std_logic;
begin

	TX_CLK <= TX_CLK_i;

	encoder_8b10b_inst: encoder_8b10b
		port map(
			CLK			=> TX_CLK_i,
			KIN_ENA		=> TX_K,
			EIN_ENA		=> '1',
			EIN_DAT		=> TX_DATA,
			EIN_RD		=> EOUT_RDREG,
			EOUT_VAL		=> OPEN,
			EOUT_DAT		=> EOUT_DAT,
			EOUT_RDCOMB	=> OPEN,
			EOUT_RDREG	=> EOUT_RDREG
		);

	tx_serdes_eps4_gen: if FPGA = "STRATIX4" generate

		altlvds_tx_inst: altlvds_tx
			generic map(
				center_align_msb					=> "UNUSED",
				common_rx_tx_pll					=> "ON",
				coreclock_divide_by				=> 1,
				data_rate							=> "1000.0 Mbps",
				deserialization_factor			=> 10,
				differential_drive				=> 0,
				enable_clock_pin_mode			=> "UNUSED",
				implement_in_les					=> "OFF",
				inclock_boost						=> 0,
				inclock_data_alignment			=> "EDGE_ALIGNED",
				inclock_period						=> 4000,
				inclock_phase_shift				=> 0,
				intended_device_family			=> "Stratix IV",
				lpm_hint								=> "CBX_MODULE_PREFIX=oserdes_eps4",
				lpm_type								=> "altlvds_tx",
				multi_clock							=> "off",
				number_of_channels				=> 1,
				outclock_alignment				=> "EDGE_ALIGNED",
				outclock_divide_by				=> 2,
				outclock_duty_cycle				=> 50,
				outclock_multiply_by				=> 1,
				outclock_phase_shift				=> 0,
				outclock_resource					=> "AUTO",
				output_data_rate					=> 1000,
				pll_compensation_mode			=> "AUTO",
				pll_self_reset_on_loss_lock	=> "OFF",
				preemphasis_setting				=> 0,
				refclk_frequency					=> "UNUSED",
				registered_input					=> "TX_CORECLK",
				use_external_pll					=> "OFF",
				use_no_phase_shift				=> "ON",
				vod_setting							=> 0,
				clk_src_is_pll						=> "off"
			)
			port map (
				tx_in(0)			=> EOUT_DAT(9),
				tx_in(1)			=> EOUT_DAT(8),
				tx_in(2)			=> EOUT_DAT(7),
				tx_in(3)			=> EOUT_DAT(6),
				tx_in(4)			=> EOUT_DAT(5),
				tx_in(5)			=> EOUT_DAT(4),
				tx_in(6)			=> EOUT_DAT(3),
				tx_in(7)			=> EOUT_DAT(2),
				tx_in(8)			=> EOUT_DAT(1),
				tx_in(9)			=> EOUT_DAT(0),
				tx_inclock		=> CLK_REF,
				pll_areset		=> PLL_RESET,
				tx_coreclock	=> TX_CLK_i,
				tx_out(0)		=> TXD
			);

	end generate;

	tx_serdes_v5_gen: if FPGA = "VIRTEX5" generate
		signal SHIFTOUT1		: std_logic;
		signal SHIFTOUT2		: std_logic;
	begin
		TX_CLK_i <= CLK_REF;

		OSERDES_inst_master: OSERDES
			generic map(
				DATA_RATE_OQ	=> "DDR",
				DATA_RATE_TQ	=> "DDR",
				DATA_WIDTH		=> 10,
				INIT_OQ			=> '0',
				INIT_TQ			=> '0',
				SERDES_MODE		=> "MASTER",
				SRVAL_OQ			=> '0',
				SRVAL_TQ			=> '0',
				TRISTATE_WIDTH	=> 4
			)
			port map(
				OQ				=> TXD,
				SHIFTOUT1	=> open,
				SHIFTOUT2	=> open,
				TQ				=> open,
				CLK			=> CLK_REF_5X,
				CLKDIV		=> CLK_REF,
				D1				=> EOUT_DAT(0),
				D2				=> EOUT_DAT(1),
				D3				=> EOUT_DAT(2),
				D4				=> EOUT_DAT(3),
				D5				=> EOUT_DAT(4),
				D6				=> EOUT_DAT(5),
				OCE			=> '1',
				REV			=> '0',
				SHIFTIN1		=> SHIFTOUT1,
				SHIFTIN2		=> SHIFTOUT2,
				SR				=> '0',
				T1				=> '0',
				T2				=> '0',
				T3				=> '0',
				T4				=> '0',
				TCE			=> '0'
			);

		OSERDES_inst_slave: OSERDES
			generic map(
				DATA_RATE_OQ	=> "DDR",
				DATA_RATE_TQ	=> "DDR",
				DATA_WIDTH		=> 10,
				INIT_OQ			=> '0',
				INIT_TQ			=> '0',
				SERDES_MODE		=> "SLAVE",
				SRVAL_OQ			=> '0',
				SRVAL_TQ			=> '0',
				TRISTATE_WIDTH	=> 4
			)
			port map(
				OQ				=> open,
				SHIFTOUT1	=> SHIFTOUT1,
				SHIFTOUT2	=> SHIFTOUT2,
				TQ				=> open,
				CLK			=> CLK_REF_5X,
				CLKDIV		=> CLK_REF,
				D1				=> '0',
				D2				=> '0',
				D3				=> EOUT_DAT(6),
				D4				=> EOUT_DAT(7),
				D5				=> EOUT_DAT(8),
				D6				=> EOUT_DAT(9),
				OCE			=> '1',
				REV			=> '0',
				SHIFTIN1		=> '0',
				SHIFTIN2		=> '0',
				SR				=> '0',
				T1				=> '0',
				T2				=> '0',
				T3				=> '0',
				T4				=> '0',
				TCE			=> '0'
			);
	end generate;

end synthesis;
