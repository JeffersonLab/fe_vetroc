library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity gtp_regif is
	port(
		avs_s0_address			: in std_logic_vector(13 downto 0) := (others => '0');
		avs_s0_read				: in std_logic := '0';
		avs_s0_readdata		: out std_logic_vector(31 downto 0);
		avs_s0_write			: in std_logic := '0';
		avs_s0_writedata		: in std_logic_vector(31 downto 0) := (others => '0');
		avs_s0_waitrequest	: out std_logic;
		clk						: in std_logic := '0';
		reset						: in std_logic := '0';
		irq						: out std_logic := '0';

		BUS_CLK					: out std_logic;
		BUS_RESET				: out std_logic;
		BUS_DIN					: out std_logic_vector(31 downto 0);
		BUS_DOUT					: in std_logic_vector(31 downto 0);
		BUS_ADDR					: out std_logic_vector(15 downto 0);
		BUS_WR					: out std_logic;
		BUS_RD					: out std_logic;
		BUS_ACK					: in std_logic;
		BUS_IRQ					: in std_logic
	);
end entity gtp_regif;

architecture rtl of gtp_regif is
	type gtp_regif_state_type is (IDLE, WAIT_ACK_DONE, RD_ADDR_SETUP, RD_WAIT_ACK, RD_DATA_SETUP, WR_SETUP, WR_WAIT_ACK);

	constant ADR_SETUP_CNT	: std_logic_vector(7 downto 0) := "00001000";
	constant RD_SETUP_CNT	: std_logic_vector(7 downto 0) := "00001000";
	constant WR_SETUP_CNT	: std_logic_vector(7 downto 0) := "00001000";
	constant TIMEOUT_CNT		: std_logic_vector(7 downto 0) := "11111111";

	signal gtp_regif_ps		: gtp_regif_state_type;
	signal gtp_regif_ns		: gtp_regif_state_type;
	signal CNT					: std_logic_vector(7 downto 0);
	signal ADR_SETUP_DONE	: std_logic;
	signal RD_SETUP_DONE		: std_logic;
	signal RD_CAPTURE_DATA	: std_logic;
	signal TIMEOUT_DONE		: std_logic;
	signal WR_SETUP_DONE		: std_logic;
	signal BUS_RD_D			: std_logic;
	signal BUS_WR_D			: std_logic;
	signal BUS_ACK_Q			: std_logic_vector(1 downto 0);
begin
	
	BUS_CLK <= clk;
	BUS_RESET <= reset;

	ADR_SETUP_DONE <= '1' when CNT = ADR_SETUP_CNT else '0';
	RD_SETUP_DONE <= '1' when CNT = RD_SETUP_CNT else '0';
	WR_SETUP_DONE <= '1' when CNT = WR_SETUP_CNT else '0';
	TIMEOUT_DONE <= '1' when CNT = TIMEOUT_CNT else '0';
	
	process(clk)
	begin
		if rising_edge(clk) then
			if gtp_regif_ps /= gtp_regif_ns then
				CNT <= (others=>'0');
			else
				CNT <= CNT + 1;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			irq <= BUS_IRQ;
			BUS_ADDR <= avs_s0_address & "00";
			BUS_DIN <= avs_s0_writedata;
			BUS_RD <= BUS_RD_D;
			BUS_WR <= BUS_WR_D;
			BUS_ACK_Q <= BUS_ACK_Q(0) & BUS_ACK;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			if RD_CAPTURE_DATA = '1' then
				avs_s0_readdata <= BUS_DOUT;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				gtp_regif_ps <= IDLE;
			else
				gtp_regif_ps <= gtp_regif_ns;
			end if;
		end if;
	end process;

	process(gtp_regif_ps, avs_s0_read, avs_s0_write, BUS_ACK_Q, ADR_SETUP_DONE, TIMEOUT_DONE, RD_SETUP_DONE, WR_SETUP_DONE)
	begin
		gtp_regif_ns <= gtp_regif_ps;

		BUS_WR_D <= '0';
		BUS_RD_D <= '0';
		RD_CAPTURE_DATA <= '0';
		avs_s0_waitrequest <= '1';

		case gtp_regif_ps is
			-- Common
			when IDLE =>
				if avs_s0_read = '1' then
					gtp_regif_ns <= RD_ADDR_SETUP;
				elsif avs_s0_write = '1' then
					gtp_regif_ns <= WR_SETUP;
				else
					avs_s0_waitrequest <= '0';
				end if;

			when WAIT_ACK_DONE =>
				if BUS_ACK_Q(1) = '0' then
					avs_s0_waitrequest <= '0';
					gtp_regif_ns <= IDLE;
				end if;

			-- Read transaction
			when RD_ADDR_SETUP =>
				if ADR_SETUP_DONE = '1' then
					gtp_regif_ns <= RD_WAIT_ACK;
				end if;

			when RD_WAIT_ACK =>
				BUS_RD_D <= '1';
				if (TIMEOUT_DONE = '1') or (BUS_ACK_Q(1) = '1') then
					gtp_regif_ns <= RD_DATA_SETUP;
				end if;

			when RD_DATA_SETUP =>
				BUS_RD_D <= '1';
				if RD_SETUP_DONE = '1' then
					gtp_regif_ns <= WAIT_ACK_DONE;
					RD_CAPTURE_DATA <= '1';
				end if;

			-- Write transaction
			when WR_SETUP =>
				if WR_SETUP_DONE = '1' then
					gtp_regif_ns <= WR_WAIT_ACK;
				end if;

			when WR_WAIT_ACK =>
				if (TIMEOUT_DONE = '1') or (BUS_ACK_Q(1) = '1') then
					gtp_regif_ns <= WAIT_ACK_DONE;
				else
					BUS_WR_D <= '1';
				end if;

			when others =>
				gtp_regif_ns <= IDLE;

		end case;
	end process;

end architecture rtl; -- of gtp_regif
