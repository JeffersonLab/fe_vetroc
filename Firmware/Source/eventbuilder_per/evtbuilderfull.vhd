library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.eventbuilder_per_pkg.all;

entity evtbuilderfull is
	port(
		CLK						: in std_logic;
		RESET						: in std_logic;

		TRIG_FIFO_RD			: out std_logic;
		TRIG_FIFO_DATA			: in std_logic_vector(47 downto 0);
		TRIG_FIFO_EMPTY		: in std_logic;
		
		SLOTID					: in std_logic_vector(4 downto 0);
		BLOCK_SIZE				: in std_logic_vector(7 downto 0);
		
		USER_FIFO_DATA_1		: out std_logic_vector(35 downto 0);
		USER_FIFO_EMPTY_1		: out std_logic;
		USER_FIFO_RDREQ_1		: in std_logic;
		USER_FIFO_DATA_2		: out std_logic_vector(35 downto 0);
		USER_FIFO_EMPTY_2		: out std_logic;
		USER_FIFO_RDREQ_2		: in std_logic;
	
		BLD_DATA					: in std_logic_vector(31 downto 0);
		BLD_EVTEND				: in std_logic;
		BLD_EMPTY				: in std_logic;
		BLD_READ					: out std_logic;
		
		USER_INT					: out std_logic;
		USER_INT_ACKED			: in std_logic;
		USER_INT_ENABLED		: in std_logic;
 		USER_FIFO_WORD_CNT	: out std_logic_vector(31 downto 0); 
		USER_FIFO_EVENT_CNT	: out std_logic_vector(31 downto 0);
		USER_FIFO_BLOCK_CNT	: out std_logic_vector(31 downto 0);
		EVT_WORD_INT_LEVEL	: in std_logic_vector(15 downto 0); 
		EVT_NUM_INT_LEVEL		: in std_logic_vector(14 downto 0);
		
		SRAM_REF_CLK			: in std_logic;
		
		-- SRAM Debug Interface
		SRAM_DBG_WR				: in std_logic;
		SRAM_DBG_RD				: in std_logic;
		SRAM_DBG_ADDR			: in std_logic_vector(19 downto 0);
		SRAM_DBG_DIN			: in std_logic_vector(17 downto 0);
		SRAM_DBG_DOUT			: out std_logic_vector(17 downto 0);
		
		-- SRAM Phy Signals
		SRAM_CLK					: out std_logic;
		SRAM_CLK_O				: out std_logic;
		SRAM_CLK_I				: in std_logic;
		SRAM_D					: inout std_logic_vector(17 downto 0);
		SRAM_A					: out std_logic_vector(19 downto 0);
		SRAM_RW					: out std_logic;
		SRAM_NOE					: out std_logic;
		SRAM_CS					: out std_logic;
		SRAM_ADV					: out std_logic
	);
end EVTBuilderFull;

architecture Synthesis of EVTBuilderFull is
	component readout_fifo is
		port(
			rst		: in std_logic;
			wr_clk	: in std_logic;
			rd_clk	: in std_logic;
			din		: in std_logic_vector(35 downto 0);
			wr_en		: in std_logic;
			rd_en		: in std_logic;
			dout		: out std_logic_vector(71 downto 0);
			full		: out std_logic;
			empty		: out std_logic
		);
	end component;

	component sramfifo is
		port(
			CLK				: in std_logic;
			
			RESET				: in std_logic;
			
			FIFO_RD_CLK		: in std_logic;
			FIFO_WR_CLK		: in std_logic;
			FIFO_RD			: in std_logic;
			FIFO_WR			: in std_logic;
			FIFO_DIN			: in std_logic_vector(35 downto 0);
			FIFO_DOUT		: out std_logic_vector(35 downto 0);
			FIFO_EMPTY		: out std_logic;
			FIFO_FULL		: out std_logic;
			
			SRAM_DBG_WR		: in std_logic;
			SRAM_DBG_RD		: in std_logic;
			SRAM_DBG_ADDR	: in std_logic_vector(19 downto 0);
			SRAM_DBG_DIN	: in std_logic_vector(17 downto 0);
			SRAM_DBG_DOUT	: out std_logic_vector(17 downto 0);
			
			-- SRAM Phy Signals
			SRAM_CLK			: out std_logic;
			SRAM_CLK_O		: out std_logic;
			SRAM_CLK_I		: in std_logic;
			SRAM_D			: inout std_logic_vector(17 downto 0);
			SRAM_A			: out std_logic_vector(19 downto 0);
			SRAM_RW			: out std_logic;
			SRAM_NOE			: out std_logic;
			SRAM_CS			: out std_logic;
			SRAM_ADV			: out std_logic
		);
	end component;
	
	component evtbuilderfull_sm is
		port(
			CLK						: in std_logic;
			RESET						: in std_logic;
			
			TRIG_EN					: in std_logic;
			BLOCK_HEADER_NEEDED	: in std_logic;
			BLOCK_TRAILER_NEEDED	: in std_logic;
			FILLER_NEEDED			: in std_logic;
			EVENT_DATA_DONE		: in std_logic;
			FIFO_FULL				: in std_logic;
		
			DO_BLOCK_HEADER		: out std_logic;
			DO_EVENT_HEADER		: out std_logic;
			DO_TRIGGER_TIME0		: out std_logic;
			DO_TRIGGER_TIME1		: out std_logic;
			DO_EVENT_DATA			: out std_logic;
			DO_FILLER				: out std_logic;
			DO_BLOCK_TRAILER		: out std_logic;
			DO_IDLE					: out std_logic
		);
	end component;

	signal DO_BLOCK_HEADER				: std_logic;
	signal DO_EVENT_HEADER				: std_logic;
	signal DO_TRIGGER_TIME0				: std_logic;
	signal DO_TRIGGER_TIME1				: std_logic;
	signal DO_EVENT_DATA					: std_logic;
	signal DO_FILLER						: std_logic;
	signal DO_BLOCK_TRAILER				: std_logic;
	signal DO_IDLE							: std_logic;
	
	signal BLOCK_HEADER_NEEDED			: std_logic;
	signal BLOCK_TRAILER_NEEDED		: std_logic;
	signal FILLER_NEEDED					: std_logic;
	signal EVENT_DATA_WORD				: std_logic_vector(31 downto 0);
	signal EVENT_DATA_READ				: std_logic;
	
	signal FIFO_DIN						: std_logic_vector(35 downto 0);
	signal FIFO_DOUT						: std_logic_vector(71 downto 0);
	signal FIFO_WR							: std_logic;
	signal FIFO_RD							: std_logic;
	signal FIFO_FULL						: std_logic;
	signal FIFO_EMPTY						: std_logic;
	
	signal SRAMFIFO_DIN					: std_logic_vector(35 downto 0);
	signal SRAMFIFO_WR					: std_logic;
	signal SRAMFIFO_FULL					: std_logic;
	signal SRAMFIFO_RD					: std_logic;
	signal SRAMFIFO_DOUT					: std_logic_vector(35 downto 0);
	signal SRAMFIFO_EMPTY				: std_logic;
	
	signal BLOCK_CNT						: std_logic_vector(9 downto 0);
	signal EVENT_CNT						: std_logic_vector(21 downto 0);
	signal BLK_EVENT_CNT					: std_logic_vector(10 downto 0);
	signal WORD_CNT						: std_logic_vector(21 downto 0);
	signal WORD_CNT_INC					: std_logic;
	
	signal ALL_DATA_EVTEND				: std_logic;
	signal BLD_DATA_VALID				: std_logic;
	
	signal TRIG_EN							: std_logic;
	signal TRIG_TIME						: std_logic_vector(47 downto 0);
	signal USER_FIFO_BLOCK_CNT_i		: std_logic_vector(31 downto 0);
	signal USER_FIFO_EVENT_CNT_i		: std_logic_vector(31 downto 0);
	signal USER_FIFO_WORD_CNT_i		: std_logic_vector(31 downto 0);
	signal INT_ACK_WAIT					: std_logic;
	signal INT_REQ							: std_logic;
	signal FIFO_READ_EVT_HEADER_L		: std_logic;
	signal FIFO_READ_EVT_HEADER_H		: std_logic;
	signal FIFO_WRITE_EVT_HEADER		: std_logic;
	signal FIFO_READ_BLK_TRAILER_L	: std_logic;
	signal FIFO_READ_BLK_TRAILER_H	: std_logic;
	signal FIFO_WRITE_BLK_TRAILER		: std_logic;
begin

	USER_FIFO_WORD_CNT <= USER_FIFO_WORD_CNT_i;
	USER_FIFO_EVENT_CNT <= USER_FIFO_EVENT_CNT_i;
	USER_FIFO_BLOCK_CNT <= USER_FIFO_BLOCK_CNT_i;

	INT_REQ <= '1' when (USER_INT_ENABLED = '1') and ( (USER_FIFO_WORD_CNT_i >= (x"0000"&EVT_WORD_INT_LEVEL)) or (USER_FIFO_EVENT_CNT_i >= (x"0000"&"0"&EVT_NUM_INT_LEVEL)) ) else '0';

	process(CLK)
	begin
		if rising_edge(CLK) then
			if (INT_ACK_WAIT = '0') and (INT_REQ = '1') then
				USER_INT <= '1';
			else
				USER_INT <= '0';
			end if;
		end if;
	end process;
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			if (RESET = '1') or (USER_INT_ACKED = '1') then
				INT_ACK_WAIT <= '0';
			elsif INT_REQ = '1' then
				INT_ACK_WAIT <= '1';
			end if;
		end if;
	end process;

	FIFO_READ_BLK_TRAILER_L <= '1' when (FIFO_RD = '1') and (FIFO_DOUT(35 downto 32) = FIFO_TAG_BLKTLR) else '0';
	FIFO_READ_BLK_TRAILER_H <= '1' when (FIFO_RD = '1') and (FIFO_DOUT(71 downto 68) = FIFO_TAG_BLKTLR) else '0';
	FIFO_WRITE_BLK_TRAILER <= '1' when (FIFO_WR = '1') and (FIFO_DIN(35 downto 32) = FIFO_TAG_BLKTLR) else '0';

	process(CLK)
		variable pattern	: std_logic_vector(2 downto 0);
	begin
		if rising_edge(CLK) then
			pattern := FIFO_WRITE_BLK_TRAILER & FIFO_READ_BLK_TRAILER_H & FIFO_READ_BLK_TRAILER_L;
			
			if RESET = '1' then
				USER_FIFO_BLOCK_CNT_i <= (others=>'0');
			elsif pattern = "011" then 
				USER_FIFO_BLOCK_CNT_i <= USER_FIFO_BLOCK_CNT_i - 2;
			elsif pattern = "111" or pattern = "010" or pattern = "001" then
				USER_FIFO_BLOCK_CNT_i <= USER_FIFO_BLOCK_CNT_i - 1;
			elsif pattern = "100" then
				USER_FIFO_BLOCK_CNT_i <= USER_FIFO_BLOCK_CNT_i + 1;
			end if;
		end if;
	end process;

	FIFO_READ_EVT_HEADER_L <= '1' when (FIFO_RD = '1') and (FIFO_DOUT(35 downto 32) = FIFO_TAG_EVTHDR) else '0';
	FIFO_READ_EVT_HEADER_H <= '1' when (FIFO_RD = '1') and (FIFO_DOUT(71 downto 68) = FIFO_TAG_EVTHDR) else '0';
	FIFO_WRITE_EVT_HEADER <= '1' when (FIFO_WR = '1') and (FIFO_DIN(35 downto 32) = FIFO_TAG_EVTHDR) else '0';

	process(CLK)
		variable pattern	: std_logic_vector(2 downto 0);
	begin
		if rising_edge(CLK) then
			pattern := FIFO_WRITE_EVT_HEADER & FIFO_READ_EVT_HEADER_H & FIFO_READ_EVT_HEADER_L;
			
			if RESET = '1' then
				USER_FIFO_EVENT_CNT_i <= (others=>'0');
			elsif pattern = "011" then 
				USER_FIFO_EVENT_CNT_i <= USER_FIFO_EVENT_CNT_i - 2;
			elsif pattern = "111" or pattern = "010" or pattern = "001" then
				USER_FIFO_EVENT_CNT_i <= USER_FIFO_EVENT_CNT_i - 1;
			elsif pattern = "100" then
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
				USER_FIFO_WORD_CNT_i <= USER_FIFO_WORD_CNT_i - 2;
			elsif (FIFO_RD = '0') and (FIFO_WR = '1') then
				USER_FIFO_WORD_CNT_i <= USER_FIFO_WORD_CNT_i + 1;
			elsif (FIFO_RD = '1') and (FIFO_WR = '1') then
				USER_FIFO_WORD_CNT_i <= USER_FIFO_WORD_CNT_i - 1;
			end if;
		end if;
	end process;

	readout_fifo_inst: readout_fifo
		port map(
			rst		=> RESET,
			wr_clk	=> CLK,
			rd_clk	=> CLK,
			din		=> SRAMFIFO_DIN,
			wr_en		=> SRAMFIFO_WR,
			rd_en		=> FIFO_RD,
			dout		=> FIFO_DOUT,
			full		=> FIFO_FULL,
			empty		=> FIFO_EMPTY
		);

	SRAMFIFO_RD <= '1' when (SRAMFIFO_EMPTY = '0') and (FIFO_FULL = '0') else '0';
	sramfifo_inst: sramfifo
		port map(
			CLK				=> SRAM_REF_CLK,
			RESET				=> RESET,
			FIFO_RD_CLK		=> CLK,
			FIFO_WR_CLK		=> CLK,
			FIFO_RD			=> SRAMFIFO_RD,
			FIFO_WR			=> FIFO_WR,
			FIFO_DIN			=> FIFO_DIN,
			FIFO_DOUT		=> SRAMFIFO_DOUT,
			FIFO_EMPTY		=> SRAMFIFO_EMPTY,
			FIFO_FULL		=> SRAMFIFO_FULL,
			SRAM_DBG_WR		=> SRAM_DBG_WR,
			SRAM_DBG_RD		=> SRAM_DBG_RD,
			SRAM_DBG_ADDR	=> SRAM_DBG_ADDR,
			SRAM_DBG_DIN	=> SRAM_DBG_DIN,
			SRAM_DBG_DOUT	=> SRAM_DBG_DOUT,
			SRAM_CLK			=> SRAM_CLK,
			SRAM_CLK_O		=> SRAM_CLK_O,
			SRAM_CLK_I		=> SRAM_CLK_I,
			SRAM_D			=> SRAM_D,
			SRAM_A			=> SRAM_A,
			SRAM_RW			=> SRAM_RW,
			SRAM_NOE			=> SRAM_NOE,
			SRAM_CS			=> SRAM_CS,
			SRAM_ADV			=> SRAM_ADV
		);
		
	TRIG_FIFO_RD <= TRIG_EN;
	TRIG_EN <= DO_IDLE and not TRIG_FIFO_EMPTY;
	TRIG_TIME <= TRIG_FIFO_DATA(47 downto 0);

	FIFO_RD <= USER_FIFO_RDREQ_2;	--USER_FIFO_RDREQ_1
	USER_FIFO_EMPTY_1 <= FIFO_EMPTY;
	USER_FIFO_EMPTY_2 <= FIFO_EMPTY;
	USER_FIFO_DATA_1 <= FIFO_DOUT(71 downto 36);
	USER_FIFO_DATA_2 <= FIFO_DOUT(35 downto 0);
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			if RESET = '1' then
				BLOCK_CNT <= conv_std_logic_vector(1, BLOCK_CNT'length);
			elsif DO_BLOCK_HEADER = '1' then
				BLOCK_CNT <= BLOCK_CNT + 1;
			end if;
		end if;
	end process;
	
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

	process(CLK)
	begin
		if rising_edge(CLK) then
			if (RESET = '1') or (DO_BLOCK_TRAILER = '1') then
				BLK_EVENT_CNT <= (others=>'0');
			elsif DO_EVENT_HEADER = '1' then
				BLK_EVENT_CNT <= BLK_EVENT_CNT + 1;
			end if;
		end if;
	end process;
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			if (RESET = '1') or (DO_BLOCK_TRAILER = '1') then
				WORD_CNT <= conv_std_logic_vector(1, WORD_CNT'length);
			elsif WORD_CNT_INC = '1' then
				WORD_CNT <= WORD_CNT + 1;
			end if;
		end if;
	end process;

	WORD_CNT_INC <= FIFO_WR;
	
	BLOCK_HEADER_NEEDED <= '1' when BLK_EVENT_CNT = conv_std_logic_vector(0, BLK_EVENT_CNT'length) else '0';
	BLOCK_TRAILER_NEEDED <= '1' when BLK_EVENT_CNT = BLOCK_SIZE else '0';
	
	FILLER_NEEDED <= WORD_CNT(0);

	BLD_DATA_VALID <= (not BLD_EMPTY) and (not BLD_EVTEND);
	ALL_DATA_EVTEND <= BLD_EVTEND and not BLD_EMPTY;
	
	EVENT_DATA_READ <= BLD_DATA_VALID and DO_EVENT_DATA;
	EVENT_DATA_WORD <= BLD_DATA;	
	BLD_READ <= ALL_DATA_EVTEND or EVENT_DATA_READ;  
	
	FIFO_WR <= DO_BLOCK_HEADER or DO_EVENT_HEADER or DO_TRIGGER_TIME0 or DO_TRIGGER_TIME1 or DO_FILLER or DO_BLOCK_TRAILER or EVENT_DATA_READ;
	FIFO_DIN <= FIFO_TAG_BLKHDR & '1' & DATA_TYPE_BLKHDR &          SLOTID & "0000" & BLOCK_CNT & BLOCK_SIZE when DO_BLOCK_HEADER = '1' else
	            FIFO_TAG_EVTHDR & '1' & DATA_TYPE_EVTHDR &          SLOTID &                       EVENT_CNT when DO_EVENT_HEADER = '1' else
	            FIFO_TAG_OTHER  & '1' & DATA_TYPE_TRGTIME &                  "000" & TRIG_TIME(23 downto 0) when DO_TRIGGER_TIME0 = '1' else
	            FIFO_TAG_OTHER  & '0' &                            "0000" & "000" & TRIG_TIME(47 downto 24) when DO_TRIGGER_TIME1 = '1' else
	            FIFO_TAG_OTHER  &                                                           EVENT_DATA_WORD when DO_EVENT_DATA = '1' else
	            FIFO_TAG_OTHER  & '1' & DATA_TYPE_FILLER &                    "000000000000000000000000000" when DO_FILLER = '1' else
	            FIFO_TAG_BLKTLR & '1' & DATA_TYPE_BLKTLR &                                SLOTID & WORD_CNT when DO_BLOCK_TRAILER = '1' else
	            FIFO_TAG_OTHER  & '1' & DATA_TYPE_DNV &                       "000000000000000000000000000";

	evtbuilderfull_sm_inst: evtbuilderfull_sm
		port map(
			CLK						=> CLK,
			RESET						=> RESET,
			TRIG_EN					=> TRIG_EN,
			BLOCK_HEADER_NEEDED	=> BLOCK_HEADER_NEEDED,
			BLOCK_TRAILER_NEEDED	=> BLOCK_TRAILER_NEEDED,
			FILLER_NEEDED			=> FILLER_NEEDED,
			EVENT_DATA_DONE		=> ALL_DATA_EVTEND,
			FIFO_FULL				=> SRAMFIFO_FULL,
			DO_BLOCK_HEADER		=> DO_BLOCK_HEADER,
			DO_EVENT_HEADER		=> DO_EVENT_HEADER,
			DO_TRIGGER_TIME0		=> DO_TRIGGER_TIME0,
			DO_TRIGGER_TIME1		=> DO_TRIGGER_TIME1,
			DO_EVENT_DATA			=> DO_EVENT_DATA,
			DO_FILLER				=> DO_FILLER,
			DO_BLOCK_TRAILER		=> DO_BLOCK_TRAILER,
			DO_IDLE					=> DO_IDLE
		);

end Synthesis;
