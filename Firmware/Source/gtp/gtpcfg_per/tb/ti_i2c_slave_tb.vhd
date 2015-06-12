library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ti_i2c_slave_tb is
end ti_i2c_slave_tb;

architecture test_bench of ti_i2c_slave_tb is
	component ti_i2c_slave is
		port(
			CLK			: in std_logic;

			SLAVE_ADR	: in std_logic_vector(6 downto 0);

			USER_WR		: out std_logic;
			USER_RD		: out std_logic;
			USER_ADDR	: out std_logic_vector(7 downto 0);		
			USER_DIN		: out std_logic_vector(15 downto 0);
			USER_DOUT	: in std_logic_vector(15 downto 0);

			SCL			: in std_logic;
			SDA			: inout std_logic
		);
	end component;

	signal CLK			: std_logic;
	signal SLAVE_ADR	: std_logic_vector(6 downto 0);
	signal USER_WR		: std_logic;
	signal USER_RD		: std_logic;
	signal USER_ADDR	: std_logic_vector(7 downto 0);		
	signal USER_DIN	: std_logic_vector(15 downto 0);
	signal USER_DOUT	: std_logic_vector(15 downto 0);
	signal SCL			: std_logic;
	signal SDA			: std_logic;
begin

	ti_i2c_slave_inst: ti_i2c_slave
		port map(
			CLK			=> CLK,
			SLAVE_ADR	=> SLAVE_ADR,
			USER_WR		=> USER_WR,
			USER_RD		=> USER_RD,
			USER_ADDR	=> USER_ADDR,
			USER_DIN		=> USER_DIN,
			USER_DOUT	=> USER_DOUT,
			SCL			=> SCL,
			SDA			=> SDA
		);

	process
	begin
		CLK <= '0';
		wait for 10 ns;
		CLK <= '1';
		wait for 10 ns;
	end process;

	SLAVE_ADR <= "0000001";
	USER_DOUT <= x"1234";

	process
		procedure i2c_start is
		begin
			SCL <= '0';
			wait for 200 ns;
			SDA <= '1';
			wait for 200 ns;
			SCL <= '1';
			wait for 200 ns;
			SDA <= '0';
			wait for 200 ns;
		end i2c_start;

		procedure i2c_stop is
		begin
			SCL <= '0';
			wait for 200 ns;
			SDA <= '0';
			wait for 200 ns;
			SCL <= '1';
			wait for 200 ns;
			SDA <= '1';
			wait for 200 ns;
		end i2c_stop;

		procedure i2c_write_byte(d : in std_logic_vector(7 downto 0)) is
		begin
			for I in 7 downto 0 loop
				SCL <= '0';
				wait for 200 ns;
				SDA <= d(I);
				wait for 200 ns;
				SCL <= '1';
				wait for 200 ns;
				SCL <= '0';
				wait for 200 ns;			
			end loop;
		end i2c_write_byte;

		procedure i2c_read_byte(d : out std_logic_vector(7 downto 0)) is
		begin
			SDA <= 'H';
			for I in 7 downto 0 loop
				SCL <= '0';
				wait for 200 ns;
				SCL <= '1';
				wait for 200 ns;
				d(I) := SDA;
				wait for 200 ns;
				SCL <= '0';
				wait for 200 ns;			
			end loop;
		end i2c_read_byte;

		procedure i2c_getack(ack : out std_logic) is
		begin
			SDA <= 'Z';
			SCL <= '0';
			wait for 200 ns;
			SCL <= '1';
			wait for 200 ns;
			ack := not SDA;
			wait for 200 ns;
			SCL <= '0';
			wait for 200 ns;			
		end i2c_getack;

		procedure i2c_sendack(ack : in std_logic) is
		begin
			SDA <= not ack;
			SCL <= '0';
			wait for 200 ns;
			SCL <= '1';
			wait for 200 ns;
			SCL <= '0';
			wait for 200 ns;			
		end i2c_sendack;

		procedure write_data(addr : in std_logic_vector(7 downto 0); data : in std_logic_vector(15 downto 0)) is
			variable ack	: std_logic;		
		begin
			-- Write @ user address
			i2c_start;
			-- slave address
			i2c_write_byte("0000001" & '0');
			i2c_getack(ack);
			-- user address
			i2c_write_byte(addr);
			i2c_getack(ack);
			-- user data MSB
			i2c_write_byte(data(15 downto 8));
			i2c_getack(ack);
			-- user data LSB
			i2c_write_byte(data(7 downto 0));
			i2c_getack(ack);
			i2c_stop;
		end write_data;

		procedure read_data(addr : in std_logic_vector(7 downto 0); data : out std_logic_vector(15 downto 0)) is
			variable ack	: std_logic;
		begin
		-- Read @ user address
			i2c_start;
			-- slave address
			i2c_write_byte("0000001" & '0');
			i2c_getack(ack);
			-- user address
			i2c_write_byte(addr);
			i2c_getack(ack);
			i2c_stop;

			i2c_start;
			-- slave address
			i2c_write_byte("0000001" & '1');
			i2c_getack(ack);
			-- user data MSB
			i2c_read_byte(data(15 downto 8));
			i2c_sendack('1');
			-- user data LSB
			i2c_read_byte(data(7 downto 0));
			i2c_sendack('0');
			i2c_stop;
		end read_data;

		variable data	: std_logic_vector(15 downto 0);
	begin
		SDA <= '1';
		SCL <= '1';
		wait for 1 us;

		i2c_stop;
		wait for 1 us;

		write_data(x"A9", x"ABCD");
		write_data(x"23", x"A1C2");
		write_data(x"75", x"3BC4");

		read_data(x"A9", data);
		read_data(x"23", data);
		read_data(x"75", data);

		wait;
	end process;

end test_bench;
