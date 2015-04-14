library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SramCntrl is
	port(
		-- SRAM clock source
		CLK				: in std_logic;
		RESET				: in std_logic;
	
		-- SRAM Phy Signals
		SRAM_CLK			: out std_logic;
		SRAM_CLK_O		: out std_logic;
		SRAM_CLK_I		: in std_logic;
		SRAM_D			: inout std_logic_vector(35 downto 0);
		SRAM_A			: out std_logic_vector(18 downto 0);
		SRAM_RW			: out std_logic;
		SRAM_NOE			: out std_logic;
		SRAM_CS			: out std_logic;
		SRAM_ADV			: out std_logic;		
		
		-- SRAM User Signals
		USER_CLK			: out std_logic;
		USER_WRITE		: in std_logic;
		USER_ADDR		: in std_logic_vector(18 downto 0);
		USER_RD_DATA	: out std_logic_vector(35 downto 0);
		USER_WR_DATA	: in std_logic_vector(35 downto 0)
	);
end SramCntrl;

architecture Synthesis of SramCntrl is
	component SramClk is
		port(
			CLK			: in std_logic;
			RESET			: in std_logic;
			
			SRAM_CLK		: out std_logic;
			SRAM_CLK_O	: out std_logic;
			SRAM_CLK_I	: in std_logic;
			
			USER_CLK		: out std_logic
		);
	end component;

	component SramIo is
		port(
			CLK			: in std_logic;
			
			SRAM_D		: inout std_logic_vector(35 downto 0);
			SRAM_A		: out std_logic_vector(18 downto 0);
			SRAM_RW		: out std_logic;
			SRAM_NOE		: out std_logic;
			SRAM_CS		: out std_logic;
			SRAM_ADV		: out std_logic;
			
			D_I			: out std_logic_vector(35 downto 0);
			D_O			: in std_logic_vector(35 downto 0);
			D_T			: in std_logic;
			A				: in std_logic_vector(18 downto 0);
			RNW			: in std_logic
		);
	end component;
	
	signal D_T				: std_logic;
	signal RNW				: std_logic;
	signal USER_CLK_i		: std_logic;
begin

	USER_CLK <= USER_CLK_i;

	RNW <= not USER_WRITE;
	D_T <= not USER_WRITE;
	
	SramClk_inst: SramClk
		port map(
			CLK			=> CLK,
			RESET			=> RESET,
			SRAM_CLK		=> SRAM_CLK,
			SRAM_CLK_O	=> SRAM_CLK_O,
			SRAM_CLK_I	=> SRAM_CLK_I,
			USER_CLK		=> USER_CLK_i
		);

	SramIo_inst: SramIo
		port map(
			CLK			=> USER_CLK_i,
			SRAM_D		=> SRAM_D,
			SRAM_A		=> SRAM_A,
			SRAM_RW		=> SRAM_RW,
			SRAM_NOE		=> SRAM_NOE,
			SRAM_CS		=> SRAM_CS,
			SRAM_ADV		=> SRAM_ADV,
			D_I			=> USER_RD_DATA,
			D_O			=> USER_WR_DATA,
			D_T			=> D_T,
			A				=> USER_ADDR,
			RNW			=> RNW
		);
	
end Synthesis;
