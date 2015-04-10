library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity mp_ram_2w1r is
	generic(
		D_WIDTH		: integer := 1;
		A_WIDTH		: integer := 10;
		DOUT_REG		: boolean := false;
		WR0_REG		: boolean := false;
		WR1_REG		: boolean := false
	);
	port(
		WR0_CLK	: in std_logic;
		WR0		: in std_logic;
		WR_ADDR0	: in std_logic_vector(A_WIDTH-1 downto 0);
		DIN0		: in std_logic_vector(D_WIDTH-1 downto 0);

		WR1_CLK	: in std_logic;
		WR1		: in std_logic;
		WR_ADDR1	: in std_logic_vector(A_WIDTH-1 downto 0);
		DIN1		: in std_logic_vector(D_WIDTH-1 downto 0);

		RD_CLK	: in std_logic;
		RD			: in std_logic;
		RD_ADDR	: in std_logic_vector(A_WIDTH-1 downto 0);
		DOUT		: out std_logic_vector(D_WIDTH-1 downto 0)
	);
end mp_ram_2w1r;

architecture synthesis of mp_ram_2w1r is
	type DATA_TYPE_ARRAY is array(natural range <>) of std_logic_vector(D_WIDTH-1 downto 0);
	
	signal DATA_ARRAY0	: DATA_TYPE_ARRAY(0 to 2**A_WIDTH-1) := (others=>(others=>'0'));
	signal DATA_ARRAY1	: DATA_TYPE_ARRAY(0 to 2**A_WIDTH-1) := (others=>(others=>'0'));

	signal DOUT_RAM					: std_logic_vector(D_WIDTH-1 downto 0);
begin

	dout_reg_gen_true: if DOUT_REG = true generate
		process(RD_CLK)
		begin
			if rising_edge(RD_CLK) then
				DOUT <= DOUT_RAM;
			end if;
		end process;
	end generate;

	dout_reg_gen_false: if DOUT_REG = false generate
		DOUT <= DOUT_RAM;
	end generate;

	process(RD_CLK)
	begin
		if rising_edge(RD_CLK) then
			if RD = '1' then
				DOUT_RAM <= DATA_ARRAY0(conv_integer(RD_ADDR)) xor DATA_ARRAY1(conv_integer(RD_ADDR));
			end if;
		end if;
	end process;

	wr0_reg_true: if WR0_REG = true generate
		signal WR0_Q		: std_logic := '0';
		signal DIN0_Q		: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
		signal WR_ADDR0_Q	: std_logic_vector(A_WIDTH-1 downto 0) := (others=>'0');
		signal WR0_DOUT1	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
	begin
		process(WR0_CLK)
		begin
			if rising_edge(WR0_CLK) then
				WR0_Q <= WR0;
				DIN0_Q <= DIN0;
				WR_ADDR0_Q <= WR_ADDR0;
				WR0_DOUT1 <= DATA_ARRAY1(conv_integer(WR_ADDR0));

				if WR0_Q = '1' then
					DATA_ARRAY0(conv_integer(WR_ADDR0_Q)) <= DIN0_Q xor WR0_DOUT1;
				end if;
			end if;
		end process;
	end generate;

	wr0_reg_false: if WR0_REG = false generate
		process(WR0_CLK)
		begin
			if rising_edge(WR0_CLK) then
				if WR0 = '1' then
					DATA_ARRAY0(conv_integer(WR_ADDR0)) <= DIN0 xor DATA_ARRAY1(conv_integer(WR_ADDR0));
				end if;
			end if;
		end process;
	end generate;

	wr1_reg_true: if WR1_REG = true generate
		signal WR1_Q		: std_logic := '0';
		signal DIN1_Q		: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
		signal WR_ADDR1_Q	: std_logic_vector(A_WIDTH-1 downto 0) := (others=>'0');
		signal WR1_DOUT0	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
	begin
		process(WR1_CLK)
		begin
			if rising_edge(WR1_CLK) then
				WR1_Q <= WR1;
				DIN1_Q <= DIN1;
				WR_ADDR1_Q <= WR_ADDR1;
				WR1_DOUT0 <= DATA_ARRAY0(conv_integer(WR_ADDR1));

				if WR1_Q = '1' then
					DATA_ARRAY1(conv_integer(WR_ADDR1_Q)) <= DIN1_Q xor WR1_DOUT0;
				end if;
			end if;
		end process;
	end generate;

	wr1_reg_false: if WR1_REG = false generate
		process(WR1_CLK)
		begin
			if rising_edge(WR1_CLK) then
				if WR1 = '1' then
					DATA_ARRAY1(conv_integer(WR_ADDR1)) <= DIN1 xor DATA_ARRAY0(conv_integer(WR_ADDR1));
				end if;
			end if;
		end process;
	end generate;

end synthesis;
