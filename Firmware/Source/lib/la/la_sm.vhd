library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

entity la_sm is
	port(
		CLK				: in std_logic;
		TRIGGER			: in std_logic;
		LA_ENABLE		: in std_logic;
		LA_READY			: out std_logic
	);
end la_sm;

architecture synthesis of la_sm is
	type LA_STATE_TYPE is (IDLE, DONE, POSTFILL, WAITTRIG);
	
	signal LA_STATE			: LA_STATE_TYPE;
	signal LA_STATE_NEXT		: LA_STATE_TYPE;
	signal LA_POSTFILLED		: std_logic;
	signal LA_PREFILLED		: std_logic;
	signal LA_TRIGWAIT		: std_logic;
	signal LA_SAMPLES			: std_logic_vector(8 downto 0);
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			if LA_ENABLE = '0' then
				LA_SAMPLES <= (others=>'0');
			elsif (LA_TRIGWAIT = '1' and LA_PREFILLED = '0') or (LA_TRIGWAIT = '0' and LA_POSTFILLED = '0') then
				LA_SAMPLES <= LA_SAMPLES + 1;
			end if;
		end if;
	end process;

	LA_PREFILLED <= '1' when LA_SAMPLES >= "100000100" else '0';
	LA_POSTFILLED <= '1' when LA_SAMPLES >= "111111111" else '0';

	process(CLK)
	begin
		if rising_edge(CLK) then
			if LA_ENABLE = '0' then
				LA_STATE <= IDLE;
			else
				LA_STATE <= LA_STATE_NEXT;
			end if;
		end if;
	end process;
	
	process(LA_STATE, LA_POSTFILLED, LA_PREFILLED, TRIGGER)
	begin
		case LA_STATE is
			when IDLE =>
				LA_STATE_NEXT <= WAITTRIG;
			when WAITTRIG =>
				if (TRIGGER = '1') and (LA_PREFILLED = '1') then
					LA_STATE_NEXT <= POSTFILL;
				else
					LA_STATE_NEXT <= WAITTRIG;
				end if;
				
			when POSTFILL =>
				if LA_POSTFILLED = '1' then
					LA_STATE_NEXT <= DONE;
				else
					LA_STATE_NEXT <= POSTFILL;
				end if;
	
			when others =>	--when DONE =>
				LA_STATE_NEXT <= DONE;
		end case;
	end process;
	
	process(LA_STATE)
	begin
		case LA_STATE is
			when IDLE =>
				LA_READY <= '1';
				LA_TRIGWAIT <= '0';
			when WAITTRIG =>
				LA_READY <= '0';
				LA_TRIGWAIT <= '1';
			when POSTFILL =>
				LA_READY <= '0';
				LA_TRIGWAIT <= '0';
			when others =>	--when DONE =>
				LA_READY <= '1';
				LA_TRIGWAIT <= '0';
		end case;
	end process;

end synthesis;
