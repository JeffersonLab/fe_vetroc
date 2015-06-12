library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;
use work.vme_mst_pkg.all;

entity vme_mst is
	port(
		-- User ports --------------------------------------

		--Signal Distribution Interface
		DTACK_LED			: out std_logic;
		TOKENIN				: in std_logic;
		TOKENOUT				: out std_logic;

		-- Event Builder Interface		
		SLOTID				: out std_logic_vector(4 downto 0);
		A32_BASE_ADDR		: in std_logic_vector(8 downto 0);
		A32_BASE_ADDR_EN	: in std_logic;		
		A32M_ADDR_MIN		: in std_logic_vector(8 downto 0);
		A32M_ADDR_MAX		: in std_logic_vector(8 downto 0);
		A32M_ADDR_EN		: in std_logic;
		TOKEN_FIRST			: in std_logic;
		TOKEN_LAST			: in std_logic;
		TOKEN_STATUS		: out std_logic;
		TOKEN_TAKE			: in std_logic;
		USER_INT_ID			: in std_logic_vector(7 downto 0);
		USER_INT_LEVEL		: in std_logic_vector(2 downto 0);
		USER_BERR_EN		: in std_logic;
		USER_INT				: in std_logic;
		USER_FIFO_DATA_1	: in std_logic_vector(35 downto 0);
		USER_FIFO_EMPTY_1	: in std_logic;
		USER_FIFO_RDREQ_1	: out std_logic;
		USER_FIFO_DATA_2	: in std_logic_vector(35 downto 0);
		USER_FIFO_EMPTY_2	: in std_logic;
		USER_FIFO_RDREQ_2	: out std_logic;

		-- VME Transceiver I/O
		VME_ADR				: in std_logic_vector(23 downto 16);
		IACK_O_N				: out std_logic;
		IACK_I_N				: in std_logic;
		IACK_N				: in std_logic;
		RETRY					: out std_logic;
		RETRY_OE				: out std_logic;
		BERR_I_N				: in std_logic;
		BERR_O_N				: out std_logic;
		DTACK_I_N			: in std_logic;
		DTACK_O_N			: out std_logic;
		DTACK_OE				: out std_logic;
		W_N					: in std_logic;
		AM						: in std_logic_vector(5 downto 0);
		A						: inout std_logic_vector(31 downto 0);
		A_LE					: out std_logic;
		AS_N					: in  std_logic;
		A_OE_N				: out std_logic;
		A_DIR					: out std_logic;
		D						: inout std_logic_vector(31 downto 0);
		D_LE					: out std_logic;
		DS_N					: in std_logic_vector(1 downto 0);
		D_OE_N				: out std_logic_vector(1 downto 0);
		D_DIR					: out std_logic;
		IRQ_N					: out std_logic_vector(7 downto 1);
		GA_N					: in std_logic_vector(4 downto 0);
		GAP					: in std_logic;

		-- Bus interface ports (Master) --------------------
		BUS_CLK			: in std_logic;
		BUS_RESET		: in std_logic;
		BUS_DIN			: out std_logic_vector(D_WIDTH-1 downto 0);
		BUS_DOUT			: in std_logic_vector(D_WIDTH-1 downto 0);
		BUS_ADDR			: out std_logic_vector(A_WIDTH-1 downto 0);
		BUS_WR			: out std_logic;
		BUS_RD			: out std_logic;
		BUS_ACK			: in std_logic
	);
end vme_mst;

architecture Synthesis of vme_mst is
	component vme_interface_8 is
		generic(
			LOCAL_ADDR_SIZE	: integer
		);
		port(
			a				: inout std_logic_vector(31 downto 0);	-- vme bus signals
			am				: in std_logic_vector(5 downto 0);
			as_n			: in std_logic;
			iack_n		: in std_logic;
			w_n			: in std_logic;
			ds0_n			: in std_logic;
			ds1_n			: in std_logic;
			dt				: inout std_logic_vector(31 downto 0);

			dtack_in_n	: in std_logic;
			berr_in_n	: in std_logic; 
			sysreset_n	: in std_logic;
			dtack_n		: out std_logic;
			berr_n		: out std_logic;
			retry_n		: out std_logic;

			i_lev			: in std_logic_vector(2 downto 0);
			iackin_n		: in std_logic;
			iackout_n	: out std_logic;
			irq_n			: out std_logic_vector(7 downto 1);
			------------------------------------------------------------------------------------------
										-- vme tx/rx chip controls
			oe_d1_n		: out std_logic;							-- (data 15..0)						
			oe_d2_n		: out std_logic;							-- (data 31..16)
			oe_dtack		: out std_logic;
			oe_retry		: out std_logic;
			dir_a			: out std_logic;
			dir_d			: out std_logic;
			oe_a_n		: out std_logic;
			le_d			: out std_logic;
			clkab_d		: out std_logic;
			clkba_d		: out std_logic;
			le_a			: out std_logic;
			clkab_a		: out std_logic;
			clkba_a		: out std_logic;
			------------------------------------------------------------------------------------------				 
			d_fifo1		: in std_logic_vector(35 downto 0);	-- data from output fifo 1 (data(71..36))
			empty1		: in std_logic;						-- fifo 1 empty flag		 
			rdreq1		: out std_logic;						-- fifo 1 read request (synced to clk_x2)		 
			d_fifo2		: in std_logic_vector(35 downto 0);	-- data from output fifo 2 (data(35..0))			 
			empty2		: in std_logic;						-- fifo 2 empty flag		 
			rdreq2		: out std_logic;						-- fifo 2 read request (synced to clk_x2)		 

			d_reg_in		: out std_logic_vector(31 downto 0);	-- data for write to A24 register space of module
			d_reg_out	: in std_logic_vector(31 downto 0);	-- data from read of A24 register space of module

			intr_stb		: in std_logic;						-- assert to trigger interrupt request by module		         		     
			------------------------------------------------------------------------------------------				 
			adr24			: in std_logic_vector(23 downto LOCAL_ADDR_SIZE);	-- A24 address of module (A23...local_addr_size)
			adr32			: in std_logic_vector(8 downto 0);	-- A32 address of module (A31...A23) (8 MB)
			en_adr32		: in std_logic;						-- assert to enable A32 addressing of module
			adr32m_min	: in std_logic_vector(8 downto 0);	-- minimum A32 multiboard address of module (A31...A23)
			adr32m_max	: in std_logic_vector(8 downto 0);	-- maximum A32 multiboard address of module (A31...A23)
			en_adr32m	: in std_logic;						-- assert to enable common A32 multiboard addressing of module
			------------------------------------------------------------------------------------------				 
			en_multiboard	: in std_logic;						-- assert to enable multiboard token passing protocol
			first_board		: in std_logic;						-- assert to identify module as first in multiboard set
			last_board		: in std_logic;						-- assert to identify module as last in multiboard set
			en_token_in_p0	: in std_logic;						-- assert to enable module to accept token in from p0
			token_in_p0		: in std_logic;						-- token in from previous module on p0
			en_token_in_p2	: in std_logic;						-- assert to enable module to accept token in from p2
			token_in_p2		: in std_logic;						-- token in from previous module on p2
			take_token		: in std_logic;						-- assert to force first module to recover token
			------------------------------------------------------------------------------------------				 		  
			busy				: in std_logic;						-- assert to hold off ack (wait for register data)
			fast_access		: in std_logic;						-- assert for read of main data (fifo)
			------------------------------------------------------------------------------------------				 		   
			modsel			: out std_logic;
			addr				: out std_logic_vector((LOCAL_ADDR_SIZE - 1) downto 0);	-- latched local address
			byte				: out std_logic_vector(3 downto 0);	-- bytes selected for register access
			data_cycle		: out std_logic;						-- asserted for data cycle
			iack_cycle		: out std_logic;						-- asserted for interrupt ack cycle
			read_sig			: out std_logic;						-- asserted during register read cycle
			read_stb			: out std_logic;						-- pulse (1 clk) to latch data for read
			write_sig		: out std_logic;						-- asserted during register write cycle
			write_stb		: out std_logic;						-- pulse (1 clk) to latch data for write
			a24_cycle		: out std_logic;						-- asserted for A24 address access
			a32_cycle		: out std_logic;						-- asserted for A32 address access
			a32m_cycle		: out std_logic;						-- asserted for A32 multiboard address access
			d64_cycle		: out std_logic;						-- asserted for D64 data access (read only)
			end_cycle		: out std_logic;						-- asserted to signal end of current vme cycle
			berr_status		: out std_logic;						-- asserted if BERR has been driven for cycle
			ds_sync			: out std_logic;						-- OR (positive asserted) of VME data strobes (sync to clk_x2)
			w_n_sync			: out std_logic;						-- VME write signal (sync to clk_x2)
			------------------------------------------------------------------------------------------				 		       
			token				: out std_logic;						-- asserted when module has token
			token_out		: out std_logic;						-- pulse to transfer token to next module
			done_block		: out std_logic;						-- asserted when block of events has been extracted
			------------------------------------------------------------------------------------------				 		       		       
			en_berr			: in std_logic;						-- enable BERR response of module
			------------------------------------------------------------------------------------------				 		       		       
			ev_count_down	: out std_logic;						-- use to decrement event counter (events on board)
			event_header	: out std_logic;						-- asserted when data word is an event header
			block_header	: out std_logic;						-- asserted when data word is a block header
			block_trailer	: out std_logic;						-- asserted when data word is a block trailer
			------------------------------------------------------------------------------------------				 		       		       
			clk_x2			: in std_logic;						-- clk_x2, clk_x4 are in phase
			clk_x4			: in std_logic;						-- (may be same frequency as clk_x2, or 2x clk_x2)
			reset				: in std_logic;
			------------------------------------------------------------------------------------------				 		       		       		         
			dnv_word			: in std_logic_vector(31 downto 0);	-- word output when no valid data is available (empty)
			filler_word		: in std_logic_vector(31 downto 0);   -- word output as a filler for 2eVME and 2eSST cycles

			temp				: out std_logic_vector(31 downto 0);  -- for debug
			sst_state		: out std_logic_vector(16 downto 0);
			sst_ctrl			: out std_logic_vector(31 downto 0)
		);
	end component;

	component vme_mst_sm is
		port(
			CLK			: in std_logic;
			RESET			: in std_logic;
			
			WRITE_SIG	: in std_logic;
			READ_SIG		: in std_logic;
			BUS_ACK		: in std_logic;

			BUS_DIN_EN	: out std_logic;
			BUS_DOUT_EN	: out std_logic;
			BUS_WR		: out std_logic;
			BUS_RD		: out std_logic;
			BUSY			: out std_logic
		);
	end component;

	constant VME_DNV_WORD				: std_logic_vector(31 downto 0) := x"F0000000";
	constant VME_FILLER_WORD			: std_logic_vector(31 downto 0) := x"F8000000";

	signal SLOTID_i		: std_logic_vector(4 downto 0);
	signal adr24			: std_logic_vector(23 downto A_WIDTH);
	signal berr_inv		: std_logic;
	signal fast_access	: std_logic;
	signal a32_cycle		: std_logic;
	signal a32m_cycle		: std_logic;
	signal w_n_sync		: std_logic;
	signal irq_inv			: std_logic_vector(7 downto 1);
	signal GA_PAR_ERR		: std_logic;
	signal sysreset_n		: std_logic;
	signal busy				: std_logic;
	signal byte				: std_logic_vector(3 downto 0);
	signal addr				: std_logic_vector(A_WIDTH-1 downto 0);
	signal modsel			: std_logic;
	signal d_reg_in		: std_logic_vector(31 downto 0);
	signal d_reg_out		: std_logic_vector(31 downto 0);
	signal data_cycle		: std_logic;
	signal iack_cycle		: std_logic;
	signal a24_cycle		: std_logic;
	signal write_sig		: std_logic;
	signal read_sig		: std_logic;
	signal BUS_DIN_EN		: std_logic;
	signal BUS_DOUT_EN	: std_logic;
begin

	SLOTID <= SLOTID_i;
	BERR_O_N <= not berr_inv;
	IRQ_N <= not irq_inv;
	GA_PAR_ERR <= not (GA_N(0) xor GA_N(1) xor GA_N(2) xor GA_N(3) xor GA_N(4) xor GAP);
	SLOTID_i <= "11110" when GA_PAR_ERR = '1' else not GA_N;

	fast_access <= (a32_cycle or a32m_cycle) and w_n_sync;

	adr24 <= not VME_ADR(23 downto A_WIDTH) when VME_ADR /= "11111111" else
	         SLOTID_i & "000" when GA_PAR_ERR = '0' else
	         conv_std_logic_vector(1, 24-A_WIDTH);

	sysreset_n <= not BUS_RESET;

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			BUS_ADDR <= addr;
		end if;
	end process;

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			if BUS_DIN_EN = '1' then
				BUS_DIN <= d_reg_in;
			end if;
		end if;
	end process;

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			if BUS_DOUT_EN = '1' then
				d_reg_out <= BUS_DOUT;
			end if;
		end if;
	end process;

	vme_mst_sm_inst: vme_mst_sm
		port map(
			CLK			=> BUS_CLK,
			RESET			=> BUS_RESET,
			WRITE_SIG	=> write_sig,
			READ_SIG		=> read_sig,
			BUS_ACK		=> BUS_ACK,
			BUS_DIN_EN	=> BUS_DIN_EN,
			BUS_DOUT_EN	=> BUS_DOUT_EN,
			BUS_WR		=> BUS_WR,
			BUS_RD		=> BUS_RD,
			BUSY			=> busy
		);

	LEDPulser_inst: LEDPulser
		generic map(
			LEN			=> 12,
			INVERT		=> true,
			MIN_OFF_EN	=> false
		)
		port map(
			CLK			=> BUS_CLK,
			INPUT			=> modsel,
			OUTPUT		=> DTACK_LED
		);

	vme_interface: vme_interface_8
		generic map(
			LOCAL_ADDR_SIZE	=> A_WIDTH
		)
		port map(
			a					=> A,
			am					=> AM,
			as_n				=> AS_N,
			iack_n			=> IACK_N,
			w_n				=> W_N,
			ds0_n				=> DS_N(0),
			ds1_n				=> DS_N(1),
			dt					=> D,
			dtack_in_n		=> DTACK_I_N,
			berr_in_n		=> BERR_I_N,
			sysreset_n		=> sysreset_n,
			dtack_n			=> DTACK_O_N,
			berr_n			=> berr_inv,
			retry_n			=> RETRY,
			i_lev				=> USER_INT_LEVEL,
			iackin_n			=> IACK_I_N,
			iackout_n		=> IACK_O_N,
			irq_n				=> irq_inv,
			oe_d1_n			=> D_OE_N(0),
			oe_d2_n			=> D_OE_N(1),
			oe_dtack			=> DTACK_OE,
			oe_retry			=> RETRY_OE,
			dir_a				=> A_DIR,
			dir_d				=> D_DIR,
			oe_a_n			=> A_OE_N,
			le_d				=> D_LE,
			clkab_d			=> open,
			clkba_d			=> open,
			le_a				=> A_LE,
			clkab_a			=> open,
			clkba_a			=> open,
			d_fifo1			=> USER_FIFO_DATA_1,
			empty1			=> USER_FIFO_EMPTY_1,
			rdreq1			=> USER_FIFO_RDREQ_1,
			d_fifo2			=> USER_FIFO_DATA_2,
			empty2			=> USER_FIFO_EMPTY_2,
			rdreq2			=> USER_FIFO_RDREQ_2,
			d_reg_in			=> d_reg_in,
			d_reg_out		=> d_reg_out,
			intr_stb			=> USER_INT,
			adr24				=> adr24,
			adr32				=> A32_BASE_ADDR,
			en_adr32			=> A32_BASE_ADDR_EN,
			adr32m_min		=> A32M_ADDR_MIN,
			adr32m_max		=> A32M_ADDR_MAX,
			en_adr32m		=> A32M_ADDR_EN,
			en_multiboard	=> A32M_ADDR_EN,
			first_board		=> TOKEN_FIRST,
			last_board		=> TOKEN_LAST,
			en_token_in_p0	=> A32M_ADDR_EN,
			token_in_p0		=> TOKENIN,
			en_token_in_p2	=> '0',
			token_in_p2		=> '0',
			take_token		=> TOKEN_TAKE,
			busy				=> busy,
			fast_access		=> fast_access,
			modsel			=> modsel,
			addr				=> addr,
			byte				=> byte,
			data_cycle		=> data_cycle,
			iack_cycle		=> iack_cycle,
			read_sig			=> read_sig,
			read_stb			=> open,
			write_sig		=> write_sig,
			write_stb		=> open,
			a24_cycle		=> a24_cycle,
			a32_cycle		=> a32_cycle,
			a32m_cycle		=> a32m_cycle,
			d64_cycle		=> open,
			end_cycle		=> open,
			berr_status		=> open,
			ds_sync			=> open,
			w_n_sync			=> w_n_sync,
			token				=> TOKEN_STATUS,
			token_out		=> TOKENOUT,
			done_block		=> open,
			en_berr			=> USER_BERR_EN,
			ev_count_down	=> open,
			event_header	=> open,
			block_header	=> open,
			block_trailer	=> open,
			clk_x2			=> BUS_CLK,
			clk_x4			=> BUS_CLK,
			reset				=> BUS_RESET,
			dnv_word			=> VME_DNV_WORD,
			filler_word		=> VME_FILLER_WORD,
			temp				=> open,
			sst_state		=> open,
			sst_ctrl			=> open
		);

end Synthesis;
