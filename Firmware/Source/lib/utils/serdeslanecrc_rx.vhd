library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity serdeslanecrc_rx is
	port(
		CLK					: in std_logic;
		CRC_RST				: in std_logic;
		RX_D_I				: in std_logic_vector(15 downto 0);
		RX_D_SRC_RDY_N_I	: in std_logic;
		
		RX_D_O				: out std_logic_vector(15 downto 0);
		RX_D_SRC_RDY_N_O	: out std_logic;
		CRC_PASS				: out std_logic
	);
end serdeslanecrc_rx;

architecture Synthesis of serdeslanecrc_rx is
	component ucrc_par is
		generic(
			POLYNOMIAL	: std_logic_vector;
			INIT_VALUE	: std_logic_vector;
			DATA_WIDTH	: integer range 2 to 256;
			SYNC_RESET	: integer range 0 to 1
		);
		port(
		clk_i		: in std_logic;
		rst_i		: in std_logic;
		clken_i	: in std_logic;
		data_i	: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		match_o	: out std_logic;
		crc_o		: out std_logic_vector(POLYNOMIAL'length - 1 downto 0)
		);
	end component;

	signal RX_D_SRC_RDY_N_I_Q	: std_logic;
	signal CRC						: std_logic_vector(15 downto 0);
	signal CRC_MATCH				: std_logic := '0';
	signal CRC_PASS_i				: std_logic := '0';
	signal clken					: std_logic;
begin
	CRC_PASS <= CRC_PASS_i;

	clken <= not RX_D_SRC_RDY_N_I;

	RX_D_SRC_RDY_N_O <= RX_D_SRC_RDY_N_I_Q or RX_D_SRC_RDY_N_I;

	process(CLK)
	begin
		if rising_edge(CLK) then
			RX_D_O <= RX_D_I;
			RX_D_SRC_RDY_N_I_Q <= RX_D_SRC_RDY_N_I;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if (RX_D_SRC_RDY_N_I = '1') and (RX_D_SRC_RDY_N_I_Q = '0') then
				if CRC_MATCH = '1' then
					CRC_PASS_i <= '1';
				else
					CRC_PASS_i <= '0';
				end if;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if (CRC = RX_D_I) then
				CRC_MATCH <= '1';
			else
				CRC_MATCH <= '0';
			end if;
		end if;
	end process;

	ucrc_par_inst0: ucrc_par
		generic map(
			POLYNOMIAL	=> x"1021",
			INIT_VALUE	=> x"FFFF",
			DATA_WIDTH	=> 16,
			SYNC_RESET	=> 1
		)
		port map(
			clk_i		=> CLK,
			rst_i		=> CRC_RST,
			clken_i	=> clken,
			data_i	=> RX_D_I,
			match_o	=> open,
			crc_o		=> CRC
		);
		
end Synthesis;
