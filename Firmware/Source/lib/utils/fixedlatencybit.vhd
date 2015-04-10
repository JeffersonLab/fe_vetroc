library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity fixedlatencybit is
	port(
			CLK			: in std_logic;
			SYNC			: in std_logic;
			
			LATENCY		: in std_logic_vector(11 downto 0);

			BIT_IN_EN	: in std_logic;
			BIT_IN		: in std_logic;

			BIT_OUT		: out std_logic;
			BIT_OUT_ERR	: out std_logic
	);
end fixedlatencybit;

architecture synthesis of fixedlatencybit is
	signal DELAY_CNT			: std_logic_vector(11 downto 0);
	signal DELAY_CNT_DONE	: std_logic;
	signal Q						: std_logic;
	signal RDREQ				: std_logic;
	signal EMPTY				: std_logic;
	signal FULL					: std_logic;
	signal SYNC_Q				: std_logic;
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			SYNC_Q <= SYNC;
		end if;
	end process;

	DELAY_CNT_DONE <= '1' when DELAY_CNT >= LATENCY else '0';

	process(CLK)
	begin
		if rising_edge(CLK) then
			if SYNC_Q = '1' then
				DELAY_CNT <= (others=>'0');
			elsif DELAY_CNT_DONE = '0' then
				DELAY_CNT <= DELAY_CNT + 1;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if SYNC_Q = '1' then
				BIT_OUT_ERR <= '0';
			elsif (FULL = '1') or ((DELAY_CNT_DONE = '1') and (EMPTY = '1')) then
				BIT_OUT_ERR <= '1';
			end if;
		end if;
	end process;

	RDREQ <= '1' when (DELAY_CNT_DONE = '1') and (EMPTY = '0') else '0';

	process(CLK)
	begin
		if rising_edge(CLK) then
			if RDREQ = '1' then
				BIT_OUT <= Q;
			else
				BIT_OUT <= '0';
			end if;
		end if;
	end process;

	scfifo_inst: scfifo
		generic map(
			add_ram_output_register	=> "OFF",
			intended_device_family	=> "Stratix IV",
			lpm_numwords			=> 2048,
			lpm_showahead			=> "ON",
			lpm_type					=> "scfifo",
			lpm_width				=> 1,
			lpm_widthu				=> 11,
			overflow_checking		=> "ON",
			underflow_checking	=> "ON",
			use_eab					=> "ON"
		)
		port map(
			clock		=> CLK,
			sclr		=> SYNC_Q,
			wrreq		=> BIT_IN_EN,
			data(0)	=> BIT_IN,
			rdreq		=> RDREQ,
			usedw		=> open,
			empty		=> EMPTY,
			full		=> FULL,
			q(0)		=> Q
		);
	
end synthesis;
