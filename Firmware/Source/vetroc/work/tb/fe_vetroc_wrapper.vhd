library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library std;
use std.standard.all;

library utils;
use utils.utils_pkg.all;

entity fe_vetroc_wrapper is
	generic(
		READOUT_EN		: std_logic := '0';
		GTX_QUICKSIM	: boolean := false
	);
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

		-- CTP Signals
		GTP_RX			: in std_logic_vector(0 to 1);
		GTP_TX			: out std_logic_vector(0 to 1);		
		
		-- TDC Inputs
		TDC_IN			: in std_logic_vector(127 downto 0)
	);
end fe_vetroc_wrapper;

architecture wrapper of fe_vetroc_wrapper is

	component fe_vetroc is
		generic(
			SIM_GTRESET_SPEEDUP	: string := "FALSE"
		);
		port(
			-- VME BUS Interface
			A_CLKAB		: out std_logic;
			A_CLKBA		: out std_logic;
			A_DIR			: out std_logic;
			A_LE			: out std_logic;
			A_OE_N		: out std_logic;
			A				: inout std_logic_vector(31 downto 0);
			AM				: in std_logic_vector(5 downto 0);
		
			D_CLKAB		: out std_logic;
			D_CLKBA		: out std_logic;
			D_DIR			: out std_logic;
			D_LE			: out std_logic;
			D_OE_N		: out std_logic;
			D				: inout std_logic_vector(31 downto 0);

			SYSRESET_N	: in std_logic;
			SYSRST_EN	: out std_logic;
			SYSFAIL_EN	: out std_logic;
			SYSFAIL_N	: in std_logic;
			BUSY_EN		: out std_logic;
			BUSY_N		: in std_logic;
			BUSRQ_EN		: out std_logic;
			RETRY_N		: in std_logic;
			RETRY_OE		: out std_logic;
			WRITE_EN		: out std_logic;
			WRITE_N		: in std_logic;

			AS_EN			: out std_logic;
			AS_N			: in std_logic;
			BERR_EN		: out std_logic;
			BERR_N		: in std_logic;
			BG3IN_N		: in std_logic;
			BG3OUT_EN	: out std_logic;
			DS0_EN		: out std_logic;
			DS0_N			: in std_logic;
			DS1_EN		: out std_logic;
			DS1_N			: in std_logic;
			DTACK_EN		: out std_logic;
			DTACK_FPGA	: out std_logic;
			DTACK_N		: in std_logic;
			GA_N			: in std_logic_vector(4 downto 0);
			GAP_N			: in std_logic;
			IACK_EN		: out std_logic;
			IACK_I_N		: in std_logic;
			IACK_N		: in std_logic;
			IACK_O_EN	: out std_logic;
			
			IRQ_N			: out std_logic_vector(7 downto 1);
			IRQOE_N		: out std_logic;

			-- VME P2 Expansion
			VMERA			: in std_logic_vector(28 downto 1);
			VMERC			: in std_logic_vector(28 downto 1);
			VMERD			: in std_logic_vector(8 downto 1);
			VMERZ			: in std_logic_vector(16 downto 1);

			-- Front Panel Inteface
			FPAIN			: in std_logic_vector(32 downto 1);
			FPBIN			: in std_logic_vector(32 downto 1);
			FPCIN			: in std_logic_vector(32 downto 1);
			FPDIN			: in std_logic_vector(32 downto 1);

			FP6ID			: in std_logic_vector(2 downto 0);
			FP6OE			: out std_logic;
			FP6SEL		: out std_logic;
			FP7ID			: in std_logic_vector(2 downto 0);
			FP7OE			: out std_logic;
			FP7SEL		: out std_logic;

			FPGAIN		: in std_logic_vector(8 downto 1);
			FPGAOUT		: out std_logic_vector(8 downto 1);
			
			LEDA			: out std_logic_vector(8 downto 1);

			-- SRAM
			MEMA			: out std_logic_vector(19 downto 0);
			MEMCE2		: out std_logic;
			MEMCLK		: out std_logic;
			MEMD			: inout std_logic_vector(17 downto 0);
			MEMLDB		: out std_logic;
			MEMRWB		: out std_logic;
			CLKLOOP_O	: out std_logic;
			CLKLOOP_I	: in std_logic;


			-- Flash Memory
			PMEMCE_N		: out std_logic;
			PMEMD0		: inout std_logic;
			PMEMD1		: inout std_logic;
			PMEMD2		: inout std_logic;
			PMEMD3		: inout std_logic;

			-- VXS Interface
			TOKENFI		: in std_logic;
			TOKENFO		: out std_logic;
			SYNCFI		: in std_logic;
			TRIG1F		: in std_logic;
			TRIG2F		: in std_logic;
			TRIGFO		: out std_logic;
			SDLINKF		: out std_logic;
			STATA_IN		: in std_logic;
			STATA_OUT	: out std_logic;
			STATB_IN		: in std_logic;
			BUSY_OUT		: out std_logic;
			
			CLKREFA_P	: in std_logic;
			CLKREFA_N	: in std_logic;
			
			CTPRX_P		: in std_logic_vector(3 to 4);
			CTPRX_N		: in std_logic_vector(3 to 4);
			CTPTX_P		: out std_logic_vector(3 to 4);
			CTPTX_N		: out std_logic_vector(3 to 4);

			-- Clocks & Config
			CLK125F_P	: in std_logic;	-- Note: labeled CLK250F_P on schematic
			CLK125F_N	: in std_logic;	-- Note: labeled CLK250F_N on schematic
			
			CLKPRGC		: in std_logic;

			PCLKLOAD		: out std_logic;
			PCLKOUT1		: out std_logic;
			PCLKOUT2		: out std_logic;
			PCLKSIN1		: out std_logic;
			PCLKSIN2		: out std_logic;
			PCSWCFG		: out std_logic;

			-- Dip switches
			SWA			: in std_logic_vector(23 downto 19);
			SWM1			: in std_logic;
			CLKSELX1		: in std_logic;
			CLKSELX2		: in std_logic

			-- Fiber Transeivers
	-- 		FIBERICK		: inout std_logic;
	-- 		FIBERICKB	: inout std_logic;
	-- 		FIBERIDATA	: inout std_logic;
	-- 		FIBERIDATAB	: inout std_logic;
	-- 		FIBERRST		: out std_logic;
	-- 		FIBERRSTB	: out std_logic;
	-- 		MODINTA		: in std_logic;
	-- 		MODINTB		: in std_logic;
	-- 		MODPRSTA		: in std_logic;
	-- 		MODPRSTB		: in std_logic;
	-- 		TIAMSEL		: out std_logic;
	-- 		TIBMSEL		: out std_logic;
	-- 		
	-- 		SYNCODEI_P	: in std_logic;
	-- 		SYNCODEI_N	: in std_logic;
	-- 		
	-- 		SYNCODEO_P	: in std_logic;
	-- 		SYNCODEO_N	: in std_logic

			-- Connects to nothing
	--		MEMOE#
	--		MEMWE#
	--		
		);
	end component;

	signal A_CLKAB			: std_logic;
	signal A_CLKBA			: std_logic;
	signal A_DIR			: std_logic;
	signal A_LE				: std_logic;
	signal A_OE_N			: std_logic;
	signal A					: std_logic_vector(31 downto 0);
	signal AM				: std_logic_vector(5 downto 0);	
	signal D_CLKAB			: std_logic;
	signal D_CLKBA			: std_logic;
	signal D_DIR			: std_logic;
	signal D_LE				: std_logic;
	signal D_OE_N			: std_logic;
	signal D					: std_logic_vector(31 downto 0);
	signal SYSRESET_N		: std_logic;
	signal SYSRST_EN		: std_logic;
	signal SYSFAIL_EN		: std_logic;
	signal SYSFAIL_N		: std_logic;
	signal BUSY_EN			: std_logic;
	signal BUSY_N			: std_logic;
	signal BUSRQ_EN		: std_logic;
	signal RETRY_N			: std_logic;
	signal RETRY_OE		: std_logic;
	signal WRITE_EN		: std_logic;
	signal WRITE_N			: std_logic;
	signal AS_EN			: std_logic;
	signal AS_N				: std_logic;
	signal BERR_EN			: std_logic;
	signal BERR_N			: std_logic;
	signal BG3IN_N			: std_logic;
	signal BG3OUT_EN		: std_logic;
	signal DS0_EN			: std_logic;
	signal DS0_N			: std_logic;
	signal DS1_EN			: std_logic;
	signal DS1_N			: std_logic;
	signal DTACK_EN		: std_logic;
	signal DTACK_FPGA		: std_logic;
	signal DTACK_N			: std_logic;
	signal GA_N				: std_logic_vector(4 downto 0);
	signal GAP_N			: std_logic;
	signal IACK_EN			: std_logic;
	signal IACK_I_N		: std_logic;
	signal IACK_N			: std_logic;
	signal IACK_O_EN		: std_logic;
	signal IRQ_N			: std_logic_vector(7 downto 1);
	signal IRQOE_N			: std_logic;
	signal VMERA			: std_logic_vector(28 downto 1);
	signal VMERC			: std_logic_vector(28 downto 1);
	signal VMERD			: std_logic_vector(8 downto 1);
	signal VMERZ			: std_logic_vector(16 downto 1);
	signal FPAIN			: std_logic_vector(32 downto 1);
	signal FPBIN			: std_logic_vector(32 downto 1);
	signal FPCIN			: std_logic_vector(32 downto 1);
	signal FPDIN			: std_logic_vector(32 downto 1);
	signal FP6ID			: std_logic_vector(2 downto 0);
	signal FP6OE			: std_logic;
	signal FP6SEL			: std_logic;
	signal FP7ID			: std_logic_vector(2 downto 0);
	signal FP7OE			: std_logic;
	signal FP7SEL			: std_logic;
	signal FPGAIN			: std_logic_vector(8 downto 1);
	signal FPGAOUT			: std_logic_vector(8 downto 1);
	signal LEDA				: std_logic_vector(8 downto 1);
	signal MEMA				: std_logic_vector(19 downto 0);
	signal MEMCE2			: std_logic;
	signal MEMCLK			: std_logic;
	signal MEMD				: std_logic_vector(17 downto 0);
	signal MEMLDB			: std_logic;
	signal MEMRWB			: std_logic;
	signal CLKLOOP_O		: std_logic;
	signal CLKLOOP_I		: std_logic;
	signal PMEMCE_N		: std_logic;
	signal PMEMD0			: std_logic;
	signal PMEMD1			: std_logic;
	signal PMEMD2			: std_logic;
	signal PMEMD3			: std_logic;
	signal TOKENFI			: std_logic;
	signal TOKENFO			: std_logic;
	signal SYNCFI			: std_logic;
	signal TRIG1F			: std_logic;
	signal TRIG2F			: std_logic;
	signal TRIGFO			: std_logic;
	signal SDLINKF			: std_logic;
	signal STATA_IN		: std_logic;
	signal STATA_OUT		: std_logic;
	signal STATB_IN		: std_logic;
	signal BUSY_OUT		: std_logic;
	signal CLKREFA_P		: std_logic;
	signal CLKREFA_N		: std_logic;		
	signal CTPRX_P			: std_logic_vector(3 to 4);
	signal CTPRX_N			: std_logic_vector(3 to 4);
	signal CTPTX_P			: std_logic_vector(3 to 4);
	signal CTPTX_N			: std_logic_vector(3 to 4);
	signal CLK125F_P		: std_logic;	-- Note: labeled CLK250F_P on schematic
	signal CLK125F_N		: std_logic;	-- Note: labeled CLK250F_N on schematic
	signal CLKPRGC			: std_logic;
	signal PCLKLOAD		: std_logic;
	signal PCLKOUT1		: std_logic;
	signal PCLKOUT2		: std_logic;
	signal PCLKSIN1		: std_logic;
	signal PCLKSIN2		: std_logic;
	signal PCSWCFG			: std_logic;
	signal SWA				: std_logic_vector(23 downto 19);
	signal SWM1				: std_logic;
	signal CLKSELX1		: std_logic;
	signal CLKSELX2		: std_logic;
begin

	fe_vetroc_inst: fe_vetroc
		generic map(
			SIM_GTRESET_SPEEDUP	=> GTX_QUICKSIM
		)
		port map(
			A_CLKAB		=> A_CLKAB,
			A_CLKBA		=> A_CLKBA,
			A_DIR			=> A_DIR,
			A_LE			=> A_LE,
			A_OE_N		=> A_OE_N,
			A				=> A,
			AM				=> AM,
			D_CLKAB		=> D_CLKAB,
			D_CLKBA		=> D_CLKBA,
			D_DIR			=> D_DIR,
			D_LE			=> D_LE,
			D_OE_N		=> D_OE_N,
			D				=> D,
			SYSRESET_N	=> SYSRESET_N,
			SYSRST_EN	=> SYSRST_EN,
			SYSFAIL_EN	=> SYSFAIL_EN,
			SYSFAIL_N	=> SYSFAIL_N,
			BUSY_EN		=> BUSY_EN,
			BUSY_N		=> BUSY_N,
			BUSRQ_EN		=> BUSRQ_EN,
			RETRY_N		=> RETRY_N,
			RETRY_OE		=> RETRY_OE,
			WRITE_EN		=> WRITE_EN,
			WRITE_N		=> WRITE_N,
			AS_EN			=> AS_EN,
			AS_N			=> AS_N,
			BERR_EN		=> BERR_EN,
			BERR_N		=> BERR_N,
			BG3IN_N		=> BG3IN_N,
			BG3OUT_EN	=> BG3OUT_EN,
			DS0_EN		=> DS0_EN,
			DS0_N			=> DS0_N,
			DS1_EN		=> DS1_EN,
			DS1_N			=> DS1_N,
			DTACK_EN		=> DTACK_EN,
			DTACK_FPGA	=> DTACK_FPGA,
			DTACK_N		=> DTACK_N,
			GA_N			=> GA_N,
			GAP_N			=> GAP_N,
			IACK_EN		=> IACK_EN,
			IACK_I_N		=> IACK_I_N,
			IACK_N		=> IACK_N,
			IACK_O_EN	=> IACK_O_EN,
			IRQ_N			=> IRQ_N,
			IRQOE_N		=> IRQOE_N,
			VMERA			=> VMERA,
			VMERC			=> VMERC,
			VMERD			=> VMERD,
			VMERZ			=> VMERZ,
			FPAIN			=> FPAIN,
			FPBIN			=> FPBIN,
			FPCIN			=> FPCIN,
			FPDIN			=> FPDIN,
			FP6ID			=> FP6ID,
			FP6OE			=> FP6OE,
			FP6SEL		=> FP6SEL,
			FP7ID			=> FP7ID,
			FP7OE			=> FP7OE,
			FP7SEL		=> FP7SEL,
			FPGAIN		=> FPGAIN,
			FPGAOUT		=> FPGAOUT,
			LEDA			=> LEDA,
			MEMA			=> MEMA,
			MEMCE2		=> MEMCE2,
			MEMCLK		=> MEMCLK,
			MEMD			=> MEMD,
			MEMLDB		=> MEMLDB,
			MEMRWB		=> MEMRWB,
			CLKLOOP_O	=> CLKLOOP_O,
			CLKLOOP_I	=> CLKLOOP_I,
			PMEMCE_N		=> PMEMCE_N,
			PMEMD0		=> PMEMD0,
			PMEMD1		=> PMEMD1,
			PMEMD2		=> PMEMD2,
			PMEMD3		=> PMEMD3,
			TOKENFI		=> TOKENFI,
			TOKENFO		=> TOKENFO,
			SYNCFI		=> SYNCFI,
			TRIG1F		=> TRIG1F,
			TRIG2F		=> TRIG2F,
			TRIGFO		=> TRIGFO,
			SDLINKF		=> SDLINKF,
			STATA_IN		=> STATA_IN,
			STATA_OUT	=> STATA_OUT,
			STATB_IN		=> STATB_IN,
			BUSY_OUT		=> BUSY_OUT,
			CLKREFA_P	=> CLKREFA_P,
			CLKREFA_N	=> CLKREFA_N,
			CTPRX_P		=> CTPRX_P,
			CTPRX_N		=> CTPRX_N,
			CTPTX_P		=> CTPTX_P,
			CTPTX_N		=> CTPTX_N,
			CLK125F_P	=> CLK125F_P,
			CLK125F_N	=> CLK125F_N,
			CLKPRGC		=> CLKPRGC,
			PCLKLOAD		=> PCLKLOAD,
			PCLKOUT1		=> PCLKOUT1,
			PCLKOUT2		=> PCLKOUT2,
			PCLKSIN1		=> PCLKSIN1,
			PCLKSIN2		=> PCLKSIN2,
			PCSWCFG		=> PCSWCFG,
			SWA			=> SWA,
			SWM1			=> SWM1,
			CLKSELX1		=> CLKSELX1,
			CLKSELX2		=> CLKSELX2
		);


			A_CLKAB		: out std_logic;
			A_CLKBA		: out std_logic;
			A_DIR			: out std_logic;
			A_LE			: out std_logic;
			A_OE_N		: out std_logic;
			A				: inout std_logic_vector(31 downto 0);
			AM				: in std_logic_vector(5 downto 0);		
			D_CLKAB		: out std_logic;
			D_CLKBA		: out std_logic;
			D_DIR			: out std_logic;
			D_LE			: out std_logic;
			D_OE_N		: out std_logic;
			D				: inout std_logic_vector(31 downto 0);
			SYSRESET_N	: in std_logic;
			SYSRST_EN	: out std_logic;
			SYSFAIL_EN	: out std_logic;
			SYSFAIL_N	: in std_logic;
			BUSY_EN		: out std_logic;
			BUSY_N		: in std_logic;
			BUSRQ_EN		: out std_logic;
			RETRY_N		: in std_logic;
			RETRY_OE		: out std_logic;
			WRITE_EN		: out std_logic;
			WRITE_N		: in std_logic;
			AS_EN			: out std_logic;
			AS_N			: in std_logic;
			BERR_EN		: out std_logic;
			BERR_N		: in std_logic;
			BG3IN_N		: in std_logic;
			BG3OUT_EN	: out std_logic;
			DS0_EN		: out std_logic;
			DS0_N			: in std_logic;
			DS1_EN		: out std_logic;
			DS1_N			: in std_logic;
			DTACK_EN		: out std_logic;
			DTACK_FPGA	: out std_logic;
			DTACK_N		: in std_logic;
			GA_N			: in std_logic_vector(4 downto 0);
			GAP_N			: in std_logic;
			IACK_EN		: out std_logic;
			IACK_I_N		: in std_logic;
			IACK_N		: in std_logic;
			IACK_O_EN	: out std_logic;
			IRQ_N			: out std_logic_vector(7 downto 1);
			IRQOE_N		: out std_logic;
			VMERA			: in std_logic_vector(28 downto 1);
			VMERC			: in std_logic_vector(28 downto 1);
			VMERD			: in std_logic_vector(8 downto 1);
			VMERZ			: in std_logic_vector(16 downto 1);
--			FPAIN			: in std_logic_vector(32 downto 1);
--			FPBIN			: in std_logic_vector(32 downto 1);
--			FPCIN			: in std_logic_vector(32 downto 1);
--			FPDIN			: in std_logic_vector(32 downto 1);
			FP6ID			: in std_logic_vector(2 downto 0);
			FP6OE			: out std_logic;
			FP6SEL		: out std_logic;
			FP7ID			: in std_logic_vector(2 downto 0);
			FP7OE			: out std_logic;
			FP7SEL		: out std_logic;
			FPGAIN		: in std_logic_vector(8 downto 1);
			FPGAOUT		: out std_logic_vector(8 downto 1);			
			LEDA			: out std_logic_vector(8 downto 1);
			MEMA			: out std_logic_vector(19 downto 0);
			MEMCE2		: out std_logic;
			MEMCLK		: out std_logic;
			MEMD			: inout std_logic_vector(17 downto 0);
			MEMLDB		: out std_logic;
			MEMRWB		: out std_logic;
			CLKLOOP_O	: out std_logic;
			CLKLOOP_I	: in std_logic;
			PMEMCE_N		: out std_logic;
			PMEMD0		: inout std_logic;
			PMEMD1		: inout std_logic;
			PMEMD2		: inout std_logic;
			PMEMD3		: inout std_logic;
			TOKENFI		: in std_logic;
			TOKENFO		: out std_logic;
--			SYNCFI		: in std_logic;
--			TRIG1F		: in std_logic;
			TRIG2F		: in std_logic;
			TRIGFO		: out std_logic;
			SDLINKF		: out std_logic;
			STATA_IN		: in std_logic;
			STATA_OUT	: out std_logic;
			STATB_IN		: in std_logic;
			BUSY_OUT		: out std_logic;
			CLKREFA_P	: in std_logic;
			CLKREFA_N	: in std_logic;
--			CTPRX_P		: in std_logic_vector(3 to 4);
--			CTPRX_N		: in std_logic_vector(3 to 4);
--			CTPTX_P		: out std_logic_vector(3 to 4);
--			CTPTX_N		: out std_logic_vector(3 to 4);
--			CLK125F_P	: in std_logic;	-- Note: labeled CLK250F_P on schematic
--			CLK125F_N	: in std_logic;	-- Note: labeled CLK250F_N on schematic
			CLKPRGC		: in std_logic;
			PCLKLOAD		: out std_logic;
			PCLKOUT1		: out std_logic;
			PCLKOUT2		: out std_logic;
			PCLKSIN1		: out std_logic;
			PCLKSIN2		: out std_logic;
			PCSWCFG		: out std_logic;
			SWA			: in std_logic_vector(23 downto 19);
			SWM1			: in std_logic;
			CLKSELX1		: in std_logic;
			CLKSELX2		: in std_logic



-----------
	CLK125F_P <= GLOBAL_CLK;
	CLK125F_N <= not GLOBAL_CLK;
	SYNCFI <= SYNC;
	TRIG1F <= TRIG;
VMEBUS_DS_N		: in std_logic_vector(1 downto 0);
VMEBUS_AS_N		: in std_logic;
VMEBUS_W_N		: in std_logic;
VMEBUS_AM		: in std_logic_vector(5 downto 0);
VMEBUS_D			: inout std_logic_vector(31 downto 0);
VMEBUS_A			: inout std_logic_vector(31 downto 0);
VMEBUS_BERR_N	: inout std_logic;
VMEBUS_DTACK_N	: inout std_logic;
	CTPRX_P <= GTP_RX;
	CTPRX_N <= not GTP_RX;
	GTP_TX <= CTPTX_P;
	FPAIN <= TDC_IN(31 downto 0);
	FPBIN <= TDC_IN(63 downto 32);
	FPCIN <= TDC_IN(95 downto 64);
	FPDIN <= TDC_IN(127 downto 96);

end wrapper;
