library ieee;
use ieee.std_logic_1164.all;

package tigtp_ser_pkg is

	------------------------------
	-- Message flow structure
	------------------------------
	--    Command: <TIGTP_CMD_IDLE> ... <TIGTP_CMD_SOP> <TIGTP_CMD_DATA> ... <TIGTP_CMD_DATA> <TIGTP_CMD_EOP> ... <TIGTP_CMD_IDLE>
	--    Data:         <N/A>               <N/A>           <USER DATA>           <N/A>           <N/A>                 <N/A>
	--
	-- Comments:
	-- 1) packets are bracketed by SOP/EOP commands
	-- 2) IDLEs can exist anywhere, including inside SOP/EOP bracketed data
	
	-- Packet decoding:
	-- Byte0: bits 3:0 = Command, bits 7:4 = reserved
	-- Byte1..N: Command specific

	------------------------------
	-- Packet data commands
	------------------------------
	-- PKT_CMD_BLOCKDATA: TI->GTP event data block transfer
	-- <TIGTP_CMD_SOP> <TIGTP_CMD_DATA=PKT_CMD_BLOCKDATA> <TIGTP_CMD_DATA=block data>xN <TIGTP_CMD_EOP>
	constant PKT_CMD_BLOCKDATA	: std_logic_vector(3 downto 0) := "0000";

	-- PKT_CMD_BLOCKDATA: GTP->TI event data block ack
	-- <TIGTP_CMD_SOP> <TIGTP_CMD_DATA=PKT_CMD_BLOCKACK> <TIGTP_CMD_EOP>
	constant PKT_CMD_BLOCKACK	: std_logic_vector(3 downto 0) := "0001";

	-- PKT_CMD_BL_REQ: GTP->TI blocking size request
	-- <TIGTP_CMD_SOP> <TIGTP_CMD_DATA=PKT_CMD_BL_REQ> <TIGTP_CMD_EOP>
	constant PKT_CMD_BL_REQ		: std_logic_vector(3 downto 0) := "0010";

	-- PKT_CMD_SYNCEVT: TI->GTP sync event indicator
	-- <TIGTP_CMD_SOP> <TIGTP_CMD_DATA=PKT_CMD_SYNCEVT> <TIGTP_CMD_EOP>
	constant PKT_CMD_SYNCEVT	: std_logic_vector(3 downto 0) := "0100";

	-- PKT_CMD_BL_RSP: TI->GTP blocking size response
	-- <TIGTP_CMD_SOP> <TIGTP_CMD_DATA=PKT_CMD_BL_RSP> <TIGTP_CMD_DATA=next block level> <TIGTP_CMD_DATA=current block level> <TIGTP_CMD_EOP>
	constant PKT_CMD_BL_RSP	: std_logic_vector(3 downto 0) := "1000";

	------------------------------
	-- Link commands
	------------------------------
	constant TIGTP_CMD_IDLE		: std_logic_vector(1 downto 0) := "00";
	constant TIGTP_CMD_SOP		: std_logic_vector(1 downto 0) := "01";
	constant TIGTP_CMD_EOP		: std_logic_vector(1 downto 0) := "10";
	constant TIGTP_CMD_DATA		: std_logic_vector(1 downto 0) := "11";

	------------------------------
	-- Internal 8b10b control characters
	------------------------------
	constant TIGTP_CHAR_SOP		: std_logic_vector(7 downto 0) := x"5C";	--K28.2
	constant TIGTP_CHAR_EOP		: std_logic_vector(7 downto 0) := x"FD";	--K29.7
	constant TIGTP_CHAR_COMMA	: std_logic_vector(7 downto 0) := x"BC";	--K28.5

	component tigtp_ser is
		generic(
			FPGA					: string := "VIRTEX5"
		);
		port(
			CLK_REF				: in std_logic;
			CLK_REF_5X			: in std_logic;
			RX_RESET				: in std_logic;
			PLL_RESET			: in std_logic;
			RX_FIFO_RESET		: in std_logic;

			-- All signals below are synchronous to USER_CLK
			USER_CLK				: out std_logic;

			-- Transmitter Interface
			-- All signals 
			USER_TX_CMD			: in std_logic_vector(1 downto 0);
			USER_TX_DATA		: in std_logic_vector(7 downto 0);

			-- Receiver Interface
			USER_RX_CMD			: out std_logic_vector(1 downto 0);
			USER_RX_DATA		: out std_logic_vector(7 downto 0);
			USER_RX_ERROR_CNT	: out std_logic_vector(15 downto 0);
			USER_RX_READY		: out std_logic;
			USER_RX_LOCKED		: out std_logic;

			-- Serial pins
			TXD					: out std_logic;
			RXD					: in std_logic
		);
	end component;

end tigtp_ser_pkg;
