library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

use work.eventbuilder_per_pkg.all;

entity evtbuilderfull is
	port(
		CLK						: in std_logic;
		RESET						: in std_logic;

		TRIG_FIFO_RD			: out std_logic;
		TRIG_FIFO_DATA			: in std_logic_vector(47 downto 0);
		TRIG_FIFO_EMPTY		: in std_logic;
		
		DEVICEID					: in std_logic_vector(4 downto 0);
		BLOCK_SIZE				: in std_logic_vector(7 downto 0);
		
		USER_FIFO_DATA			: out std_logic_vector(35 downto 0);
		USER_FIFO_EMPTY		: out std_logic;
		USER_FIFO_RDREQ		: in std_logic;
	
		BLD_DATA					: in std_logic_vector(31 downto 0);
		BLD_EVTEND				: in std_logic;
		BLD_EMPTY				: in std_logic;
		BLD_READ					: out std_logic;
		
 		USER_FIFO_WORD_CNT	: out std_logic_vector(31 downto 0); 
		USER_FIFO_EVENT_CNT	: out std_logic_vector(31 downto 0)
	);
end evtbuilderfull;

architecture synthesis of evtbuilderfull is
	component evtbuilderfull_sm is
		port(
			CLK						: in std_logic;
			RESET						: in std_logic;
			
			TRIG_EN					: in std_logic;
			EVENT_DATA_DONE		: in std_logic;
			FIFO_FULL				: in std_logic;
		
			DO_EVENT_HEADER		: out std_logic;
			DO_TRIGGER_TIME0		: out std_logic;
			DO_TRIGGER_TIME1		: out std_logic;
			DO_EVENT_DATA			: out std_logic;
			DO_IDLE					: out std_logic
		);
	end component;

	signal DO_EVENT_HEADER				: std_logic;
	signal DO_TRIGGER_TIME0				: std_logic;
	signal DO_TRIGGER_TIME1				: std_logic;
	signal DO_EVENT_DATA					: std_logic;
	signal DO_IDLE							: std_logic;
	
	signal EVENT_DATA_WORD				: std_logic_vector(31 downto 0);
	signal EVENT_DATA_READ				: std_logic;
	
	signal FIFO_DIN						: std_logic_vector(35 downto 0);
	signal FIFO_DOUT						: std_logic_vector(35 downto 0);
	signal FIFO_WR							: std_logic;
	signal FIFO_RD							: std_logic;
	signal FIFO_FULL						: std_logic;
	signal FIFO_EMPTY						: std_logic;
	
	signal EVENT_CNT						: std_logic_vector(21 downto 0);
	
	signal ALL_DATA_EVTEND				: std_logic;
	signal BLD_DATA_VALID				: std_logic;

	signal TRIG_EN							: std_logic;
	signal TRIG_TIME						: std_logic_vector(47 downto 0);
	signal USER_FIFO_EVENT_CNT_i		: std_logic_vector(31 downto 0);
	signal USER_FIFO_WORD_CNT_i		: std_logic_vector(31 downto 0);
	signal FIFO_READ_EVT_HEADER		: std_logic;
	signal FIFO_WRITE_EVT_HEADER		: std_logic;
begin

	USER_FIFO_WORD_CNT <= USER_FIFO_WORD_CNT_i;
	USER_FIFO_EVENT_CNT <= USER_FIFO_EVENT_CNT_i;

	FIFO_READ_EVT_HEADER <= '1' when (FIFO_RD = '1') and (FIFO_DOUT(35 downto 32) = FIFO_TAG_EVTHDR) else '0';
	FIFO_WRITE_EVT_HEADER <= '1' when (FIFO_WR = '1') and (FIFO_DIN(35 downto 32) = FIFO_TAG_EVTHDR) else '0';

	process(CLK)
		variable pattern	: std_logic_vector(1 downto 0);
	begin
		if rising_edge(CLK) then
			pattern := FIFO_WRITE_EVT_HEADER & FIFO_READ_EVT_HEADER;
			
			if RESET = '1' then
				USER_FIFO_EVENT_CNT_i <= (others=>'0');
			elsif pattern = "01" then
				USER_FIFO_EVENT_CNT_i <= USER_FIFO_EVENT_CNT_i - 1;
			elsif pattern = "10" then
				USER_FIFO_EVENT_CNT_i <= USER_FIFO_EVENT_CNT_i + 1;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if RESET = '1' then
				USER_FIFO_WORD_CNT_i <= (others=>'0');
			elsif (FIFO_RD = '1') and (FIFO_WR = '0') then
				USER_FIFO_WORD_CNT_i <= USER_FIFO_WORD_CNT_i - 1;
			elsif (FIFO_RD = '0') and (FIFO_WR = '1') then
				USER_FIFO_WORD_CNT_i <= USER_FIFO_WORD_CNT_i + 1;
			end if;
		end if;
	end process;

	scfifo_generic_inst: scfifo_generic
		generic map(
			D_WIDTH	=> 36,
			A_WIDTH	=> 14,
			DOUT_REG	=> true,
			FWFT		=> true
		)
		port map(
			CLK		=> CLK,
			RST		=> RESET,
			DIN		=> FIFO_DIN,
			WR			=> FIFO_WR,
			FULL		=> FIFO_FULL,
			DOUT		=> FIFO_DOUT,
			RD			=> FIFO_RD,
			EMPTY		=> FIFO_EMPTY
		);

	TRIG_FIFO_RD <= TRIG_EN;
	TRIG_EN <= DO_IDLE and not TRIG_FIFO_EMPTY;
	TRIG_TIME <= TRIG_FIFO_DATA(47 downto 0);

	FIFO_RD <= USER_FIFO_RDREQ;
	USER_FIFO_EMPTY <= FIFO_EMPTY;
	USER_FIFO_DATA <= FIFO_DOUT;
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			if RESET = '1' then
				EVENT_CNT <= conv_std_logic_vector(1, EVENT_CNT'length);
			elsif DO_EVENT_HEADER = '1' then
				EVENT_CNT <= EVENT_CNT + 1;
			end if;
		end if;
	end process;
	
	BLD_DATA_VALID <= (not BLD_EMPTY) and (not BLD_EVTEND);
	ALL_DATA_EVTEND <= BLD_EVTEND and not BLD_EMPTY;
	
	EVENT_DATA_READ <= BLD_DATA_VALID and DO_EVENT_DATA;
	EVENT_DATA_WORD <= BLD_DATA;	
	BLD_READ <= ALL_DATA_EVTEND or EVENT_DATA_READ;  
	
	FIFO_WR <= DO_EVENT_HEADER or DO_TRIGGER_TIME0 or DO_TRIGGER_TIME1 or EVENT_DATA_READ;
	FIFO_DIN <= FIFO_TAG_EVTHDR & '1' & DATA_TYPE_EVTHDR &       DEVICEID &                       EVENT_CNT when DO_EVENT_HEADER = '1' else
	            FIFO_TAG_OTHER  & '1' & DATA_TYPE_TRGTIME &                  "000" & TRIG_TIME(23 downto 0) when DO_TRIGGER_TIME0 = '1' else
	            FIFO_TAG_OTHER  & '0' &                            "0000" & "000" & TRIG_TIME(47 downto 24) when DO_TRIGGER_TIME1 = '1' else
	            FIFO_TAG_OTHER  &                                                           EVENT_DATA_WORD when DO_EVENT_DATA = '1' else
	            FIFO_TAG_OTHER  & '1' & DATA_TYPE_DNV &                       "000000000000000000000000000";

	evtbuilderfull_sm_inst: evtbuilderfull_sm
		port map(
			CLK						=> CLK,
			RESET						=> RESET,
			TRIG_EN					=> TRIG_EN,
			EVENT_DATA_DONE		=> ALL_DATA_EVTEND,
			FIFO_FULL				=> FIFO_FULL,
			DO_EVENT_HEADER		=> DO_EVENT_HEADER,
			DO_TRIGGER_TIME0		=> DO_TRIGGER_TIME0,
			DO_TRIGGER_TIME1		=> DO_TRIGGER_TIME1,
			DO_EVENT_DATA			=> DO_EVENT_DATA,
			DO_IDLE					=> DO_IDLE
		);

end Synthesis;
