library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

entity scfifo_std is
	generic(
		D_WIDTH	: integer := 32;
		A_WIDTH		: integer := 10;
		RD_PROTECT	: boolean := true;
		WR_PROTECT	: boolean := true
	);
	port(
		CLK		: in std_logic;
		RST		: in std_logic;

		DIN		: in std_logic_vector(D_WIDTH-1 downto 0);
		WR			: in std_logic;
		FULL		: out std_logic;

		DOUT		: out std_logic_vector(D_WIDTH-1 downto 0);
		RD			: in std_logic;
		EMPTY		: out std_logic
	);
end scfifo_std;

architecture synthesis of scfifo_std is
	signal WR_ACTIVE		: std_logic;
	signal RD_ACTIVE		: std_logic;
	signal WR_ADDR			: std_logic_vector(A_WIDTH-1 downto 0) := (others=>'0');
	signal RD_ADDR			: std_logic_vector(A_WIDTH-1 downto 0) := (others=>'0');
	signal WR_ADDR_NEXT	: std_logic_vector(A_WIDTH-1 downto 0);
	signal RD_ADDR_NEXT	: std_logic_vector(A_WIDTH-1 downto 0);
	signal EMPTY_NEXT		: std_logic;
	signal FULL_i			: std_logic;
	signal EMPTY_i			: std_logic := '1';
begin

	FULL <= FULL_i;
	EMPTY <= EMPTY_i;

	EMPTY_NEXT <= '1' when WR_ADDR = RD_ADDR_NEXT else '0';
	FULL_i <= '1' when WR_ADDR_NEXT = RD_ADDR else '0';

	WR_ADDR_NEXT <= WR_ADDR + 1;

	RD_ADDR_NEXT <= RD_ADDR + 1;

	wr_protect_gen_true: if WR_PROTECT = true generate
		WR_ACTIVE <= WR and not FULL_i;
	end generate;

	wr_protect_gen_false: if WR_PROTECT = false generate
		WR_ACTIVE <= WR;
	end generate;

	rd_protect_gen_true: if RD_PROTECT = true generate
	RD_ACTIVE <= RD and not EMPTY_i;
	end generate;

	rd_protect_gen_false: if RD_PROTECT = false generate
		RD_ACTIVE <= RD;
	end generate;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				WR_ADDR <= (others=>'0');
			elsif WR_ACTIVE = '1' then
				WR_ADDR <= WR_ADDR_NEXT;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				RD_ADDR <= (others=>'0');
			elsif RD_ACTIVE = '1' then
				RD_ADDR <= RD_ADDR_NEXT;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				EMPTY_i <= '1';
			elsif WR_ACTIVE = '1' then
				EMPTY_i <= '0';
			elsif RD_ACTIVE = '1' then
				EMPTY_i <= EMPTY_NEXT;
			end if;
		end if;
	end process;

	sdp_ram_inst: sdp_ram
		generic map(
			D_WIDTH		=> D_WIDTH,
			A_WIDTH		=> A_WIDTH,
			DOUT_REG		=> false
		)
		port map(
			WR_CLK		=> CLK,
			WR				=> WR_ACTIVE,
			WR_ADDR		=> WR_ADDR,
			DIN			=> DIN,
			RD_CLK		=> CLK,
			RD				=> RD_ACTIVE,
			RD_ADDR		=> RD_ADDR,
			DOUT			=> DOUT
		);

end synthesis;
