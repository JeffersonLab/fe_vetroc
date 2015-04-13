library ieee;
use ieee.std_logic_1164.all;

entity evtbuilderfull_sm is
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
end evtbuilderfull_sm;

architecture synthesis of evtbuilderfull_sm is
	type BUILDER_STATE_TYPE is (IDLE, WRITE_BLOCK_HEAER, WRITE_EVENT_HEADER, WRITE_TRIGGER_TIME_0, WRITE_TRIGGER_TIME_1,
	                            WRITE_EVENT_DATA, WRITE_FILLER, WRITE_BLOCK_TRAILER);
								
	signal BUILDER_STATE			: BUILDER_STATE_TYPE;
	signal BUILDER_STATE_NEXT	: BUILDER_STATE_TYPE;
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			if RESET = '1' then
				BUILDER_STATE <= IDLE;
			elsif FIFO_FULL = '0' then
				BUILDER_STATE <= BUILDER_STATE_NEXT;
			end if;
		end if;
	end process;

	process(BUILDER_STATE, TRIG_EN, BLOCK_HEADER_NEEDED, EVENT_DATA_DONE, BLOCK_TRAILER_NEEDED, FILLER_NEEDED)
	begin
		case BUILDER_STATE is
			when IDLE =>
				if TRIG_EN = '1' then
					if BLOCK_HEADER_NEEDED = '1' then
						BUILDER_STATE_NEXT <= WRITE_BLOCK_HEAER;
					else
						BUILDER_STATE_NEXT <= WRITE_EVENT_HEADER;
					end if;
				else
					BUILDER_STATE_NEXT <= IDLE;
				end if;
			
			when WRITE_BLOCK_HEAER =>
				BUILDER_STATE_NEXT <= WRITE_EVENT_HEADER;
			
			when WRITE_EVENT_HEADER =>
				BUILDER_STATE_NEXT <= WRITE_TRIGGER_TIME_0;
				
			when WRITE_TRIGGER_TIME_0 =>
				BUILDER_STATE_NEXT <= WRITE_TRIGGER_TIME_1;
			
			when WRITE_TRIGGER_TIME_1 =>
				BUILDER_STATE_NEXT <= WRITE_EVENT_DATA;

			when WRITE_EVENT_DATA =>
				if EVENT_DATA_DONE = '1' then
					if BLOCK_TRAILER_NEEDED = '1' then
						if FILLER_NEEDED = '1' then
							BUILDER_STATE_NEXT <= WRITE_FILLER;
						else
							BUILDER_STATE_NEXT <= WRITE_BLOCK_TRAILER;
						end if;
					else
						BUILDER_STATE_NEXT <= IDLE;
					end if;
				else
					BUILDER_STATE_NEXT <= WRITE_EVENT_DATA;
				end if;
				
			when WRITE_FILLER =>
				BUILDER_STATE_NEXT <= WRITE_BLOCK_TRAILER;
			
			when WRITE_BLOCK_TRAILER =>
				BUILDER_STATE_NEXT <= IDLE;
				
			when others =>
				BUILDER_STATE_NEXT <= IDLE;
		end case;
	end process;

	process(BUILDER_STATE, FIFO_FULL)
	begin
		case BUILDER_STATE is
			when IDLE =>
				DO_BLOCK_HEADER <= '0';
				DO_EVENT_HEADER <= '0';
				DO_TRIGGER_TIME0 <= '0';
				DO_TRIGGER_TIME1 <= '0';
				DO_EVENT_DATA <= '0';
				DO_FILLER <= '0';
				DO_BLOCK_TRAILER <= '0';
				DO_IDLE <= not FIFO_FULL;
			
			when WRITE_BLOCK_HEAER =>
				DO_BLOCK_HEADER <= not FIFO_FULL;
				DO_EVENT_HEADER <= '0';
				DO_TRIGGER_TIME0 <= '0';
				DO_TRIGGER_TIME1 <= '0';
				DO_EVENT_DATA <= '0';
				DO_FILLER <= '0';
				DO_BLOCK_TRAILER <= '0';
				DO_IDLE <= '0';
			
			when WRITE_EVENT_HEADER =>
				DO_BLOCK_HEADER <= '0';
				DO_EVENT_HEADER <= not FIFO_FULL;
				DO_TRIGGER_TIME0 <= '0';
				DO_TRIGGER_TIME1 <= '0';
				DO_EVENT_DATA <= '0';
				DO_FILLER <= '0';
				DO_BLOCK_TRAILER <= '0';
				DO_IDLE <= '0';
				
			when WRITE_TRIGGER_TIME_0 =>
				DO_BLOCK_HEADER <= '0';
				DO_EVENT_HEADER <= '0';
				DO_TRIGGER_TIME0 <= not FIFO_FULL;
				DO_TRIGGER_TIME1 <= '0';
				DO_EVENT_DATA <= '0';
				DO_FILLER <= '0';
				DO_BLOCK_TRAILER <= '0';
				DO_IDLE <= '0';
			
			when WRITE_TRIGGER_TIME_1 =>
				DO_BLOCK_HEADER <= '0';
				DO_EVENT_HEADER <= '0';
				DO_TRIGGER_TIME0 <= '0';
				DO_TRIGGER_TIME1 <= not FIFO_FULL;
				DO_EVENT_DATA <= '0';
				DO_FILLER <= '0';
				DO_BLOCK_TRAILER <= '0';
				DO_IDLE <= '0';
					
			when WRITE_EVENT_DATA =>
				DO_BLOCK_HEADER <= '0';
				DO_EVENT_HEADER <= '0';
				DO_TRIGGER_TIME0 <= '0';
				DO_TRIGGER_TIME1 <= '0';
				DO_EVENT_DATA <= not FIFO_FULL;
				DO_FILLER <= '0';
				DO_BLOCK_TRAILER <= '0';
				DO_IDLE <= '0';
				
			when WRITE_FILLER =>
				DO_BLOCK_HEADER <= '0';
				DO_EVENT_HEADER <= '0';
				DO_TRIGGER_TIME0 <= '0';
				DO_TRIGGER_TIME1 <= '0';
				DO_EVENT_DATA <= '0';
				DO_FILLER <= not FIFO_FULL;
				DO_BLOCK_TRAILER <= '0';
				DO_IDLE <= '0';
			
			when WRITE_BLOCK_TRAILER =>
				DO_BLOCK_HEADER <= '0';
				DO_EVENT_HEADER <= '0';
				DO_TRIGGER_TIME0 <= '0';
				DO_TRIGGER_TIME1 <= '0';
				DO_EVENT_DATA <= '0';
				DO_FILLER <= '0';
				DO_BLOCK_TRAILER <= not FIFO_FULL;
				DO_IDLE <= '0';
				
			when others =>
				DO_BLOCK_HEADER <= '0';
				DO_EVENT_HEADER <= '0';
				DO_TRIGGER_TIME0 <= '0';
				DO_TRIGGER_TIME1 <= '0';
				DO_EVENT_DATA <= '0';
				DO_FILLER <= '0';
				DO_BLOCK_TRAILER <= '0';
				DO_IDLE <= not FIFO_FULL;

		end case;
	end process;

end synthesis;
