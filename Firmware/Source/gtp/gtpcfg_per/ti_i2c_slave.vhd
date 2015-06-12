library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ti_i2c_slave is
	port(
		CLK			: in std_logic;

		SLAVE_ADR	: in std_logic_vector(6 downto 0);

		USER_WR		: out std_logic;
		USER_RD		: out std_logic;
		USER_ADDR	: out std_logic_vector(7 downto 0);		
		USER_DIN		: out std_logic_vector(15 downto 0);
		USER_DOUT	: in std_logic_vector(15 downto 0);

		SCL			: in std_logic;
		SDA			: inout std_logic;
		SDA_OE		: out std_logic
	);
end ti_i2c_slave;

architecture Synthesis of ti_i2c_slave is
	component ti_i2c_slave_io is
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
	end component;

	component ti_i2c_slave_sm is
		port(
			CLK					: in std_logic;

			DONE					: in std_logic;
			I2C_START			: in std_logic;
			I2C_STOP				: in std_logic;
			SCL_FILT				: in std_logic;
			RX_DATA_0			: in std_logic;

			RX_DATA_EN			: out std_logic;
			RX_ACK_EN			: out std_logic;
			SLAVE_ADR_EN		: out std_logic;
			TX_DATA_EN			: out std_logic;
			USER_WR				: out std_logic;
			USER_RD				: out std_logic;
			USER_ADDR_EN		: out std_logic;
			USER_DOUT_MSB_EN	: out std_logic;
			USER_DOUT_LSB_EN	: out std_logic;
			USER_DIN_MSB_EN	: out std_logic;
			USER_DIN_LSB_EN	: out std_logic
		);
	end component;

	component ti_i2c_slave_sreg is
		port(
			CLK				: in std_logic;

			SCL_FILT_R		: in std_logic;
			SCL_FILT_F		: in std_logic;
			SDA_FILT			: in std_logic;
			SDA_OUT			: out std_logic;

			TX_DATA_EN		: in std_logic;
			TX_DATA			: in std_logic_vector(7 downto 0);

			RX_DATA_EN		: in std_logic;
			RX_DATA			: out std_logic_vector(7 downto 0);

			RX_ACK_EN		: in std_logic;
			SLAVE_ADR		: in std_logic_vector(6 downto 0);
			SLAVE_ADR_EN	: in std_logic;

			DONE				: out std_logic
		);
	end component;

	signal I2C_START			: std_logic;
	signal I2C_STOP			: std_logic;
	signal SCL_FILT_Q			: std_logic;
	signal SDA_FILT_Q			: std_logic;
	signal SDA_FILT_R			: std_logic;
	signal SDA_FILT_F			: std_logic;
	signal SCL_FILT_R			: std_logic;
	signal SCL_FILT_F			: std_logic;
	signal SDA_FILT			: std_logic;
	signal SCL_FILT			: std_logic;
	signal SDA_OUT				: std_logic;
	signal USER_ADDR_EN		: std_logic;
	signal USER_DIN_MSB_EN	: std_logic;
	signal USER_DIN_LSB_EN	: std_logic;
	signal USER_DOUT_MSB_EN	: std_logic;
	signal USER_DOUT_LSB_EN	: std_logic;
	signal USER_ADDR_i		: std_logic_vector(7 downto 0) := x"00";
	signal USER_DIN_i			: std_logic_vector(15 downto 0) := x"0000";
	signal SLAVE_ADR_EN		: std_logic;
	signal RX_ACK_EN			: std_logic;
	signal RX_DATA				: std_logic_vector(7 downto 0);
	signal RX_DATA_EN			: std_logic;
	signal TX_DATA				: std_logic_vector(7 downto 0) := x"00";
	signal TX_DATA_EN			: std_logic;
	signal DONE					: std_logic;
begin

	ti_i2c_slave_io_inst: ti_i2c_slave_io
		port map(
			CLK			=> CLK,
			SDA_FILT		=> SDA_FILT,
			SCL_FILT		=> SCL_FILT,
			SDA_OUT		=> SDA_OUT,
			SCL			=> SCL,
			SDA			=> SDA,
			SDA_OE		=> SDA_OE
		);

	ti_i2c_slave_sreg_inst: ti_i2c_slave_sreg
		port map(
			CLK					=> CLK,
			SCL_FILT_R			=> SCL_FILT_R,
			SCL_FILT_F			=> SCL_FILT_F,
			SDA_FILT				=> SDA_FILT,
			SDA_OUT				=> SDA_OUT,
			TX_DATA_EN			=> TX_DATA_EN,
			TX_DATA				=> TX_DATA,
			RX_DATA_EN			=> RX_DATA_EN,
			RX_DATA				=> RX_DATA,
			RX_ACK_EN			=> RX_ACK_EN,
			SLAVE_ADR			=> SLAVE_ADR,
			SLAVE_ADR_EN		=> SLAVE_ADR_EN,
			DONE					=> DONE
		);

	ti_i2c_slave_sm_inst: ti_i2c_slave_sm
		port map(
			CLK					=> CLK,
			DONE					=> DONE,
			I2C_START			=> I2C_START,
			I2C_STOP				=> I2C_STOP,
			SCL_FILT				=> SCL_FILT,
			RX_DATA_0			=> RX_DATA(0),
			RX_DATA_EN			=> RX_DATA_EN,
			RX_ACK_EN			=> RX_ACK_EN,
			SLAVE_ADR_EN		=> SLAVE_ADR_EN,
			TX_DATA_EN			=> TX_DATA_EN,
			USER_WR				=> USER_WR,
			USER_RD				=> USER_RD,
			USER_ADDR_EN		=> USER_ADDR_EN,
			USER_DOUT_MSB_EN	=> USER_DOUT_MSB_EN,
			USER_DOUT_LSB_EN	=> USER_DOUT_LSB_EN,
			USER_DIN_MSB_EN	=> USER_DIN_MSB_EN,
			USER_DIN_LSB_EN	=> USER_DIN_LSB_EN
		);

	SDA_FILT_R <= '1' when (SDA_FILT = '1') and (SDA_FILT_Q = '0') else '0';
	SDA_FILT_F <= '1' when (SDA_FILT = '0') and (SDA_FILT_Q = '1') else '0';
	SCL_FILT_R <= '1' when (SCL_FILT = '1') and (SCL_FILT_Q = '0') else '0';
	SCL_FILT_F <= '1' when (SCL_FILT = '0') and (SCL_FILT_Q = '1') else '0';

	I2C_START <= SDA_FILT_F and SCL_FILT;
	I2C_STOP <= SDA_FILT_R and SCL_FILT;

	process(CLK)
	begin
		if rising_edge(CLK) then
			SCL_FILT_Q <= SCL_FILT;
			SDA_FILT_Q <= SDA_FILT;
		end if;
	end process;

	-- User Bus Interface Registers
	USER_ADDR <= USER_ADDR_i;
	USER_DIN <= USER_DIN_i;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if USER_ADDR_EN = '1' then
				USER_ADDR_i <= RX_DATA;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if USER_DIN_MSB_EN = '1' then
				USER_DIN_i(15 downto 8) <= RX_DATA;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if USER_DIN_LSB_EN = '1' then
				USER_DIN_i(7 downto 0) <= RX_DATA;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if USER_DOUT_MSB_EN = '1' then
				TX_DATA <= USER_DOUT(15 downto 8);
			end if;

			if USER_DOUT_LSB_EN = '1' then
				TX_DATA <= USER_DOUT(7 downto 0);
			end if;
		end if;
	end process;

end Synthesis;
