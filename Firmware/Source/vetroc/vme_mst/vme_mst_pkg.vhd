library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.perbus_pkg.all;

package vme_mst_pkg is

	component vme_mst is
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
	end component;

end vme_mst_pkg;
