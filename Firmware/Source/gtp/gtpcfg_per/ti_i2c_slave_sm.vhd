library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ti_i2c_slave_sm is
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
end ti_i2c_slave_sm;

architecture Synthesis of ti_i2c_slave_sm is
	type I2C_STATE_TYPE is (IDLE, WAIT_SCL_LOW, RX_SLAVE_ADDR, RX_USER_ADDR,
		RX_USER_DATA_MSB, RX_USER_DATA_LSB, RX_USER_DATA_WRITE,
		TX_USER_DATA_READ, TX_USER_DATA_MSB, TX_USER_DATA_LSB, WAIT_STOP
	);

	signal I2C_STATE			: I2C_STATE_TYPE;
	signal I2C_STATE_NEXT	: I2C_STATE_TYPE;
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			if I2C_STOP	= '1' then
				I2C_STATE <= IDLE;
			else			
				I2C_STATE <= I2C_STATE_NEXT;
			end if;
		end if;
	end process;

	process(I2C_STATE, I2C_START, RX_DATA_0, SCL_FILT, DONE)
	begin
		I2C_STATE_NEXT <= I2C_STATE;

		case I2C_STATE is
			when IDLE =>
				if I2C_START = '1' then
					I2C_STATE_NEXT <= WAIT_SCL_LOW;
				end if;

			when WAIT_SCL_LOW =>
				if SCL_FILT = '0' then
					I2C_STATE_NEXT <= RX_SLAVE_ADDR;
				end if;

			when RX_SLAVE_ADDR =>
				if DONE = '1' then
					if RX_DATA_0 = '0' then
						I2C_STATE_NEXT <= RX_USER_ADDR;
					else
						I2C_STATE_NEXT <= TX_USER_DATA_READ;
					end if;
				end if;

			when RX_USER_ADDR =>
				if DONE = '1' then
					I2C_STATE_NEXT <= RX_USER_DATA_MSB;
				end if;

			when RX_USER_DATA_MSB =>
				if DONE = '1' then
					I2C_STATE_NEXT <= RX_USER_DATA_LSB;
				end if;

			when RX_USER_DATA_LSB =>
				if DONE = '1' then
					I2C_STATE_NEXT <= RX_USER_DATA_WRITE;
				end if;

			when RX_USER_DATA_WRITE =>
				I2C_STATE_NEXT <= WAIT_STOP;

			when TX_USER_DATA_READ =>
				I2C_STATE_NEXT <= TX_USER_DATA_MSB;

			when TX_USER_DATA_MSB =>
				if DONE = '1' then
					I2C_STATE_NEXT <= TX_USER_DATA_LSB;
				end if;

			when TX_USER_DATA_LSB =>
				if DONE = '1' then
					I2C_STATE_NEXT <= WAIT_STOP;
				end if;

			when WAIT_STOP =>
			when others =>
		end case;
	end process;

	process(I2C_STATE, DONE)
	begin
		RX_DATA_EN <= '0';
		RX_ACK_EN <= '0';
		SLAVE_ADR_EN <= '0';
		TX_DATA_EN <= '0';
		USER_WR <= '0';
		USER_RD <= '0';
		USER_ADDR_EN <= '0';
		USER_DOUT_MSB_EN <= '0';
		USER_DOUT_LSB_EN <= '0';
		USER_DIN_MSB_EN <= '0';
		USER_DIN_LSB_EN <= '0';

		case I2C_STATE is
			when IDLE =>

			when WAIT_SCL_LOW =>

			when RX_SLAVE_ADDR =>
				RX_DATA_EN <= not DONE;
				SLAVE_ADR_EN <= '1';

			when RX_USER_ADDR =>
				RX_DATA_EN <= not DONE;
				USER_ADDR_EN <= '1';
				RX_ACK_EN <= '1';

			when RX_USER_DATA_MSB =>
				RX_DATA_EN <= not DONE;
				USER_DIN_MSB_EN <= '1';
				RX_ACK_EN <= '1';

			when RX_USER_DATA_LSB =>
				RX_DATA_EN <= not DONE;
				USER_DIN_LSB_EN <= '1';
				RX_ACK_EN <= '1';

			when RX_USER_DATA_WRITE =>
				USER_WR <= '1';

			when TX_USER_DATA_READ =>
				USER_RD <= '1';

			when TX_USER_DATA_MSB =>
				TX_DATA_EN <= not DONE;
				USER_DOUT_MSB_EN <= '1';

			when TX_USER_DATA_LSB =>
				TX_DATA_EN <= not DONE;
				USER_DOUT_LSB_EN <= '1';

			when WAIT_STOP =>

			when others =>
		end case;
	end process;



end Synthesis;
