library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library utils;
use utils.utils_pkg.all;

entity sd_mux is
	port(
		CLK					: in std_logic;

		FPGAIN_SYNC			: in std_logic_vector(8 downto 1);
		TOKENFI_SYNC		: in std_logic;
		SYNCFI_SYNC			: in std_logic;
		TRIG1F_SYNC			: in std_logic;
		TRIG2F_SYNC			: in std_logic;
		STATA_IN_SYNC		: in std_logic;
		STATB_IN_SYNC		: in std_logic;

		FPGAIN_ASYNC		: in std_logic_vector(8 downto 1);
		TOKENFI_ASYNC		: in std_logic;
		SYNCFI_ASYNC		: in std_logic;
		TRIG1F_ASYNC		: in std_logic;
		TRIG2F_ASYNC		: in std_logic;
		STATA_IN_ASYNC		: in std_logic;
		STATB_IN_ASYNC		: in std_logic;

		PULSER_OUTPUT		: in std_logic;
		BUSY					: in std_logic;
	
		FPGAOUT_MUX			: out std_logic_vector(8 downto 1);
		TOKENFO_MUX			: out std_logic;
		TRIGFO_MUX			: out std_logic;
		SDLINKF_MUX			: out std_logic;
		STATA_OUT_MUX		: out std_logic;
		BUSY_OUT_MUX		: out std_logic;

		SYNC					: out std_logic;
		TRIG					: out std_logic;
		
		FPGAOUT_SRC			: in slv5a(8 downto 1);
		TOKENFO_SRC			: in std_logic_vector(4 downto 0);
		TRIGFO_SRC			: in std_logic_vector(4 downto 0);
		SDLINKF_SRC			: in std_logic_vector(4 downto 0);
		STATA_OUT_SRC		: in std_logic_vector(4 downto 0);
		BUSY_OUT_SRC		: in std_logic_vector(4 downto 0);
		TRIG_SRC				: in std_logic_vector(4 downto 0);
		SYNC_SRC				: in std_logic_vector(4 downto 0)
	);
end sd_mux;

architecture synthesis of sd_mux is
	signal MUX_SRC				: std_logic_vector(31 downto 0);
	signal MUX_SRC_SYNC		: std_logic_vector(31 downto 0);
begin

	-- Async Signal multiplexing
	MUX_SRC(0) <= '0';
	MUX_SRC(1) <= '1';
	MUX_SRC(2) <= FPGAIN_ASYNC(1);
	MUX_SRC(3) <= FPGAIN_ASYNC(2);
	MUX_SRC(4) <= FPGAIN_ASYNC(3);
	MUX_SRC(5) <= FPGAIN_ASYNC(4);
	MUX_SRC(6) <= FPGAIN_ASYNC(5);
	MUX_SRC(7) <= FPGAIN_ASYNC(6);
	MUX_SRC(8) <= FPGAIN_ASYNC(7);
	MUX_SRC(9) <= FPGAIN_ASYNC(8);
	MUX_SRC(10) <= TOKENFI_ASYNC;
	MUX_SRC(11) <= SYNCFI_ASYNC;
	MUX_SRC(12) <= TRIG1F_ASYNC;
	MUX_SRC(13) <= TRIG2F_ASYNC;
	MUX_SRC(14) <= STATA_IN_ASYNC;
	MUX_SRC(15) <= STATB_IN_ASYNC;
	MUX_SRC(16) <= '0';
	MUX_SRC(17) <= '0';
	MUX_SRC(18) <= PULSER_OUTPUT;
	MUX_SRC(19) <= BUSY;
	MUX_SRC(31 downto 20) <= (others=>'0');

	FPGAOUT_MUX_gen: for I in FPGAOUT_MUX'range generate
		FPGAOUT_MUX(I) <= MUX_SRC(conv_integer(FPGAOUT_SRC(I)));
	end generate;

	TOKENFO_MUX <= MUX_SRC(conv_integer(TOKENFO_SRC));
	TRIGFO_MUX <= MUX_SRC(conv_integer(TRIGFO_SRC));
	SDLINKF_MUX <= MUX_SRC(conv_integer(SDLINKF_SRC));
	STATA_OUT_MUX <= MUX_SRC(conv_integer(STATA_OUT_SRC));
	BUSY_OUT_MUX <= MUX_SRC(conv_integer(BUSY_OUT_SRC));

	-- Sync Signal multiplexing
	process(CLK)
	begin
		if rising_edge(CLK) then
			MUX_SRC_SYNC(0) <= '0';
			MUX_SRC_SYNC(1) <= '1';
			MUX_SRC_SYNC(2) <= FPGAIN_SYNC(1);
			MUX_SRC_SYNC(3) <= FPGAIN_SYNC(2);
			MUX_SRC_SYNC(4) <= FPGAIN_SYNC(3);
			MUX_SRC_SYNC(5) <= FPGAIN_SYNC(4);
			MUX_SRC_SYNC(6) <= FPGAIN_SYNC(5);
			MUX_SRC_SYNC(7) <= FPGAIN_SYNC(6);
			MUX_SRC_SYNC(8) <= FPGAIN_SYNC(7);
			MUX_SRC_SYNC(9) <= FPGAIN_SYNC(8);
			MUX_SRC_SYNC(10) <= TOKENFI_SYNC;
			MUX_SRC_SYNC(11) <= SYNCFI_SYNC;
			MUX_SRC_SYNC(12) <= TRIG1F_SYNC;
			MUX_SRC_SYNC(13) <= TRIG2F_SYNC;
			MUX_SRC_SYNC(14) <= STATA_IN_SYNC;
			MUX_SRC_SYNC(15) <= STATB_IN_SYNC;
			MUX_SRC_SYNC(16) <= '0';
			MUX_SRC_SYNC(17) <= '0';
			MUX_SRC_SYNC(18) <= PULSER_OUTPUT;
			MUX_SRC_SYNC(19) <= BUSY;
			MUX_SRC_SYNC(31 downto 20) <= (others=>'0');

			SYNC <= MUX_SRC_SYNC(conv_integer(SYNC_SRC));
			TRIG <= MUX_SRC_SYNC(conv_integer(TRIG_SRC));
		end if;
	end process;

end synthesis;
