library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

library utils;
use utils.utils_pkg.all;

entity spiflash is
	port(
		CLK				: in std_logic;

		WR_DATA			: in std_logic_vector(7 downto 0);
		RD_DATA			: out std_logic_vector(7 downto 0);
		NCS_SET			: in std_logic;
		NCS_CLEAR		: in std_logic;
		START				: in std_logic;
		DONE				: out std_logic;

		CONFIGROM_D		: out std_logic;
		CONFIGROM_Q		: in std_logic;
		CONFIGROM_S_N	: out std_logic
	);
end spiflash;

architecture synthesis of spiflash is
	signal SPI_CLK		: std_logic;
begin

	STARTUPE2_inst: STARTUPE2
		generic map(
			PROG_USR			=> "FALSE"
		)
		port map(
			CFGCLK		=> open,
			CFGMCLK		=> open,
			EOS			=> open,
			PREQ			=> open,
			CLK			=> '0',
			GSR			=> '0',
			GTS			=> '0',
			KEYCLEARB	=> '1',
			PACK			=> '0',
			USRCCLKO		=> SPI_CLK,
			USRCCLKTS	=> '0',
			USRDONEO		=> '1',
			USRDONETS	=> '0'
		);

	SpiInterface_inst: SpiInterface
		port map(
			CLK			=> CLK,
			WR_DATA		=> WR_DATA,
			RD_DATA		=> RD_DATA,
			NCS_SET		=> NCS_SET,
			NCS_CLEAR	=> NCS_CLEAR,
			START			=> START,
			DONE			=> DONE,
			SPI_CLK		=> SPI_CLK,
			SPI_MISO		=> CONFIGROM_Q,
			SPI_MOSI		=> CONFIGROM_D,
			SPI_NCS		=> CONFIGROM_S_N
		);

end synthesis;
