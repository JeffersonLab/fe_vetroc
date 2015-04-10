library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library modelsim_lib;
use modelsim_lib.util.all;

entity fe_rich_wrapper is
	port(
		-- Trigger Interface
		GLOBAL_CLK		: in std_logic;
		SYNC				: in std_logic;
		TRIG				: in std_logic;

		-- VME Bus Interface
		VMEBUS_DS_N		: in std_logic_vector(1 downto 0);
		VMEBUS_AS_N		: in std_logic;
		VMEBUS_W_N		: in std_logic;
		VMEBUS_AM		: in std_logic_vector(5 downto 0);
		VMEBUS_D			: inout std_logic_vector(31 downto 0);
		VMEBUS_A			: inout std_logic_vector(31 downto 0);
		VMEBUS_BERR_N	: inout std_logic;
		VMEBUS_DTACK_N	: inout std_logic;
		
		-- TDC Inputs
		TDC_IN			: in std_logic_vector(191 downto 0)
	);
end fe_rich_wrapper;

architecture wrapper of fe_rich_wrapper is
	component fe_rich is
		port(
			-- System Clock
			CLK_30MHZ		: in std_logic;

			-- Fiber Interface
			FIBER_CLK_P		: in std_logic;
			FIBER_CLK_N		: in std_logic;

			FIBER_RX_P		: in std_logic;
			FIBER_RX_N		: in std_logic;

			FIBER_TX_P		: out std_logic;
			FIBER_TX_N		: out std_logic;

			FIBER_TX_DIS	: out std_logic;

			-- SPI Flash Inteface
			CONFIGROM_D		: out std_logic;
			CONFIGROM_Q		: in std_logic;
			CONFIGROM_S_N	: out std_logic;

			-- MAROC3 Discriminator Outputs
			MAROC_OUT_1		: in std_logic_vector(63 downto 0);
			MAROC_OUT_2		: in std_logic_vector(63 downto 0);
			MAROC_OUT_3		: in std_logic_vector(63 downto 0);

			-- MAROC3 Static Register Interface
			CK_SC				: out std_logic;
			RSTN_SC			: out std_logic;
			D_SC_1			: out std_logic;
			QBUF_SC_3		: in std_logic;

			-- MAROC3 Dynamic Register Interface
			CK_R				: out std_logic;
			RSTB_R			: out std_logic;
			D_R				: out std_logic;
			QBUF_R_1			: in std_logic;
			QBUF_R_2			: in std_logic;
			QBUF_R_3			: in std_logic;

			-- MAROC3 Misc I/O
			EN_OTAQ			: out std_logic;
			HOLD1				: out std_logic;
			HOLD2				: out std_logic;
			OR_1_0			: in std_logic;
			OR_1_1			: in std_logic;
			OR_2_0			: in std_logic;
			OR_2_1			: in std_logic;
			OR_3_0			: in std_logic;
			OR_3_1			: in std_logic;
			CTEST				: out std_logic;

			-- Test/user I/O
			INPUT_1			: in std_logic;
			INPUT_2			: in std_logic;
			INPUT_3			: in std_logic;
			OUTPUT_1			: out std_logic;
			OUTPUT_2			: out std_logic;
			OUTPUT_3			: out std_logic
		);
	end component;

	signal CLK_30MHZ		: std_logic := '0';
	signal FIBER_CLK_P	: std_logic := '0';
	signal FIBER_CLK_N	: std_logic := '1';
	signal FIBER_RX_P		: std_logic := '0';
	signal FIBER_RX_N		: std_logic := '1';
	signal FIBER_TX_P		: std_logic := '0';
	signal FIBER_TX_N		: std_logic := '1';
	signal FIBER_TX_DIS	: std_logic := '0';
	signal CONFIGROM_D	: std_logic := '0';
	signal CONFIGROM_Q	: std_logic := '0';
	signal CONFIGROM_S_N	: std_logic := '0';
	signal MAROC_OUT_1	: std_logic_vector(63 downto 0) := (others=>'0');
	signal MAROC_OUT_2	: std_logic_vector(63 downto 0) := (others=>'0');
	signal MAROC_OUT_3	: std_logic_vector(63 downto 0) := (others=>'0');
	signal CK_SC			: std_logic := '0';
	signal RSTN_SC			: std_logic := '0';
	signal D_SC_1			: std_logic := '0';
	signal QBUF_SC_3		: std_logic := '0';
	signal CK_R				: std_logic := '0';
	signal RSTB_R			: std_logic := '0';
	signal D_R				: std_logic := '0';
	signal QBUF_R_1		: std_logic := '0';
	signal QBUF_R_2		: std_logic := '0';
	signal QBUF_R_3		: std_logic := '0';
	signal EN_OTAQ			: std_logic := '0';
	signal HOLD1			: std_logic := '0';
	signal HOLD2			: std_logic := '0';
	signal OR_1_0			: std_logic := '0';
	signal OR_1_1			: std_logic := '0';
	signal OR_2_0			: std_logic := '0';
	signal OR_2_1			: std_logic := '0';
	signal OR_3_0			: std_logic := '0';
	signal OR_3_1			: std_logic := '0';
	signal CTEST			: std_logic := '0';
	signal INPUT_1			: std_logic := '0';
	signal INPUT_2			: std_logic := '0';
	signal INPUT_3			: std_logic := '0';
	signal OUTPUT_1		: std_logic := '0';
	signal OUTPUT_2		: std_logic := '0';
	signal OUTPUT_3		: std_logic := '0';

	-- Signal Spy Mirrors
	signal GCLK_125_REF_RST			: std_logic := '0';
	signal GCLK_125_REF				: std_logic := '0';
	signal BUS_RESET					: std_logic := '1';
	signal BUS_DIN						: std_logic_vector(31 downto 0) := (others=>'0');
	signal BUS_DOUT					: std_logic_vector(31 downto 0) := (others=>'0');
	signal BUS_WR						: std_logic := '0';
	signal BUS_RD						: std_logic := '0';
	signal BUS_ACK						: std_logic := '0';
	signal BUS_ADDR					: std_logic_vector(15 downto 0) := (others=>'0');
begin

	fe_rich_inst: fe_rich
		port map(
			CLK_30MHZ		=> CLK_30MHZ,
			FIBER_CLK_P		=> FIBER_CLK_P,
			FIBER_CLK_N		=> FIBER_CLK_N,
			FIBER_RX_P		=> FIBER_RX_P,
			FIBER_RX_N		=> FIBER_RX_N,
			FIBER_TX_P		=> FIBER_TX_P,
			FIBER_TX_N		=> FIBER_TX_N,
			FIBER_TX_DIS	=> FIBER_TX_DIS,
			CONFIGROM_D		=> CONFIGROM_D,
			CONFIGROM_Q		=> CONFIGROM_Q,
			CONFIGROM_S_N	=> CONFIGROM_S_N,
			MAROC_OUT_1		=> MAROC_OUT_1,
			MAROC_OUT_2		=> MAROC_OUT_2,
			MAROC_OUT_3		=> MAROC_OUT_3,
			CK_SC				=> CK_SC,
			RSTN_SC			=> RSTN_SC,
			D_SC_1			=> D_SC_1,
			QBUF_SC_3		=> QBUF_SC_3,
			CK_R				=> CK_R,
			RSTB_R			=> RSTB_R,
			D_R				=> D_R,
			QBUF_R_1			=> QBUF_R_1,
			QBUF_R_2			=> QBUF_R_2,
			QBUF_R_3			=> QBUF_R_3,
			EN_OTAQ			=> EN_OTAQ,
			HOLD1				=> HOLD1,
			HOLD2				=> HOLD2,
			OR_1_0			=> OR_1_0,
			OR_1_1			=> OR_1_1,
			OR_2_0			=> OR_2_0,
			OR_2_1			=> OR_2_1,
			OR_3_0			=> OR_3_0,
			OR_3_1			=> OR_3_1,
			CTEST				=> CTEST,
			INPUT_1			=> INPUT_1,
			INPUT_2			=> INPUT_2,
			INPUT_3			=> INPUT_3,
			OUTPUT_1			=> OUTPUT_1,
			OUTPUT_2			=> OUTPUT_2,
			OUTPUT_3			=> OUTPUT_3
		);

	process
	begin
		CLK_30MHZ <= '0';
		wait for 16.666 ns;
		CLK_30MHZ <= '1';
		wait for 16.666 ns;
	end process;

	process
	begin
		GCLK_125_REF_RST <= '1';
		wait for 100 ns;
		wait until rising_edge(GLOBAL_CLK);
		GCLK_125_REF_RST <= '0';
		wait;
	end process;

	GCLK_125_REF <= GLOBAL_CLK;

	INPUT_1 <= TRIG;
	INPUT_2 <= transport TRIG after 500 ns;
--	SYNC				: in std_logic;

 	process
 	begin
		-- monitored in tb
 		init_signal_spy("fe_rich_inst/BUS_DOUT","BUS_DOUT", 1);
 		init_signal_spy("fe_rich_inst/BUS_ACK","BUS_ACK", 1);

		init_signal_driver("GCLK_125_REF_RST", "fe_rich_inst/GCLK_125_REF_RST");
		init_signal_driver("GCLK_125_REF", "fe_rich_inst/GCLK_125_REF");
		init_signal_driver("BUS_RESET", "fe_rich_inst/BUS_RESET");
		init_signal_driver("BUS_DIN", "fe_rich_inst/BUS_DIN");
		init_signal_driver("BUS_WR", "fe_rich_inst/BUS_WR");
		init_signal_driver("BUS_RD", "fe_rich_inst/BUS_RD");
		init_signal_driver("BUS_ADDR", "fe_rich_inst/BUS_ADDR");

 		wait;
 	end process;

	process
		procedure WriteReg(
				addr : in std_logic_vector(15 downto 0);
				data : in std_logic_vector(31 downto 0)
			) is
		begin
			BUS_ADDR <= addr;
			BUS_DIN <= data;
			wait for 40 ns;
			BUS_WR <= '1';
			wait for 200 ns;
			BUS_WR <= '0';
		end WriteReg;

		procedure ReadReg(
				addr : in std_logic_vector(15 downto 0);
				signal data : out std_logic_vector(31 downto 0)
			) is
		begin
			BUS_ADDR <= addr;
			wait for 400 ns;
			BUS_RD <= '1';
			wait for 200 ns;
			data <= BUS_DOUT;
			wait for 10 ns;
			BUS_RD <= '0';
		end ReadReg;
	begin
		BUS_RESET <= '1';
		BUS_DIN <= (others=>'0');
		BUS_WR <= '0';
		BUS_RD <= '0';
		BUS_ADDR <= (others=>'0');

		VMEBUS_D <= (others=>'H');
		VMEBUS_A <= (others=>'H');
		VMEBUS_BERR_N <= 'H';
		VMEBUS_DTACK_N <= 'H';

		wait for 1 us;
		BUS_RESET <= '0';

		while true loop
			wait until falling_edge(VMEBUS_AS_N);

			if VMEBUS_A(31 downto 16) = x"0000" then
				if VMEBUS_W_N = '1' then
					ReadReg(VMEBUS_A(15 downto 0), VMEBUS_D);
				else
					WriteReg(VMEBUS_A(15 downto 0), VMEBUS_D);
				end if;
				VMEBUS_DTACK_N <= '0';
			end if;

			wait until to_X01(VMEBUS_AS_N) = '1';
			VMEBUS_D <= (others=>'H');
			VMEBUS_DTACK_N <= 'H';
		end loop;

	end process;

	MAROC_OUT_1 <= TDC_IN(63 downto 0);
	MAROC_OUT_2 <= TDC_IN(127 downto 64);
	MAROC_OUT_3 <= TDC_IN(191 downto 128);

end wrapper;
