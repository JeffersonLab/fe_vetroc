library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library modelsim_lib;
use modelsim_lib.util.all;

library utils;
use utils.utils_pkg.all;

use work.gtp_pkg.all;

entity gtp_wrapper_tb is
	generic(
		PMA_DIRECT				: std_logic_vector(7 downto 0) := x"55"
	);
end gtp_wrapper_tb;

architecture testbench of gtp_wrapper_tb is

	component aurora_5G_wrapper is
		generic(
			STARTING_CHANNEL_NUMBER		: natural;
			PMA_DIRECT						: std_logic := '0';
			SIM_GTXRESET_SPEEDUP			: integer := 0
		);
		port(
			CLK					: in std_logic;

			-- TX Stream Interface
			TX_D					: in std_logic_vector(31 downto 0);
			TX_SRC_RDY_N		: in std_logic;
			TX_DST_RDY_N		: out std_logic;

			-- RX Stream Interface
			RX_D					: out std_logic_vector(31 downto 0);
			RX_SRC_RDY_N		: out std_logic;

			-- GTX Serial I/O
			RXP					: in std_logic_vector(0 to 1);
			TXP					: out std_logic_vector(0 to 1);

			--GTX Reference Clock Interface
			GTXD0					: in std_logic;

			--SIV Specific
			CLK50					: in std_logic;
			CAL_BLK_POWERDOWN	: in std_logic;
			CAL_BLK_BUSY		: in std_logic;
			RECONFIG_FROMGXB	: out std_logic_vector(67 downto 0);
			RECONFIG_TOGXB		: in std_logic_vector(3 downto 0);

			-- Registers
			GXB_CTRL				: in std_logic_vector(31 downto 0);
			GXB_STATUS			: out std_logic_vector(31 downto 0);
			GXB_ERR_TILE		: out std_logic_vector(31 downto 0);
			GXB_ERR				: out std_logic

		);
	end component;

	constant GLOBAL_CLK_PER	: time := 4 ns;

	type VXS_SERDES_PAIR is array(natural range <>) of std_logic_vector(0 to 1);

	signal RXP					: VXS_SERDES_PAIR(7 downto 0);
	signal TXP					: VXS_SERDES_PAIR(7 downto 0);

	signal CLK50				: std_logic;
	signal GXB_CTRL			: std_logic_vector(31 downto 0);
	signal TX_D					: slv32a(7 downto 0);
	signal TX_SRC_RDY_N		: std_logic_vector(7 downto 0);
	signal TX_DST_RDY_N		: std_logic_vector(7 downto 0);

	-- TI/SD Signals
	signal GLOBAL_CLK			: std_logic;
	signal SYNC					: std_logic;
	signal TRIG					: std_logic;

	-- VME bus signals
--	constant VME_GEO			: int_array(0 to 13) := (9,12,8,13,7,14,6,15,5,16,4,17,3,18);

	signal VMEBUS_DS_N		: std_logic_vector(1 downto 0);
	signal VMEBUS_AS_N		: std_logic;
	signal VMEBUS_W_N			: std_logic;
	signal VMEBUS_AM			: std_logic_vector(5 downto 0);
	signal VMEBUS_D			: std_logic_vector(31 downto 0);
	signal VMEBUS_A			: std_logic_vector(31 downto 0);
	signal VMEBUS_BERR_N		: std_logic;
	signal VMEBUS_DTACK_N	: std_logic;
begin
	
	process
	begin
		GLOBAL_CLK <= '0';
		wait for GLOBAL_CLK_PER / 2;
		GLOBAL_CLK <= '1';
		wait for GLOBAL_CLK_PER / 2;
	end process;

	process
	begin
		CLK50 <= '0';
		wait for 10 ns;
		CLK50 <= '1';
		wait for 10 ns;
	end process;

	gtp_wrapper_inst: gtp_wrapper
		port map(
			GLOBAL_CLK		=> GLOBAL_CLK,
			SYNC				=> SYNC,
			TRIG				=> TRIG,
			VMEBUS_DS_N		=> VMEBUS_DS_N,
			VMEBUS_AS_N		=> VMEBUS_AS_N,
			VMEBUS_W_N		=> VMEBUS_W_N,
			VMEBUS_AM		=> VMEBUS_AM,
			VMEBUS_D			=> VMEBUS_D,
			VMEBUS_A			=> VMEBUS_A,
			VMEBUS_BERR_N	=> VMEBUS_BERR_N,
			VMEBUS_DTACK_N	=> VMEBUS_DTACK_N,
			PP1_RX			=> TXP(0),	--TOF
			PP1_TX			=> RXP(0),
			PP2_RX			=> "00",
			PP2_TX			=> open,
			PP3_RX			=> TXP(1),	--ST
			PP3_TX			=> RXP(1),
			PP4_RX			=> "00",
			PP4_TX			=> open,
			PP5_RX			=> TXP(2),	--PS
			PP5_TX			=> RXP(2),
			PP6_RX			=> "00",
			PP6_TX			=> open,
			PP7_RX			=> TXP(3),	--TAGH
			PP7_TX			=> RXP(3),
			PP8_RX			=> "00",
			PP8_TX			=> open,
			PP9_RX			=> TXP(4),	--TAGM
			PP9_TX			=> RXP(4),
			PP10_RX			=> "00",
			PP10_TX			=> open,
			PP11_RX			=> TXP(5),	--FCAL
			PP11_TX			=> RXP(5),
			PP12_RX			=> "00",
			PP12_TX			=> open,
			PP13_RX			=> TXP(6),	--FCAL
			PP13_TX			=> RXP(6),
			PP14_RX			=> "00",
			PP14_TX			=> open,
			PP15_RX			=> TXP(7),	--BCAL
			PP15_TX			=> RXP(7),
			PP16_RX			=> "00",
			PP16_TX			=> open
		);

	vxs_ser_gen: for I in 0 to 7 generate
		aurora_5G_wrapper_inst: aurora_5G_wrapper
			generic map(
				STARTING_CHANNEL_NUMBER => 0,
				PMA_DIRECT					=> PMA_DIRECT(I),
				SIM_GTXRESET_SPEEDUP		=> 1
			)
			port map(
				CLK					=> GLOBAL_CLK,
				TX_D					=> TX_D(I),
				TX_SRC_RDY_N		=> TX_SRC_RDY_N(I),
				TX_DST_RDY_N		=> TX_DST_RDY_N(I),
				RX_D					=> open,
				RX_SRC_RDY_N		=> open,
				RXP					=> RXP(I),
				TXP					=> TXP(I),
				GTXD0					=> GLOBAL_CLK,
				CLK50					=> CLK50,
				CAL_BLK_POWERDOWN	=> '0',
				CAL_BLK_BUSY		=> '0',
				RECONFIG_FROMGXB	=> open,
				RECONFIG_TOGXB		=> "0000",
				GXB_CTRL				=> GXB_CTRL,
				GXB_STATUS			=> open,
				GXB_ERR_TILE		=> open,
				GXB_ERR				=> open
			);
	end generate;

	process
		variable cnt	: integer := 0;
	begin
		while true loop
			wait until rising_edge(GLOBAL_CLK);
			if SYNC = '1' then
				cnt := 0;
				TX_SRC_RDY_N <= "11111111";
				TX_D <= (others=>(others=>'0'));
			else
				cnt := (cnt + 1) mod 1000;
				TX_SRC_RDY_N <= "00000000";

				if cnt = 0 then
					TX_D <= (others=>x"FFFFFFFF");
				else
					TX_D <= (others=>x"00000000");
				end if;

-- 				--TOF
-- 				TX_D(0) <= conv_std_logic_vector(cnt mod 65536, 16) &
-- 				           conv_std_logic_vector(cnt mod 65536, 16);
-- 				--ST
-- 				TX_D(1) <= conv_std_logic_vector(cnt, 32);
-- 
-- 				--PS
-- 				TX_D(2) <= conv_std_logic_vector(cnt mod 65536, 32);
-- 
-- 				--TAGH
-- 				TX_D(3) <= conv_std_logic_vector(cnt, 32);
-- 
-- 				--TAGM
-- 				TX_D(4) <= conv_std_logic_vector(cnt, 32);
-- 
-- 				--FCAL
-- 				TX_D(5) <= conv_std_logic_vector(cnt, 32);
-- 				TX_D(6) <= conv_std_logic_vector(cnt, 32);
-- 
-- 				--BCAL
-- 				TX_D(7)(23 downto 0) <= conv_std_logic_vector(cnt, 24);
-- 				TX_D(7)(31 downto 24) <= conv_std_logic_vector(cnt, 8);

			end if;
		end loop;
	end process;


	process
	begin
		GXB_CTRL <= x"00000001";
		wait for 1 us;
		GXB_CTRL <= x"00000000";
		wait;
	end process;

	process
		constant AM_A24_NP_DATA			: std_logic_vector(5 downto 0) := "111001";
		constant AM_A24_SP_DATA			: std_logic_vector(5 downto 0) := "111101";
		constant AM_A32_NP_DATA			: std_logic_vector(5 downto 0) := "001001";
		constant AM_A32_SP_DATA			: std_logic_vector(5 downto 0) := "001101";
	
		procedure VMEWrite32(Address : in std_logic_vector(31 downto 0); Data : in std_logic_vector(31 downto 0)) is
			variable I 		: integer;
		begin
			VMEBUS_A <= Address;
			VMEBUS_D <= Data;
			VMEBUS_AM <= AM_A24_NP_DATA;
			VMEBUS_W_N <= '0';
			wait for 10 ns;
			
			VMEBUS_AS_N <= '0';
			wait for 5 ns;
			VMEBUS_DS_N <= "00";
			wait for 5 ns;			

			I := 0;
			while (I < 1000) and To_X01(VMEBUS_DTACK_N) = '1' and To_X01(VMEBUS_BERR_N) = '1' loop
				I := I + 1;
				wait for 5 ns;
			end loop;
			
			VMEBUS_D <= (others=>'H');
			VMEBUS_AS_N <= '1';
			VMEBUS_DS_N <= "11";
			
			wait until To_X01(VMEBUS_DTACK_N) = '1';
			wait for 60 ns;
		end procedure;
		
		procedure VMERead32(Address : in std_logic_vector(31 downto 0); Data : out std_logic_vector(31 downto 0)) is
			variable I 		: integer;
		begin
			VMEBUS_A <= Address;
			VMEBUS_AM <= AM_A24_NP_DATA;
			VMEBUS_W_N <= '1';
			wait for 10 ns;
			
			VMEBUS_AS_N <= '0';
			wait for 5 ns;
			VMEBUS_DS_N <= "00";
			wait for 5 ns;

			I := 0;
			while (I < 1000) and To_X01(VMEBUS_DTACK_N) = '1' and To_X01(VMEBUS_BERR_N) = '1' loop
				I := I + 1;
				wait for 5 ns;
			end loop;
			
			Data := VMEBUS_D;
			VMEBUS_AS_N <= '1';
			VMEBUS_DS_N <= "11";
			
			wait until To_X01(VMEBUS_DTACK_N) = '1';
			wait for 60 ns;
		end procedure;

	--	function DCRB_BASE_PP(payload : integer) return std_logic_vector is
	--	begin
	--		return conv_std_logic_vector(VME_GEO(payload-1) * 8, 16);
	--	end DCRB_BASE_PP;

		constant GTP_BASE			: std_logic_vector(15 downto 0) := x"0000";
	--	constant DCRB_PP1_BASE	: std_logic_vector(15 downto 0) := conv_std_logic_vector(VME_GEO(0) * 8, 16);

		variable ReadData			: std_logic_vector(31 downto 0);
		variable offset			: std_logic_vector(31 downto 0);
	begin
		SYNC <= '1';
		TRIG <= '0';

		VMEBUS_DS_N <= "11";
		VMEBUS_AS_N <= '1';
		VMEBUS_W_N <= '1';
		VMEBUS_AM <= "000000";
		VMEBUS_D <= (others=>'H');
		VMEBUS_A <= (others=>'H');
		VMEBUS_BERR_N <= 'H';
		VMEBUS_DTACK_N <= 'H';
		wait for 2 us;
		VMEWrite32(GTP_BASE & x"0100", x"80000000");
		VMEWrite32(GTP_BASE & x"0100", x"00000000");
		wait for 1 us;

		-- route VXS SYNC to internal SYNC
		VMEWrite32(GTP_BASE & x"0324", x"00000002");

		-- Power up serdes
		VMEWrite32(GTP_BASE & x"0504", x"00000000");
		VMEWrite32(GTP_BASE & x"0604", x"00000000");

		-- Enable serdes channels
		VMEWrite32(GTP_BASE & x"1000", x"00000000");
		VMEWrite32(GTP_BASE & x"1200", x"00000000");
		VMEWrite32(GTP_BASE & x"1400", x"00000000");
		VMEWrite32(GTP_BASE & x"1600", x"00000000");
		VMEWrite32(GTP_BASE & x"1800", x"00000000");
		VMEWrite32(GTP_BASE & x"1A00", x"00000000");
		VMEWrite32(GTP_BASE & x"1C00", x"00000000");
		VMEWrite32(GTP_BASE & x"1E00", x"00000000");
		VMEWrite32(GTP_BASE & x"2400", x"00000000");

		-- Enable all trigger paths
		VMEWrite32(GTP_BASE & x"2000", x"000000FF");

		-- Trigger bit configuration

		--Triggerbit 0: BCALHitModules
		VMEWrite32(GTP_BASE & x"4000", x"00000003");	--TRG_CTRL_REG
		VMEWrite32(GTP_BASE & x"4004", x"00000300");	--TRIG_OUT_CTRL_REG: Latency = 768*4ns, Width=+0*4ns
		VMEWrite32(GTP_BASE & x"4014", x"00000001");	--BCAL_CTRL1_REG

		--Triggerbit 1: BFCAL
		VMEWrite32(GTP_BASE & x"4100", x"00000005");	--TRG_CTRL_REG
		VMEWrite32(GTP_BASE & x"4104", x"00000300");	--TRIG_OUT_CTRL_REG: Latency = 768*4ns, Width=+0*4ns
		VMEWrite32(GTP_BASE & x"4110", x"00000001");	--BCAL_CTRL0_REG
		VMEWrite32(GTP_BASE & x"4120", x"00000001");	--FCAL_CTRL_REG
		VMEWrite32(GTP_BASE & x"4130", x"00000001");	--BFCAL_CTRL_REG

		--Triggerbit 2: TAGM
		VMEWrite32(GTP_BASE & x"4200", x"00000009");	--TRG_CTRL_REG
		VMEWrite32(GTP_BASE & x"4204", x"00000300");	--TRIG_OUT_CTRL_REG: Latency = 768*4ns, Width=+0*4ns
		VMEWrite32(GTP_BASE & x"4270", x"FFFFFFFF");	--TAGM_CTRL_REG

		--Triggerbit 3: TAGH
		VMEWrite32(GTP_BASE & x"4300", x"00000011");	--TRG_CTRL_REG
		VMEWrite32(GTP_BASE & x"4304", x"00000300");	--TRIG_OUT_CTRL_REG: Latency = 768*4ns, Width=+0*4ns
		VMEWrite32(GTP_BASE & x"4374", x"FFFFFFFF");	--TAGH_CTRL_REG

		--Triggerbit 4: PS
		VMEWrite32(GTP_BASE & x"4400", x"00000021");	--TRG_CTRL_REG
		VMEWrite32(GTP_BASE & x"4404", x"00000300");	--TRIG_OUT_CTRL_REG: Latency = 768*4ns, Width=+0*4ns
		VMEWrite32(GTP_BASE & x"4440", x"0000FFFF");	--PS_CTRL_REG

		--Triggerbit 5: ST
		VMEWrite32(GTP_BASE & x"4500", x"00000041");	--TRG_CTRL_REG
		VMEWrite32(GTP_BASE & x"4504", x"00000300");	--TRIG_OUT_CTRL_REG: Latency = 768*4ns, Width=+0*4ns
		VMEWrite32(GTP_BASE & x"4550", x"FFFFFFFF");	--ST_CTRL0_REG
		VMEWrite32(GTP_BASE & x"4554", x"00000001");	--ST_CTRL1_REG

		--Triggerbit 6: TOF
		VMEWrite32(GTP_BASE & x"4600", x"00000081");	--TRG_CTRL_REG
		VMEWrite32(GTP_BASE & x"4604", x"00000300");	--TRIG_OUT_CTRL_REG: Latency = 768*4ns, Width=+0*4ns
		VMEWrite32(GTP_BASE & x"4660", x"FFFFFFFF");	--TOF_CTRL0_REG
		VMEWrite32(GTP_BASE & x"4664", x"00000001");	--TOF_CTRL1_REG

		wait for 8 us;
		SYNC <= '0';

		wait;		
	end process;

end testbench;
