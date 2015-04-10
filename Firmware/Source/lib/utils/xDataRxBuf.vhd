library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity xDataRxBuf is
	generic(
		DELAY				: integer := 0;
		SIGNAL_PATTERN	: string := "CLOCK";
		USE_REG			: boolean := false;
		IS_CLK			: boolean := false
	);
	port(
		CLK				: in std_logic;
		
		-- Differential Inputs
		DATA_P			: in std_logic;
		DATA_N			: in std_logic;

		-- Output
		DATA				: out std_logic
	);
end xDataRxBuf;

architecture Synthesis of xDataRxBuf is
	signal DATA_IBUFDS	: std_logic;
	signal DATA_IDELAY	: std_logic;
begin

	IsClk_Gen_true: if IS_CLK = true generate
		IBUFGDS_inst: IBUFGDS
			generic map(
				DIFF_TERM	=> TRUE,
				IOSTANDARD	=> "LVDS_25"
			)
			port map(
				O	=> DATA_IBUFDS,
				I	=> DATA_P,
				IB	=> DATA_N
			);
	end generate;

	IsClk_Gen_false: if IS_CLK = false generate
		IBUFDS_inst: IBUFDS
			generic map(
				DIFF_TERM	=> TRUE,
				IOSTANDARD	=> "LVDS_25"
			)
			port map(
				O	=> DATA_IBUFDS,
				I	=> DATA_P,
				IB	=> DATA_N
			);
	end generate;

	IODELAY_inst: IODELAY
		generic map (
			DELAY_SRC					=> "I",
			HIGH_PERFORMANCE_MODE	=> TRUE,
			IDELAY_TYPE					=> "FIXED",
			IDELAY_VALUE				=> DELAY,
			ODELAY_VALUE				=> 0,
			REFCLK_FREQUENCY			=> 200.0,
			SIGNAL_PATTERN				=> SIGNAL_PATTERN
		)
		port map (
			DATAOUT	=> DATA_IDELAY,
			C			=> '0',
			CE			=> '0',
			DATAIN	=> '0',
			IDATAIN	=> DATA_IBUFDS,
			INC		=> '0',
			ODATAIN	=> '0',
			RST		=> '0',
			T			=> '0'
		);

	UseReg_Gen_true: if USE_REG = true generate
		attribute iob	: string;
		attribute iob of reg	: label is "FORCE";
	begin
		reg: process(CLK)
		begin
			if rising_edge(CLK) then
				DATA <= DATA_IDELAY;
			end if;
		end process;
	end generate;
	
	UseReg_Gen_false: if USE_REG = false generate
		DATA <= DATA_IDELAY;
	end generate;	

end Synthesis;
