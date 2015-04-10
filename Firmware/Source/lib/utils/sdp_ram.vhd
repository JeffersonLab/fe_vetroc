library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sdp_ram is
	generic(
		D_WIDTH		: integer := 32;
		A_WIDTH		: integer := 10;
		DOUT_REG		: boolean := false
	);
	port(
		WR_CLK	: in std_logic;
		WR			: in std_logic;
		WR_ADDR	: in std_logic_vector(A_WIDTH-1 downto 0);
		DIN		: in std_logic_vector(D_WIDTH-1 downto 0);
		
		RD_CLK	: in std_logic;
		RD			: in std_logic;
		RD_ADDR	: in std_logic_vector(A_WIDTH-1 downto 0);
		DOUT		: out std_logic_vector(D_WIDTH-1 downto 0)
	);
end sdp_ram;

architecture Synthesis of sdp_ram is
	type DATA_TYPE_ARRAY is array(natural range <>) of std_logic_vector(D_WIDTH-1 downto 0);
	
	signal DATA_ARRAY		: DATA_TYPE_ARRAY(0 to 2**A_WIDTH-1) := (others=>(others=>'0'));
	signal DOUT_RAM		: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
	signal DOUT_i			: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
begin
	DOUT <= DOUT_i;

	dout_reg_gen_true: if DOUT_REG = true generate
		process(RD_CLK)
		begin
			if rising_edge(RD_CLK) then
				DOUT_i <= DOUT_RAM;
			end if;
		end process;
	end generate;

	dout_reg_gen_false: if DOUT_REG = false generate
		DOUT_i <= DOUT_RAM;
	end generate;

	process(WR_CLK)
	begin
		if rising_edge(WR_CLK) then
			if WR = '1' then
				DATA_ARRAY(conv_integer(WR_ADDR)) <= DIN;
			end if;
		end if;
	end process;
	
	process(RD_CLK)
	begin
		if rising_edge(RD_CLK) then
			if RD = '1' then
				DOUT_RAM <= DATA_ARRAY(conv_integer(RD_ADDR));
			end if;
		end if;
	end process;

end Synthesis;
