library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.utils_pkg.all;

entity sum_mon is
	port(
		CLK					: in std_logic;

		SUM_MON_THR			: in std_logic_vector(31 downto 0);
		SUM_MON_NSA			: in std_logic_vector(7 downto 0);
		SUM_MON_NSB			: in std_logic_vector(7 downto 0);

		SUM					: in std_logic_vector(31 downto 0);
		SUM_VALID			: in std_logic;

		SUM_HIST_ENABLE	: in std_logic;
		SUM_HIST_DATA		: out std_logic_vector(31 downto 0);
		SUM_HIST_RD			: in std_logic
	);
end sum_mon;

architecture Synthesis of sum_mon is
	signal CLEAR_CNT_DONE	: std_logic;
	signal CLEAR_CNT			: std_logic_vector(10 downto 0);
	signal CLEAR				: std_logic;
	signal PULSE_I				: std_logic_vector(31 downto 0) := (others=>'0');	
	signal SUM_WR_ADDR		: std_logic_vector(7 downto 0);
	signal SUM_RD_ADDR		: std_logic_vector(7 downto 0) := (others=>'0');
	signal SUM_RAM_IN			: std_logic_vector(31 downto 0);
	signal SUM_RAM_OUT		: std_logic_vector(31 downto 0);
	signal SYNC_Q				: std_logic;
	signal THR_WR_ADDR		: std_logic_vector(7 downto 0);
	signal THR_RAM_IN			: std_logic_vector(0 downto 0);
	signal THR_RAM_OUT		: std_logic_vector(0 downto 0);
	signal GATE					: std_logic;
	signal BIN					: std_logic_vector(4 downto 0);
begin

	CLEAR_CNT_DONE <= '1' when CLEAR_CNT = conv_std_logic_vector(2**CLEAR_CNT'length-1, CLEAR_CNT'length) else '0';

	process(CLK)
	begin
		if rising_edge(CLK) then
			if SUM_VALID = '0' then
				CLEAR_CNT <= (others=>'0');
			elsif CLEAR_CNT_DONE = '0' then
				CLEAR_CNT <= CLEAR_CNT + 1;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if SUM >= SUM_MON_THR then
				THR_RAM_IN <= "1";
			else
				THR_RAM_IN <= "0";
			end if;
		end if;
	end process;
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			if CLEAR = '1' then
				SUM_RAM_IN <= (others=>'0');
			else
				SUM_RAM_IN <= SUM;
			end if;
		end if;
	end process;
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			if CLEAR = '1' then
				PULSE_I <= (others=>'0');
			else
				PULSE_I <= PULSE_I + SUM_RAM_IN - SUM_RAM_OUT;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			SUM_WR_ADDR <= SUM_RD_ADDR + SUM_MON_NSA + SUM_MON_NSB - 1;
			THR_WR_ADDR <= SUM_RD_ADDR + SUM_MON_NSA - 2;
			SUM_RD_ADDR <= SUM_RD_ADDR + 1;			
			CLEAR <= not CLEAR_CNT_DONE;
		end if;
	end process;
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			GATE <= '0';
			BIN <= (others=>'0');
			for I in 0 to 31 loop
				if PULSE_I(I) = '1' then
					GATE <= THR_RAM_OUT(0);
					BIN <= conv_std_logic_vector(I, BIN'length);
				end if;
			end loop;
		end if;
	end process;

	sdp_ram_inst_sum: sdp_ram
		generic map(
			D_WIDTH		=> 32,
			A_WIDTH		=> 8,
			DOUT_REG		=> true
		)
		port map(
			WR_CLK	=> CLK,
			WR			=> '1',
			WR_ADDR	=> SUM_WR_ADDR,
			DIN		=> SUM_RAM_IN,
			RD_CLK	=> CLK,
			RD			=> '1',
			RD_ADDR	=> SUM_RD_ADDR,
			DOUT		=> SUM_RAM_OUT
		);

	sdp_ram_thr: sdp_ram
		generic map(
			D_WIDTH		=> 1,
			A_WIDTH		=> 8,
			DOUT_REG		=> true
		)
		port map(
			WR_CLK	=> CLK,
			WR			=> '1',
			WR_ADDR	=> THR_WR_ADDR,
			DIN		=> THR_RAM_IN,
			RD_CLK	=> CLK,
			RD			=> '1',
			RD_ADDR	=> SUM_RD_ADDR,
			DOUT		=> THR_RAM_OUT
		);

	hist_inst: hist
		generic map(
			BIN_DEPTH		=> 32,
			BIN_WIDTH		=> 5
		)
		port map(
			CLK				=> CLK,
			ENABLE			=> SUM_HIST_ENABLE,
			BIN_DATA			=> SUM_HIST_DATA,
			BIN_RD			=> SUM_HIST_RD,
			GATE				=> GATE,
			BIN				=> BIN
		);

end Synthesis;
