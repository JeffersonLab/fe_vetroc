library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity SpiInterface is
	port(
		CLK			: in std_logic;
		
		WR_DATA		: in std_logic_vector(7 downto 0);
		RD_DATA		: out std_logic_vector(7 downto 0);
		NCS_SET		: in std_logic;
		NCS_CLEAR	: in std_logic;
		START			: in std_logic;
		DONE			: out std_logic;
		
		SPI_CLK		: out std_logic;
		SPI_MISO		: in std_logic;
		SPI_MOSI		: out std_logic;
		SPI_NCS		: out std_logic
	);
end SpiInterface;

architecture Synthesis of SpiInterface is
	signal BIT_CNT			: std_logic_vector(4 downto 0) := "00000";
	signal BIT_CNT_DONE	: std_logic;
	signal SHIFT_REG_TX	: std_logic_vector(7 downto 0) := "00000000";
	signal SHIFT_REG_EN	: std_logic;
	signal SHIFT_REG_RX	: std_logic_vector(7 downto 0) := "00000000";
	signal NCS				: std_logic;
		
	attribute iob: string;
	attribute iob of SPI_CLK	: signal is "TRUE";
	attribute iob of SPI_MISO	: signal is "TRUE";
	attribute iob of SPI_MOSI	: signal is "TRUE";
	attribute iob of SPI_NCS	: signal is "TRUE";
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			SPI_MOSI <= SHIFT_REG_TX(7);
			SPI_CLK <= BIT_CNT(0);
			DONE <= BIT_CNT_DONE;
			RD_DATA <= SHIFT_REG_RX;
			SPI_NCS <= NCS;
		end if;
	end process;
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			if NCS_CLEAR = '1' then
				NCS <= '0';
			elsif NCS_SET = '1' then
				NCS <= '1';
			end if;
		end if;
	end process;
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			if START = '1' then
				SHIFT_REG_TX <= WR_DATA;
			elsif SHIFT_REG_EN = '1' then
				SHIFT_REG_TX <= SHIFT_REG_TX(6 downto 0) & '0'; 
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if SHIFT_REG_EN = '1' then
				SHIFT_REG_RX <= SHIFT_REG_RX(6 downto 0) & SPI_MISO; 
			end if;
		end if;
	end process;

	SHIFT_REG_EN <= BIT_CNT(0) and not BIT_CNT_DONE;
	
	BIT_CNT_DONE <= '1' when BIT_CNT = conv_std_logic_vector(0, BIT_CNT'length) else '0';
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			if START = '1' then
				BIT_CNT <= "10000";
			elsif BIT_CNT_DONE /= '1' then
				BIT_CNT <= BIT_CNT - 1; 
			end if;
		end if;
	end process;	

end Synthesis;
