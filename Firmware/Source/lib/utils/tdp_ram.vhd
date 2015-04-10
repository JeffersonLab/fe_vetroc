library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tdp_ram is
	generic(
		D_WIDTH		: integer := 32;
		A_WIDTH		: integer := 10;
		DOUTA_REG	: boolean := false;
		DOUTB_REG	: boolean := false
	);
	port(
		CLKA		: in std_logic;
		WRA		: in std_logic;
		RDA		: in std_logic;
		ADDRA		: in std_logic_vector(A_WIDTH-1 downto 0);
		DINA		: in std_logic_vector(D_WIDTH-1 downto 0);
		DOUTA		: out std_logic_vector(D_WIDTH-1 downto 0);
		
		CLKB		: in std_logic;
		WRB		: in std_logic;
		RDB		: in std_logic;
		ADDRB		: in std_logic_vector(A_WIDTH-1 downto 0);
		DINB		: in std_logic_vector(D_WIDTH-1 downto 0);
		DOUTB		: out std_logic_vector(D_WIDTH-1 downto 0)
	);
end tdp_ram;

architecture Synthesis of tdp_ram is
	type DATA_TYPE_ARRAY is array(natural range <>) of std_logic_vector(D_WIDTH-1 downto 0);
	
	shared variable DATA_ARRAY		: DATA_TYPE_ARRAY(0 to 2**A_WIDTH-1) := (others=>(others=>'0'));

	signal DOUTA_RAM					: std_logic_vector(D_WIDTH-1 downto 0);
	signal DOUTB_RAM					: std_logic_vector(D_WIDTH-1 downto 0);
begin

	douta_reg_gen_true: if DOUTA_REG = true generate
		process(CLKA)
		begin
			if rising_edge(CLKA) then
				DOUTA <= DOUTA_RAM;
			end if;
		end process;
	end generate;

	douta_reg_gen_false: if DOUTA_REG = false generate
		DOUTA <= DOUTA_RAM;
	end generate;

	doutb_reg_gen_true: if DOUTB_REG = true generate
		process(CLKB)
		begin
			if rising_edge(CLKB) then
				DOUTB <= DOUTB_RAM;
			end if;
		end process;
	end generate;

	doutb_reg_gen_false: if DOUTB_REG = false generate
		DOUTB <= DOUTB_RAM;
	end generate;

	process(CLKA)
	begin
		if rising_edge(CLKA) then
			if RDA = '1' then
				DOUTA_RAM <= DATA_ARRAY(conv_integer(ADDRA));
			end if;

			if WRA = '1' then
				DATA_ARRAY(conv_integer(ADDRA)) := DINA;
			end if;
		end if;
	end process;

	process(CLKB)
	begin
		if rising_edge(CLKB) then
			if RDB = '1' then
				DOUTB_RAM <= DATA_ARRAY(conv_integer(ADDRB));
			end if;

			if WRB = '1' then
				DATA_ARRAY(conv_integer(ADDRB)) := DINB;
			end if;
		end if;
	end process;

end Synthesis;
