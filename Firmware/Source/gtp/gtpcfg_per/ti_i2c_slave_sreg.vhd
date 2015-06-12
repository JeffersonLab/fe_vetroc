library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ti_i2c_slave_sreg is
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
end ti_i2c_slave_sreg;

architecture synthesis of ti_i2c_slave_sreg is
	signal RX_DATA_i		: std_logic_vector(7 downto 0) := x"00";
	signal BIT_CNT			: std_logic_vector(3 downto 0) := "0000";
	signal BIT_ACK			: std_logic;
	signal BIT_DATA		: std_logic;
begin

	RX_DATA <= RX_DATA_i;

	BIT_ACK <= '1' when BIT_CNT = "1000" else '0';
	BIT_DATA <= '1' when BIT_CNT < "1000" else '0';
	DONE <= '1' when BIT_CNT > "1000" else '0';

	process(CLK)
	begin
		if rising_edge(CLK) then
			if (TX_DATA_EN = '0') and (RX_DATA_EN = '0') then
				BIT_CNT <= (others=>'0');
			elsif SCL_FILT_F = '1' then
				BIT_CNT <= BIT_CNT + 1;
			end if;
		end if;
	end process;

	process(TX_DATA_EN, BIT_CNT, TX_DATA, RX_DATA_EN, BIT_ACK, RX_ACK_EN, SLAVE_ADR_EN, RX_DATA_i, SLAVE_ADR)
	begin
		SDA_OUT <= '1';	-- Release SDA

		if TX_DATA_EN = '1' then
			if BIT_DATA = '1' then
				SDA_OUT <= TX_DATA(7-conv_integer(BIT_CNT(2 downto 0)));
			end if;
		elsif RX_DATA_EN = '1' then
			if (BIT_ACK = '1') and (RX_ACK_EN = '1') then
				SDA_OUT <= '0';	-- ACK
			elsif (BIT_ACK = '1') and (SLAVE_ADR_EN = '1') and (RX_DATA_i(7 downto 1) = SLAVE_ADR) then
				SDA_OUT <= '0';	-- ACK
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if (BIT_DATA = '1') and (SCL_FILT_R = '1') and (RX_DATA_EN = '1') then
				RX_DATA_i <= RX_DATA_i(6 downto 0) & SDA_FILT;
			end if;
		end if;
	end process;

end synthesis;
