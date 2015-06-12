library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;

entity trigger_per is
	generic(
		ADDR_INFO				: PER_ADDR_INFO
	);
	port(
		----------------------------------------------------
		-- User ports --------------------------------------
		----------------------------------------------------
		CLK						: in std_logic;
		CLK_DIV4					: in std_logic;

		SYNC						: in std_logic;

		-- Payload port serial data input
		RX_D						: in slv32a(15 downto 0);
		RX_SRC_RDY_N			: in std_logic_vector(15 downto 0);

		-- Trigger decisions
		TRIG_BIT_OUT			: out std_logic_vector(31 downto 0);

		----------------------------------------------------
		-- Bus interface ports -----------------------------
		----------------------------------------------------
		BUS_RESET				: in std_logic;
		BUS_RESET_SOFT			: in std_logic;
		BUS_DIN					: in std_logic_vector(D_WIDTH-1 downto 0);
		BUS_DOUT					: out std_logic_vector(D_WIDTH-1 downto 0);
		BUS_ADDR					: in std_logic_vector(A_WIDTH-1 downto 0);
		BUS_WR					: in std_logic;
		BUS_RD					: in std_logic;
		BUS_ACK					: out std_logic
	);
end trigger_per;

architecture Synthesis of trigger_per is
	component trigger_word_format is
		port(
			CLK						: in std_logic;
			CLK_DIV4					: in std_logic;

			SYNC						: in std_logic;

			TRG_EN					: in std_logic_vector(15 downto 0);

			-- Payload port serial data input
			RX_D						: in slv32a(15 downto 0);
			RX_SRC_RDY_N			: in std_logic_vector(15 downto 0);

			-- HITS_EN: '0' - HITS stream not valid, '1' - HITS stream is valid
			HITS_EN			: out std_logic;
			-- HITS - each index contains a 128bit vector containing current hit pattern for particular VXS/VME slot
			--    HITS(0)  = VXS payload 15 = VME slot  3 on 21 slot Weiner backplanes
			--    HITS(1)  = VXS payload 13 = VME slot  4 on 21 slot Weiner backplanes
			--    HITS(2)  = VXS payload 11 = VME slot  5 on 21 slot Weiner backplanes
			--    HITS(3)  = VXS payload  9 = VME slot  6 on 21 slot Weiner backplanes
			--    HITS(4)  = VXS payload  7 = VME slot  7 on 21 slot Weiner backplanes
			--    HITS(5)  = VXS payload  5 = VME slot  8 on 21 slot Weiner backplanes
			--    HITS(6)  = VXS payload  3 = VME slot  9 on 21 slot Weiner backplanes
			--    HITS(7)  = VXS payload  1 = VME slot 10 on 21 slot Weiner backplanes
			--    HITS(8)  = VXS payload  2 = VME slot 13 on 21 slot Weiner backplanes
			--    HITS(9)  = VXS payload  4 = VME slot 14 on 21 slot Weiner backplanes
			--    HITS(10) = VXS payload 6  = VME slot 15 on 21 slot Weiner backplanes
			--    HITS(11) = VXS payload 8  = VME slot 16 on 21 slot Weiner backplanes
			--    HITS(12) = VXS payload 10 = VME slot 17 on 21 slot Weiner backplanes
			--    HITS(13) = VXS payload 12 = VME slot 18 on 21 slot Weiner backplanes
			--    HITS(14) = VXS payload 14 = VME slot 19 on 21 slot Weiner backplanes
			--    HITS(15) = VXS payload 16 = VME slot 20 on 21 slot Weiner backplanes
			HITS				: out slv128a(0 to 15)
		);
	end component;

	signal PI							: pbus_if_i := ('0', '0', x"00000000", x"0000", '0', '0', '0');
	signal PO							: pbus_if_o := (x"00000000", '0');

	-- Registers
	signal TRG_CTRL_REG				: std_logic_vector(31 downto 0) := x"0000FFFF";
	signal TRG_STATUS_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal CLUSTER_THR_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LATENCY_REG				: std_logic_vector(31 downto 0) := x"00000000";

	-- Register Bits
	signal TRG_EN						: std_logic_vector(15 downto 0);
	signal CLUSTER_THR				: std_logic_vector(2 downto 0);
	signal LATENCY						: std_logic_vector(11 downto 0);
	signal LATENCY_ERR				: std_logic;

	----------------------------------------------------------------
	constant CLUSTER_WINDOW_SIZE	: integer := 4;

	signal HITS_EN						: std_logic;
	signal HITS							: slv128a(0 to 15);
	signal CLUSTER_TRIGGER_EN		: std_logic;
	signal CLUSTER_TRIGGER			: std_logic;
begin

	-- Scan 2048 vector clusters of size CLUSTER_WINDOW_SIZE having >= CLUSTER_THR hits
	process(CLK_DIV4)
		variable STRIP						: std_logic_vector(128*16-1 downto 0);
		variable STRIP_CLUSTERS			: std_logic_vector(128*16-CLUSTER_WINDOW_SIZE downto 0);
		variable CLUSTER_CNT				: std_logic_vector(CLUSTER_THR'range);
	begin
		if rising_edge(CLK_DIV4) then
			-- Arrange all VETROC hits as one big strip for convenience
			--    once geometry is know this can be separated into
			--    planes of smaller strips
			STRIP := HITS(15) & HITS(14) & HITS(13) & HITS(12) &
						HITS(11) & HITS(10) & HITS(9) & HITS(8) &
						HITS(7) & HITS(6) & HITS(5) & HITS(4) &
						HITS(3) & HITS(2) & HITS(1) & HITS(0);

			for I in STRIP_CLUSTERS'range loop
				CLUSTER_CNT := (others=>'0');
				for J in 0 to CLUSTER_WINDOW_SIZE-1 loop
					if STRIP(I+J) = '1' then
						CLUSTER_CNT := CLUSTER_CNT + 1;
					end if;
				end loop;

				if CLUSTER_CNT >= CLUSTER_THR then
					STRIP_CLUSTERS(I) := '1';
				else
					STRIP_CLUSTERS(I) := '0';
				end if;
			end loop;

			CLUSTER_TRIGGER <= or_reduce(STRIP_CLUSTERS);
			CLUSTER_TRIGGER_EN <= HITS_EN;
		end if;
	end process;

	-- Trigger bit output - perform latency adjustment to maintain a fixed latency trigger decision 
	fixedlatencybit_inst: fixedlatencybit
		port map(
				CLK			=> CLK,
				SYNC			=> SYNC,
				LATENCY		=> LATENCY,
				BIT_IN_EN	=> CLUSTER_TRIGGER,
				BIT_IN		=> CLUSTER_TRIGGER_EN,
				BIT_OUT		=> TRIG_BIT_OUT(0),
				BIT_OUT_ERR	=> LATENCY_ERR
		);

	TRIG_BIT_OUT(31 downto 1) <= (others=>'0');

	-- Convert VXS module serial streams to format useful for trigger logic
	trigger_word_format_inst: trigger_word_format
		port map(
			CLK				=> CLK,
			CLK_DIV4			=> CLK_DIV4,
			SYNC				=> SYNC,
			TRG_EN			=> TRG_EN,
			RX_D				=> RX_D,
			RX_SRC_RDY_N	=> RX_SRC_RDY_N,
			HITS_EN			=> HITS_EN,
			HITS				=> HITS
		);

	-- Registers
	PerBusCtrl_inst: PerBusCtrl
		generic map(
			ADDR_INFO		=> ADDR_INFO
		)
		port map(
			BUS_RESET		=> BUS_RESET,
			BUS_RESET_SOFT	=> BUS_RESET_SOFT,
			BUS_DIN			=> BUS_DIN,
			BUS_DOUT			=> BUS_DOUT,
			BUS_ADDR			=> BUS_ADDR,
			BUS_WR			=> BUS_WR,
			BUS_RD			=> BUS_RD,
			BUS_ACK			=> BUS_ACK,
			PER_CLK			=> CLK_DIV4,
			PER_RESET		=> PI.RESET,
			PER_RESET_SOFT	=> PI.RESET_SOFT,
			PER_DIN			=> PI.DIN,
			PER_ADDR			=> PI.ADDR,
			PER_WR			=> PI.WR,
			PER_RD			=> PI.RD,
			PER_MATCH		=> PI.MATCH,
			PER_DOUT			=> PO.DOUT,
			PER_ACK			=> PO.ACK
		);

	--TRG_CTRL_REG
	TRG_EN <= TRG_CTRL_REG(15 downto 0);

	--TRG_STATUS_REG
	TRG_STATUS_REG(0) <= LATENCY_ERR;

	--CLUSTER_THR_REG
	CLUSTER_THR <= CLUSTER_THR_REG(2 downto 0);

	--TRG_LATENCY_REG
	LATENCY <= LATENCY_REG(11 downto 0);

	process(CLK_DIV4)
	begin
		if rising_edge(CLK_DIV4) then
			PO.ACK <= '0';
			
			rw_reg(	REG => TRG_CTRL_REG				,PI=>PI,PO=>PO, A => x"0000", RW => x"0000FFFF", I => x"0000FFFF");
			ro_reg(	REG => TRG_STATUS_REG			,PI=>PI,PO=>PO, A => x"0004", RO => x"00000001");
			rw_reg(	REG => LATENCY_REG				,PI=>PI,PO=>PO, A => x"0008", RW => x"00000FFF", I => x"00000200");
			rw_reg(	REG => CLUSTER_THR_REG			,PI=>PI,PO=>PO, A => x"000C", RW => x"00000007");
		end if;
	end process;

end Synthesis;
