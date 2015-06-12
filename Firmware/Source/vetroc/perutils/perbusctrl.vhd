library ieee;
use ieee.std_logic_1164.all;

use work.perbus_pkg.all;

-- Note:
--    1) control signals are synchronized to peripheral clock domain. Bus master
--       must provide sufficient delays on control signals to allow asynchronous
--       data/address paths meet destinations.
--    2) data path delays must be controlled in UCF on BUS_* <-> PER_* signals
--    3) For large bus systems, increase bus master multicycle setup cycles and
--       relax UCF data path constraint as appropriate
entity perbusctrl is
	generic(
			ADDR_INFO	: PER_ADDR_INFO
		);
	port(
		BUS_RESET	: in std_logic;
		BUS_RESET_SOFT	: in std_logic;
		BUS_DIN		: in std_logic_vector(D_WIDTH-1 downto 0);
		BUS_DOUT		: out std_logic_vector(D_WIDTH-1 downto 0);
		BUS_ADDR		: in std_logic_vector(A_WIDTH-1 downto 0);
		BUS_WR		: in std_logic;
		BUS_RD		: in std_logic;
		BUS_ACK		: out std_logic;
		
		PER_CLK		: in std_logic;
		PER_RESET	: out std_logic;
		PER_RESET_SOFT	: out std_logic;
		PER_DIN		: out std_logic_vector(D_WIDTH-1 downto 0);
		PER_DOUT		: in std_logic_vector(D_WIDTH-1 downto 0);
		PER_ADDR		: out std_logic_vector(A_WIDTH-1 downto 0);
		PER_WR		: out std_logic;
		PER_RD		: out std_logic;
		PER_ACK		: in std_logic;
		PER_MATCH	: out std_logic
	);
end perbusctrl;

architecture Synthesis of perbusctrl is
	signal BUS_WR_Q			: std_logic_vector(2 downto 0) := (others=>'0');
	signal BUS_RD_Q			: std_logic_vector(2 downto 0) := (others=>'0');
	signal BUS_RESET_Q		: std_logic_vector(1 downto 0) := (others=>'1');
	signal BUS_RESET_SOFT_Q	: std_logic_vector(1 downto 0) := (others=>'1');
	signal BUS_ACK_RST	: std_logic;
begin

	BUS_DOUT <= PER_DOUT;
	PER_DIN <= BUS_DIN;
	PER_ADDR <= BUS_ADDR and ADDR_INFO.USER_MASK;
	PER_MATCH <= '1' when (BUS_ADDR and ADDR_INFO.BASE_MASK) = ADDR_INFO.BASE_ADDR else '0'; 

	PER_RESET <= BUS_RESET_Q(BUS_RESET_Q'left);
	PER_RESET_SOFT <= BUS_RESET_SOFT_Q(BUS_RESET_SOFT_Q'left);

	process(PER_CLK, BUS_RESET)
	begin
		if BUS_RESET = '1' then
			BUS_RESET_Q <= (others=>'1');
		elsif rising_edge(PER_CLK) then
			BUS_RESET_Q <= BUS_RESET_Q(BUS_RESET_Q'left-1 downto 0) & '0';
		end if;
	end process;

	process(PER_CLK, BUS_RESET_SOFT)
	begin
		if BUS_RESET_SOFT = '1' then
			BUS_RESET_SOFT_Q <= (others=>'1');
		elsif rising_edge(PER_CLK) then
			BUS_RESET_SOFT_Q <= BUS_RESET_SOFT_Q(BUS_RESET_SOFT_Q'left-1 downto 0) & '0';
		end if;
	end process;

	process(PER_CLK)
	begin
		if rising_edge(PER_CLK) then
			BUS_WR_Q <= BUS_WR_Q(BUS_WR_Q'left-1 downto 0) & BUS_WR;
			BUS_RD_Q <= BUS_RD_Q(BUS_RD_Q'left-1 downto 0) & BUS_RD;
			PER_WR <= BUS_WR_Q(BUS_WR_Q'left-1) and not BUS_WR_Q(BUS_WR_Q'left);
			PER_RD <= BUS_RD_Q(BUS_RD_Q'left-1) and not BUS_RD_Q(BUS_RD_Q'left);
		end if;
	end process;

	BUS_ACK_RST <= '1' when (BUS_WR = '0') and (BUS_RD = '0') else '0';

	process(PER_CLK, BUS_ACK_RST)
	begin
		if BUS_ACK_RST = '1' then
			BUS_ACK <= '0';
		elsif rising_edge(PER_CLK) then
			if PER_ACK = '1' then
				BUS_ACK <= '1';
			end if;
		end if;
	end process;

end Synthesis;
