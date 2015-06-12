library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ti_i2c_slave_io is
	port(
		CLK			: in std_logic;

		-- I2C Filtered signals
		SDA_FILT		: out std_logic;
		SCL_FILT		: out std_logic;
		SDA_OUT		: in std_logic;

		-- I2C I/O port signals
		SCL			: in std_logic;
		SDA			: inout std_logic;
		SDA_OE		: out std_logic
	);
end ti_i2c_slave_io;

architecture Synthesis of ti_i2c_slave_io is
	signal SCL_Q		: std_logic_vector(3 downto 0) := "1111";
	signal SDA_Q		: std_logic_vector(3 downto 0) := "1111";
	signal SDA_OUT_Q	: std_logic := '1';
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			SCL_Q <= SCL_Q(2 downto 0) & SCL;
			SDA_Q <= SDA_Q(2 downto 0) & SDA;
			SDA_OUT_Q <= SDA_OUT;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if (SDA_OUT = '1') and (SDA_OUT_Q = '0') then
				SDA <= '1';
				SDA_OE <= '1';
			elsif (SDA_OUT = '1') and (SDA_OUT_Q = '1') then
				SDA <= 'Z';
				SDA_OE <= '0';
			else
				SDA <= '0';
				SDA_OE <= '1';
			end if;
		end if;
	end process;

	process(CLK)
		variable scl_bits		: std_logic_vector(2 downto 0);
	begin
		if rising_edge(CLK) then
			scl_bits := SCL_Q(3 downto 1);
			if (scl_bits = "110") or (scl_bits = "000") then
				SCL_FILT <= '0';
			elsif (scl_bits = "001") or (scl_bits = "111") then
				SCL_FILT <= '1';
			end if;
		end if;
	end process;

	process(CLK)
		variable sda_bits		: std_logic_vector(2 downto 0);
	begin
		if rising_edge(CLK) then
			sda_bits := SDA_Q(3 downto 1);
			if (sda_bits = "110") or (sda_bits = "000") then
				SDA_FILT <= '0';
			elsif (sda_bits = "001") or (sda_bits = "111") then
				SDA_FILT <= '1';
			end if;
		end if;
	end process;

end Synthesis;
