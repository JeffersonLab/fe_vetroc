library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity perbus_mst_sm is
	port(
		CLK			: in std_logic;
		RESET			: in std_logic;
		
		WRITE_SIG	: in std_logic;
		READ_SIG		: in std_logic;
		BUS_ACK		: in std_logic;

		BUS_DIN_EN	: out std_logic;
		BUS_DOUT_EN	: out std_logic;
		BUS_WR		: out std_logic;
		BUS_RD		: out std_logic;
		BUSY			: out std_logic
	);
end perbus_mst_sm;

architecture synthesis of perbus_mst_sm is
	type BUS_STATE_TYPE is (
			INIT, IDLE, 
			ADR_SETUP_WAIT, WAIT_RD_ACK, RD_SETUP_WAIT, RD_CAPTURE, WAIT_RD_ACK_RELEASE, 
			WR_CAPTURE, WR_SETUP_WAIT, WAIT_WR_ACK, WAIT_WR_ACK_RELEASE
		);

	constant ADR_SETUP_CNT	: std_logic_vector(7 downto 0) := "00001000";
	constant RD_SETUP_CNT	: std_logic_vector(7 downto 0) := "00001000";
	constant WR_SETUP_CNT	: std_logic_vector(7 downto 0) := "00001000";
	constant TIMEOUT_CNT		: std_logic_vector(7 downto 0) := "11111111";

	signal CNT					: std_logic_vector(7 downto 0);
	signal ADR_SETUP_DONE	: std_logic;
	signal RD_SETUP_DONE		: std_logic;
	signal TIMEOUTOUT_DONE	: std_logic;
	signal WR_SETUP_DONE		: std_logic;
	signal BUS_STATE			: BUS_STATE_TYPE := INIT;
	signal BUS_STATE_NEXT	: BUS_STATE_TYPE;
	signal BUS_RD_D			: std_logic;
	signal BUS_WR_D			: std_logic;
	signal BUS_ACK_Q			: std_logic_vector(1 downto 0);
begin

	ADR_SETUP_DONE <= '1' when CNT = ADR_SETUP_CNT else '0';
	RD_SETUP_DONE <= '1' when CNT = RD_SETUP_CNT else '0';
	WR_SETUP_DONE <= '1' when CNT = WR_SETUP_CNT else '0';
	TIMEOUTOUT_DONE <= '1' when CNT = TIMEOUT_CNT else '0';
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			if BUS_STATE /= BUS_STATE_NEXT then
				CNT <= (others=>'0');
			else
				CNT <= CNT + 1;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if RESET = '1' then
				BUS_STATE <= INIT;
			else
				BUS_STATE <= BUS_STATE_NEXT;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			BUS_RD <= BUS_RD_D;
			BUS_WR <= BUS_WR_D;
			BUS_ACK_Q <= BUS_ACK_Q(0) & BUS_ACK;
		end if;
	end process;

	process(BUS_STATE, WRITE_SIG, READ_SIG, ADR_SETUP_DONE, RD_SETUP_DONE, WR_SETUP_DONE, BUS_ACK_Q, TIMEOUTOUT_DONE)
	begin
		case BUS_STATE is
			when INIT =>
				if (WRITE_SIG = '0') and (READ_SIG = '0') then
					BUS_STATE_NEXT <= IDLE;
				else
					BUS_STATE_NEXT <= INIT;
				end if;

			when IDLE =>
				if WRITE_SIG = '1' then
					BUS_STATE_NEXT <= WR_CAPTURE;
				elsif READ_SIG = '1' then
					BUS_STATE_NEXT <= ADR_SETUP_WAIT;
				else
					BUS_STATE_NEXT <= IDLE;
				end if;

			------------------------------
			-- Read cycle
			------------------------------
			when ADR_SETUP_WAIT =>
				if READ_SIG = '0' then
					BUS_STATE_NEXT <= INIT;
				elsif ADR_SETUP_DONE = '1' then
					BUS_STATE_NEXT <= WAIT_RD_ACK;
				else
					BUS_STATE_NEXT <= ADR_SETUP_WAIT;
				end if;

			when WAIT_RD_ACK =>
				if (READ_SIG = '0') then
					BUS_STATE_NEXT <= INIT;
				elsif (BUS_ACK_Q(1) = '1') or (TIMEOUTOUT_DONE = '1') then
					BUS_STATE_NEXT <= RD_SETUP_WAIT;
				else
					BUS_STATE_NEXT <= WAIT_RD_ACK;
				end if;

			when RD_SETUP_WAIT =>
				if READ_SIG = '0' then
					BUS_STATE_NEXT <= INIT;
				elsif RD_SETUP_DONE = '1' then
					BUS_STATE_NEXT <= RD_CAPTURE;
				else
					BUS_STATE_NEXT <= RD_SETUP_WAIT;
				end if;

			when RD_CAPTURE =>
				if READ_SIG = '0' then
					BUS_STATE_NEXT <= INIT;
				else
					BUS_STATE_NEXT <= WAIT_RD_ACK_RELEASE;
				end if;

			when WAIT_RD_ACK_RELEASE =>
				if READ_SIG = '0' then
					BUS_STATE_NEXT <= INIT;
				elsif BUS_ACK_Q(1) = '0' then
					BUS_STATE_NEXT <= INIT;
				else
					BUS_STATE_NEXT <= WAIT_RD_ACK_RELEASE;
				end if;

			------------------------------
			-- Write cycle
			------------------------------
			when WR_CAPTURE =>
				if WRITE_SIG = '0' then
					BUS_STATE_NEXT <= INIT;
				else
					BUS_STATE_NEXT <= WR_SETUP_WAIT;
				end if;

			when WR_SETUP_WAIT =>
				if WRITE_SIG = '0' then
					BUS_STATE_NEXT <= INIT;
				elsif WR_SETUP_DONE = '1' then
					BUS_STATE_NEXT <= WAIT_WR_ACK;
				else
					BUS_STATE_NEXT <= WR_SETUP_WAIT;
				end if;

			when WAIT_WR_ACK =>
				if WRITE_SIG = '0' then
					BUS_STATE_NEXT <= INIT;
				elsif (BUS_ACK_Q(1) = '1') or (TIMEOUTOUT_DONE = '1') then
					BUS_STATE_NEXT <= WAIT_WR_ACK_RELEASE;
				else
					BUS_STATE_NEXT <= WAIT_WR_ACK;
				end if;

			when WAIT_WR_ACK_RELEASE =>
				if WRITE_SIG = '0' then
					BUS_STATE_NEXT <= INIT;
				elsif BUS_ACK_Q(1) = '0' then
					BUS_STATE_NEXT <= INIT;
				else
					BUS_STATE_NEXT <= WAIT_WR_ACK_RELEASE;
				end if;

			when others =>
				BUS_STATE_NEXT <= INIT;
		end case;
	end process;
	
	process(BUS_STATE, WRITE_SIG, READ_SIG)
	begin
		case BUS_STATE is
			when INIT =>
				BUS_DIN_EN <= '0';
				BUS_DOUT_EN <= '0';
				BUS_WR_D <= '0';
				BUS_RD_D <= '0';
				BUSY <= '0';

			when IDLE =>
				BUS_DIN_EN <= '0';
				BUS_DOUT_EN <= '0';
				BUS_WR_D <= '0';
				BUS_RD_D <= '0';
				BUSY <= WRITE_SIG or READ_SIG;

			when WAIT_RD_ACK =>
				BUS_DIN_EN <= '0';
				BUS_DOUT_EN <= '0';
				BUS_WR_D <= '0';
				BUS_RD_D <= '1';
				BUSY <= '1';

			when ADR_SETUP_WAIT =>
				BUS_DIN_EN <= '0';
				BUS_DOUT_EN <= '0';
				BUS_WR_D <= '0';
				BUS_RD_D <= '0';
				BUSY <= '1';

			when RD_SETUP_WAIT =>
				BUS_DIN_EN <= '0';
				BUS_DOUT_EN <= '0';
				BUS_WR_D <= '0';
				BUS_RD_D <= '1';
				BUSY <= '1';

			when RD_CAPTURE =>
				BUS_DIN_EN <= '0';
				BUS_DOUT_EN <= '1';
				BUS_WR_D <= '0';
				BUS_RD_D <= '1';
				BUSY <= '1';

			when WAIT_RD_ACK_RELEASE =>
				BUS_DIN_EN <= '0';
				BUS_DOUT_EN <= '0';
				BUS_WR_D <= '0';
				BUS_RD_D <= '0';
				BUSY <= '1';

			when WR_CAPTURE =>
				BUS_DIN_EN <= '1';
				BUS_DOUT_EN <= '0';
				BUS_WR_D <= '0';
				BUS_RD_D <= '0';
				BUSY <= '1';

			when WR_SETUP_WAIT =>
				BUS_DIN_EN <= '0';
				BUS_DOUT_EN <= '0';
				BUS_WR_D <= '0';
				BUS_RD_D <= '0';
				BUSY <= '1';

			when WAIT_WR_ACK =>
				BUS_DIN_EN <= '0';
				BUS_DOUT_EN <= '0';
				BUS_WR_D <= '1';
				BUS_RD_D <= '0';
				BUSY <= '1';

			when WAIT_WR_ACK_RELEASE =>
				BUS_DIN_EN <= '0';
				BUS_DOUT_EN <= '0';
				BUS_WR_D <= '0';
				BUS_RD_D <= '0';
				BUSY <= '1';

			when others =>
				BUS_DIN_EN <= '0';
				BUS_DOUT_EN <= '0';
				BUS_WR_D <= '0';
				BUS_RD_D <= '0';
				BUSY <= '0';

		end case;
	end process;

end synthesis;
