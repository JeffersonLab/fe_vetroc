library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library utils;
use utils.utils_pkg.all;

entity aurora_5G_wrapper is
	generic(
		STARTING_CHANNEL_NUMBER		: natural;
		PMA_DIRECT						: std_logic := '0';
		SIM_GTXRESET_SPEEDUP			: integer := 0;
		GTX_QUICKSIM					: boolean := false
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
end aurora_5G_wrapper;

architecture synthesis of aurora_5G_wrapper is
	component aurora_5G is
		generic(
			STARTING_CHANNEL_NUMBER	: natural;
			PMA_DIRECT					: std_logic := '0';
			SIM_GTXRESET_SPEEDUP		: integer := 0
		);
		port(
			-- TX Stream Interface
			TX_D					: in std_logic_vector(0 to 31);
			TX_SRC_RDY_N		: in std_logic;
			TX_DST_RDY_N		: out std_logic;

			-- RX Stream Interface
			RX_D					: out std_logic_vector(0 to 31);
			RX_SRC_RDY_N		: out std_logic;

			-- Clock Correction Interface
			DO_CC					: in  std_logic;
			WARN_CC				: in  std_logic;    

			-- GTX Serial I/O
			RXP					: in std_logic_vector(0 to 1);
			TXP					: out std_logic_vector(0 to 1);

			--GTX Reference Clock Interface
			GTXD0					: in std_logic;

			-- Error Detection Interface
			HARD_ERR				: out std_logic_vector(0 to 1);
			SOFT_ERR				: out std_logic_vector(0 to 1);

			-- Status
			CHANNEL_UP			: out std_logic;
			LANE_UP				: out std_logic_vector(0 to 1);

			-- System Interface
			USER_CLK				: in std_logic;
			SYNC_CLK				: in std_logic;
			RESET					: in std_logic;
			POWER_DOWN			: in std_logic;
			LOOPBACK				: in std_logic_vector(2 downto 0);
			GT_RESET				: in std_logic;
			TX_OUT_CLK			: out std_logic;
			TX_LOCK				: out std_logic;

			--SIV Specific
			CLK50					: in std_logic;
			CAL_BLK_POWERDOWN	: in std_logic;
			CAL_BLK_BUSY		: in std_logic;
			RECONFIG_FROMGXB	: out std_logic_vector(67 downto 0);
			RECONFIG_TOGXB		: in std_logic_vector(3 downto 0)
		);
	end component;
begin

	gtx_quicksim_gen_true: if GTX_QUICKSIM = true generate
		constant fifo_depth	: integer := 4;
		signal fifo				: slv32a(0 to fifo_depth-1) := (others=>(others=>'0'));
		signal fifo_wr			: std_logic := '0';
		signal fifo_rd			: std_logic := '0';
		signal fifo_rd_pos	: integer := 0;
		signal fifo_wr_pos	: integer := 0;
	begin
		-- dump simple receiver
		process
			procedure write_fifo(d : in std_logic_vector) is
				variable fifo_wr_pos_next	: integer;
			begin
				fifo_wr_pos_next := (fifo_wr_pos + 1) mod fifo_depth;
				if fifo_wr_pos_next = fifo_rd_pos then
					--report "gtx dummy fifo write on full" severity warning;
				else
					fifo(fifo_wr_pos) <= d;
					fifo_wr_pos <= fifo_wr_pos_next;
				end if;
			end write_fifo;

			variable t			: time;
			variable rxdata	: std_logic_vector(RX_D'range) := (others=>'0');
		begin
			while true loop
				rxdata := (others=>'0');

				-- search start bit
				wait until rising_edge(RXP(0));
				t := NOW;
				wait until falling_edge(RXP(0));
				t := NOW - t;
				if t = 30 ps then
					-- capture data bits
					for I in RX_D'range loop
						wait until rising_edge(RXP(0));
						t := NOW;
						wait until falling_edge(RXP(0));
						t := NOW - t;
						if t = 10 ps then
							rxdata(I) := '0';
						elsif t = 20 ps then
							rxdata(I) := '1';
						end if;
					end loop;
					write_fifo(rxdata);
				end if;
			end loop;
		end process;

		process(CLK)
			procedure read_fifo(d : out std_logic_vector) is
			begin
				if fifo_wr_pos = fifo_rd_pos then
					report "gtx dummy fifo read on empty" severity error;
				end if;
				d := fifo(fifo_rd_pos);
				fifo_rd_pos <= (fifo_rd_pos + 1) mod fifo_depth;
			end read_fifo;

			variable rxdata	: std_logic_vector(RX_D'range) := (others=>'0');
		begin
			if rising_edge(CLK) then
				if fifo_wr_pos /= fifo_rd_pos then	-- check for not empty fifo
					RX_SRC_RDY_N <= '0';
					read_fifo(rxdata);
					RX_D <= rxdata;
				else
					RX_SRC_RDY_N <= '1';
					RX_D <= (others=>'0');
				end if;
			end if;
		end process;

		-- dumb simple transmitter
		process
			variable txdata	: std_logic_vector(TX_D'range);
		begin
			TXP <= (others=>'0');

			while true loop
				wait until rising_edge(CLK);
				txdata := TX_D;

				if TX_SRC_RDY_N = '0' then
					-- start bit
					TXP <= (others=>'1');
					wait for 30 ps;
					TXP <= (others=>'0');
					wait for 30 ps;

					-- data bits
					for I in txdata'range loop
						if txdata(I) = '0' then
							TXP <= (others=>'1');
							wait for 10 ps;
							TXP <= (others=>'0');
							wait for 20 ps;
						elsif txdata(I) = '1' then
							TXP <= (others=>'1');
							wait for 20 ps;
							TXP <= (others=>'0');
							wait for 10 ps;
						end if;
					end loop;
				end if;
			end loop;
		end process;

		TX_DST_RDY_N <= '0';

		RECONFIG_FROMGXB <= (others=>'0');

		GXB_STATUS <= x"00000000";
		GXB_ERR_TILE <= x"00000000";
		GXB_ERR <= '0';

	end generate;

	gtx_quicksim_gen_false: if GTX_QUICKSIM = false generate
		signal POWER_DOWN			: std_logic;
		signal GT_RESET			: std_logic := '1';
		signal GXBERR_RST			: std_logic;
		signal GXBERR_EN			: std_logic;
		signal RESET				: std_logic := '1';

		signal CHANNEL_UP			: std_logic;
		signal HARD_ERR			: std_logic_vector(0 to 1);
		signal LANE_UP				: std_logic_vector(0 to 1);
		signal RX_SRC_RDY_N_i	: std_logic;
		signal SOFT_ERR			: std_logic_vector(0 to 1);
		signal TX_LOCK				: std_logic;

		signal STARTUP_CNT			: std_logic_vector(23 downto 0) := (others=>'0');
		signal STARTUP_CNT_DONE		: std_logic;
		signal STARTUP_CNT_GT_RESET_DONE	: std_logic;
		signal POWER_DOWN_Q			: std_logic_vector(1 downto 0);
		signal TX_LOCK_Q				: std_logic_vector(1 downto 0);
		signal HARD_ERR_Q				: std_logic_vector(1 downto 0);
		signal CHANNEL_UP_Q			: std_logic;
	begin
		RX_SRC_RDY_N <= RX_SRC_RDY_N_i;
		GXB_ERR <= or_reduce(HARD_ERR);

		STARTUP_CNT_GT_RESET_DONE <= '1' when STARTUP_CNT >= conv_std_logic_vector(10000, STARTUP_CNT'length) else '0';
		STARTUP_CNT_DONE <= '1' when STARTUP_CNT = conv_std_logic_vector(2**STARTUP_CNT'length-1, STARTUP_CNT'length) else '0';

		process(CLK)
		begin
			if rising_edge(CLK) then
				POWER_DOWN_Q <= POWER_DOWN_Q(0) & POWER_DOWN;
				TX_LOCK_Q <= TX_LOCK_Q(0) & TX_LOCK;
				HARD_ERR_Q <= HARD_ERR_Q(0) & or_reduce(HARD_ERR);
				CHANNEL_UP_Q <= CHANNEL_UP;

				if (SIM_GTXRESET_SPEEDUP = 1) or (STARTUP_CNT_GT_RESET_DONE = '1') then
					GT_RESET <= '0';
				else
					GT_RESET <= '1';
				end if;

				if TX_LOCK_Q(1) = '1' then
					RESET <= '0';
				else
					RESET <= '1';
				end if;

				if (POWER_DOWN_Q(1) = '1') or ((STARTUP_CNT_DONE = '1') and (TX_LOCK_Q(1) = '0')) or ((STARTUP_CNT_DONE = '1') and (CHANNEL_UP_Q = '0'))then
					STARTUP_CNT <= (others=>'0');
				elsif STARTUP_CNT_DONE = '0' then
					STARTUP_CNT <= STARTUP_CNT + 1;
				end if;
			end if;
		end process;

		-----------------------------------
		-- Register GTX_CTRL Mapping
		-----------------------------------
		POWER_DOWN <= GXB_CTRL(0);
	--	GT_RESET <= GXB_CTRL(1);
	--	LOOPBACK <= GXB_CTRL(4 downto 2);
	--	RXENPRBSTST <= GXB_CTRL(6 downto 5);			
	--	TXENPRBSTST <= GXB_CTRL(8 downto 7);
	--	RESET <= GXB_CTRL(9);
		GXBERR_RST <= GXB_CTRL(10);
		GXBERR_EN <= GXB_CTRL(11);
		
		-----------------------------------
		-- Register GTX_STATUS Mapping
		-----------------------------------
		GXB_STATUS(0) <= HARD_ERR(0);
		GXB_STATUS(1) <= HARD_ERR(1);
		GXB_STATUS(2) <= '0';	--HARD_ERR(2);
		GXB_STATUS(3) <= '0';	--HARD_ERR(3);
		GXB_STATUS(4) <= LANE_UP(0);
		GXB_STATUS(5) <= LANE_UP(1);
		GXB_STATUS(6) <= '0';	--LANE_UP(2);
		GXB_STATUS(7) <= '0';	--LANE_UP(3);
		GXB_STATUS(8) <= '0';	--RXPOLARITY;
		GXB_STATUS(9) <= '0';	--RXPOLARITY_LANE1;
		GXB_STATUS(10) <= '0';	--RXPOLARITY_LANE2;
		GXB_STATUS(11) <= '0';	--RXPOLARITY_LANE3;
		GXB_STATUS(12) <= CHANNEL_UP;
		GXB_STATUS(13) <= TX_LOCK;
		GXB_STATUS(14) <= RX_SRC_RDY_N_i;
		GXB_STATUS(31 downto 15) <= (others=>'0');


		-----------------------------------
		-- Error Counters
		-----------------------------------	
		Counter_ErrLane0: Counter
			generic map(
				LEN	=> 16
			)
			port map(
				CLK	=> CLK,
				RST	=> GXBERR_RST,
				EN		=> GXBERR_EN,
				INC	=> SOFT_ERR(0),
				CNT	=> GXB_ERR_TILE(15 downto 0)
			);
	
		Counter_ErrLane1: Counter
			generic map(
				LEN	=> 16
			)
			port map(
				CLK	=> CLK,
				RST	=> GXBERR_RST,
				EN		=> GXBERR_EN,
				INC	=> SOFT_ERR(1),
				CNT	=> GXB_ERR_TILE(31 downto 16)
			);

		aurora_5G_inst: aurora_5G
			generic map(
				STARTING_CHANNEL_NUMBER	=> STARTING_CHANNEL_NUMBER,
				PMA_DIRECT					=> PMA_DIRECT,
				SIM_GTXRESET_SPEEDUP		=> SIM_GTXRESET_SPEEDUP
			)
			port map(
				TX_D					=> TX_D,
				TX_SRC_RDY_N		=> TX_SRC_RDY_N,
				TX_DST_RDY_N		=> TX_DST_RDY_N,
				RX_D					=> RX_D,
				RX_SRC_RDY_N		=> RX_SRC_RDY_N_i,
				DO_CC					=> '0',
				WARN_CC				=> '0',
				RXP					=> RXP,
				TXP					=> TXP,
				GTXD0					=> GTXD0,
				HARD_ERR				=> HARD_ERR,
				SOFT_ERR				=> SOFT_ERR,
				CHANNEL_UP			=> CHANNEL_UP,
				LANE_UP				=> LANE_UP,
				USER_CLK				=> CLK,
				SYNC_CLK				=> CLK,
				RESET					=> RESET,
				POWER_DOWN			=> POWER_DOWN,
				LOOPBACK				=> "000",
				GT_RESET				=> GT_RESET,
				TX_OUT_CLK			=> open,
				TX_LOCK				=> TX_LOCK,
				CLK50					=> CLK50,
				CAL_BLK_POWERDOWN	=> CAL_BLK_POWERDOWN,
				CAL_BLK_BUSY		=> CAL_BLK_BUSY,
				RECONFIG_FROMGXB	=> RECONFIG_FROMGXB,
				RECONFIG_TOGXB		=> RECONFIG_TOGXB
			);
	end generate;

end synthesis;
