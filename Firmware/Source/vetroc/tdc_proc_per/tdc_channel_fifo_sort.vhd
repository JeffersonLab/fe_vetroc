library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

entity tdc_channel_fifo_sort is
	generic(
		AWIDTH	: integer
	);
	port(
		CLK		: in std_logic;

		WR_0		: in std_logic;
		DIN_0		: in std_logic_vector(21 downto 0);
		FULL_0	: out std_logic;

		WR_1		: in std_logic;
		DIN_1		: in std_logic_vector(21 downto 0);
		FULL_1	: out std_logic;

		WR			: out std_logic;
		DIN		: out std_logic_vector(21 downto 0);
		FULL		: in std_logic
	);
end tdc_channel_fifo_sort;

architecture synthesis of tdc_channel_fifo_sort is
	signal RD_0			: std_logic;
	signal DOUT_0		: std_logic_vector(21 downto 0);
	signal EMPTY_0		: std_logic;
	signal RD_1			: std_logic;
	signal DOUT_1		: std_logic_vector(21 downto 0);
	signal EMPTY_1		: std_logic;
begin

	scfifo_generic_inst0: scfifo_generic
		generic map(
			D_WIDTH	=> 22,
			A_WIDTH	=> AWIDTH,
			DOUT_REG	=> true,
			FWFT		=> true
		)
		port map(
			CLK		=> CLK,
			RST		=> '0',
			DIN		=> DIN_0,
			WR			=> WR_0,
			FULL		=> FULL_0,
			DOUT		=> DOUT_0,
			RD			=> RD_0,
			EMPTY		=> EMPTY_0
		);

	scfifo_generic_inst1: scfifo_generic
		generic map(
			D_WIDTH	=> 22,
			A_WIDTH	=> AWIDTH,
			DOUT_REG	=> true,
			FWFT		=> true
		)
		port map(
			CLK		=> CLK,
			RST		=> '0',
			DIN		=> DIN_1,
			WR			=> WR_1,
			FULL		=> FULL_1,
			DOUT		=> DOUT_1,
			RD			=> RD_1,
			EMPTY		=> EMPTY_1
		);

	WR <= RD_0 or RD_1;
	DIN <= DOUT_0 when RD_0 = '1' else DOUT_1;

	process(FULL, EMPTY_0, EMPTY_1, DOUT_0, DOUT_1, RD_0, RD_1)
		variable tdiff		: std_logic_vector(12 downto 0);
	begin
		tdiff := DOUT_1(12 downto 0) - DOUT_0(12 downto 0);

		if FULL = '0' and EMPTY_0 = '0' and EMPTY_1 = '1' then
			RD_0 <= '1';
			RD_1 <= '0';
		elsif FULL = '0' and EMPTY_0 = '1' and EMPTY_1 = '0' then
			RD_0 <= '0';
			RD_1 <= '1';
		elsif FULL = '0' and EMPTY_0 = '0' and EMPTY_1 = '0' then
			RD_0 <= not tdiff(12);
			RD_1 <= tdiff(12);
		else
			RD_0 <= '0';
			RD_1 <= '0';
		end if;
	end process;

end synthesis;
