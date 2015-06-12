library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

entity sd_mux is
	port(
		CLK					: in std_logic;

		TRIG1_SYNC			: in std_logic;
		TRIG2_SYNC			: in std_logic;
		SYNC_SYNC			: in std_logic;
		FP_IN_SYNC			: in std_logic_vector(3 downto 0);

		PULSER_OUTPUT		: in std_logic;
		FP_IN_ASYNC			: in std_logic_vector(3 downto 0);
		SYNC_ASYNC			: in std_logic;
		TRIG1_ASYNC			: in std_logic;
		TRIG2_ASYNC			: in std_logic;
		BUSY					: in std_logic;
		TRIG_IN				: in std_logic_vector(31 downto 0);
		
		FP_OUT_MUX			: out std_logic_vector(3 downto 0);

		SYNC					: out std_logic;
		TRIG					: out std_logic;
		
		FP_OUT_SRC			: in slv6a(3 downto 0);
		TRIG_SRC				: in std_logic_vector(5 downto 0);
		SYNC_SRC				: in std_logic_vector(5 downto 0)
	);
end sd_mux;

architecture Synthesis of sd_mux is
	signal MUX_SRC				: std_logic_vector(63 downto 0);
	signal MUX_SRC_SYNC		: std_logic_vector(63 downto 0);
	signal MUX_SRC_SYNC_Q0	: std_logic_vector(63 downto 0);
	signal MUX_SRC_SYNC_Q1	: std_logic_vector(63 downto 0);
begin

	-- Async Signal multiplexing
	MUX_SRC(0) <= '0';
	MUX_SRC(1) <= '1';
	MUX_SRC(2) <= SYNC_ASYNC;
	MUX_SRC(3) <= TRIG1_ASYNC;
	MUX_SRC(4) <= TRIG2_ASYNC;
	MUX_SRC(5) <= FP_IN_ASYNC(0);
	MUX_SRC(6) <= FP_IN_ASYNC(1);
	MUX_SRC(7) <= FP_IN_ASYNC(2);
	MUX_SRC(8) <= FP_IN_ASYNC(3);
	MUX_SRC(9) <= PULSER_OUTPUT;
	MUX_SRC(10) <= BUSY;
	MUX_SRC(31 downto 11) <= (others=>'0');
	MUX_SRC(63 downto 32) <= TRIG_IN;

	FP_OUT_MUX_gen: for I in 0 to 3 generate
		FP_OUT_MUX(I) <= MUX_SRC(conv_integer(FP_OUT_SRC(I)));
	end generate;

	-- Synchronous Signal multiplexing
	process(CLK)
	begin
		if rising_edge(CLK) then
			MUX_SRC_SYNC(0) <= '0';
			MUX_SRC_SYNC(1) <= '1';
			MUX_SRC_SYNC(2) <= SYNC_SYNC;
			MUX_SRC_SYNC(3) <= TRIG1_SYNC;
			MUX_SRC_SYNC(4) <= TRIG2_SYNC;
			MUX_SRC_SYNC(5) <= FP_IN_SYNC(0);
			MUX_SRC_SYNC(6) <= FP_IN_SYNC(1);
			MUX_SRC_SYNC(7) <= FP_IN_SYNC(2);
			MUX_SRC_SYNC(8) <= FP_IN_SYNC(3);
			MUX_SRC_SYNC(9) <= PULSER_OUTPUT;
			MUX_SRC_SYNC(10) <= BUSY;
			MUX_SRC_SYNC(63 downto 11) <= (others=>'0');

			SYNC <= MUX_SRC_SYNC(conv_integer(SYNC_SRC));
			TRIG <= MUX_SRC_SYNC(conv_integer(TRIG_SRC));
		end if;
	end process;

end Synthesis;
