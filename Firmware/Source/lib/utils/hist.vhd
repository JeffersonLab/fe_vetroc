library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

use work.utils_pkg.all;

entity hist is
	generic(
		BIN_DEPTH		: integer := 32;
		BIN_WIDTH		: integer := 10
	);
	port(
		CLK				: in std_logic;
		
		ENABLE			: in std_logic;
		BIN_DATA			: out std_logic_vector(BIN_DEPTH-1 downto 0);
		BIN_RD			: in std_logic;

		GATE				: in std_logic;
		BIN				: in std_logic_vector(BIN_WIDTH-1 downto 0)
	);
end hist;

architecture Synthesis of hist is
	signal BIN_ADDR		: std_logic_vector(BIN_WIDTH-1 downto 0) := (others=>'0');
	signal INC				: std_logic;
	signal INC_Q			: std_logic_vector(1 downto 0);
	signal ENABLE_Q		: std_logic;
	signal GATE_Q			: std_logic;
	signal BIN_Q0			: std_logic_vector(BIN_WIDTH-1 downto 0) := (others=>'0');
	signal BIN_Q1			: std_logic_vector(BIN_WIDTH-1 downto 0) := (others=>'0');
	signal BIN_Q2			: std_logic_vector(BIN_WIDTH-1 downto 0) := (others=>'0');
	signal OVERFLOW		: std_logic;

	signal DINA				: std_logic_vector(BIN_DEPTH-1 downto 0);
	signal DINB				: std_logic_vector(BIN_DEPTH-1 downto 0);
	signal DOUTA			: std_logic_vector(BIN_DEPTH-1 downto 0);
	signal WRA				: std_logic;
	signal WRB				: std_logic;
	signal ADDRA			: std_logic_vector(BIN_WIDTH-1 downto 0) := (others=>'0');
	signal ADDRB			: std_logic_vector(BIN_WIDTH-1 downto 0) := (others=>'0');
begin
	
	INC <= ENABLE_Q and GATE_Q;
	OVERFLOW <= '1' when (and_reduce(DOUTA) = '1') else '0';
	
	DINA <= (others=>'0');
	ADDRA <= BIN_Q0 when ENABLE_Q = '1' else BIN_ADDR;
	WRA <= BIN_RD and not ENABLE_Q;

	DINB <= DOUTA + 1;
	ADDRB <= BIN_Q2;
	WRB <= INC_Q(1) and not OVERFLOW;

	process(CLK)
	begin
		if rising_edge(CLK) then
			BIN_DATA <= DOUTA;
			GATE_Q <= GATE;
			BIN_Q0 <= BIN;
			BIN_Q1 <= BIN_Q0;
			BIN_Q2 <= BIN_Q1;
			INC_Q <= INC_Q(INC_Q'length-2 downto 0) & INC;
			ENABLE_Q <= ENABLE;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if ENABLE_Q = '1' then
				BIN_ADDR <= (others=>'0');
			elsif BIN_RD = '1' then
				BIN_ADDR <= BIN_ADDR + 1;
			end if;
		end if;
	end process;

	tdp_ram_inst: tdp_ram
		generic map(
			D_WIDTH		=> BIN_DEPTH,
			A_WIDTH		=> BIN_WIDTH,
			DOUTA_REG	=> true,
			DOUTB_REG	=> true
		)
		port map(
			CLKA		=> CLK,
			WRA		=> WRA,
			RDA		=> '1',
			ADDRA		=> ADDRA,
			DINA		=> DINA,
			DOUTA		=> DOUTA,
			CLKB		=> CLK,
			WRB		=> WRB,
			RDB		=> '1',
			ADDRB		=> ADDRB,
			DINB		=> DINB,
			DOUTB		=> open
		);

end Synthesis;
