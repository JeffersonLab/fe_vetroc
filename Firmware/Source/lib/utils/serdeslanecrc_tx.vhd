library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity serdeslanecrc_tx is
	port(
		CLK				: in std_logic;
		TX_D_I			: in std_logic_vector(15 downto 0);
		TX_SRC_RDY_N_I	: in std_logic;
		
		TX_D_O			: out std_logic_vector(15 downto 0);
		TX_SRC_RDY_N_O	: out std_logic
	);
end serdeslanecrc_tx;

architecture Synthesis of serdeslanecrc_tx is
	component ucrc_par is
		generic(
			POLYNOMIAL	: std_logic_vector;
			INIT_VALUE	: std_logic_vector;
			DATA_WIDTH	: integer range 2 to 256;
			SYNC_RESET	: integer range 0 to 1
		);
		port(
			clk_i			: in std_logic;
			rst_i			: in std_logic;
			clken_i		: in std_logic;
			data_i		: in std_logic_vector(DATA_WIDTH-1 downto 0);
			match_o		: out std_logic;
			crc_o			: out std_logic_vector(POLYNOMIAL'length-1 downto 0)
		);
	end component;


	signal clken				: std_logic;
	signal CRC_RST				: std_logic;
	signal CRC					: std_logic_vector(15 downto 0);
	signal TX_SRC_RDY_N_I_Q	: std_logic;
begin

	clken <= not TX_SRC_RDY_N_I;
	CRC_RST <= TX_SRC_RDY_N_I;

	process(CLK)
	begin
		if rising_edge(CLK) then
			TX_SRC_RDY_N_I_Q <= TX_SRC_RDY_N_I;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if TX_SRC_RDY_N_I = '0' then
				TX_D_O <= TX_D_I;
				TX_SRC_RDY_N_O <= '0';
			elsif (TX_SRC_RDY_N_I = '1') and (TX_SRC_RDY_N_I_Q = '0') then
				TX_D_O <= CRC;
				TX_SRC_RDY_N_O <= '0';
			else
				TX_D_O <= x"0000";
				TX_SRC_RDY_N_O <= '1';
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
			clk_i			=> CLK,
			rst_i			=> CRC_RST,
			clken_i		=> clken,
			data_i		=> TX_D_I,
			match_o		=> open,
			crc_o			=> CRC
		);

end Synthesis;
