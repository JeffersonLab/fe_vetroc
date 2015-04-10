library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.utils_pkg.all;

entity indexer is
	generic(
		-- Max number of elements buffer can hold=2**A_WIDTH_BUF
		A_WIDTH_BUF		: integer := 9;
		-- Time variable width. Maximum run time=2**T_WIDTH*4ns before rollover
		D_WIDTH			: integer := 16;
		T_WIDTH			: integer := 16;
		N_WIDTH			: integer := 6
	);
	port(
		-- WR_CLK domain
		WR_CLK			: in std_logic;
		WR_CLK_2X		: in std_logic;
		WR					: in std_logic;
		DIN				: in std_logic_vector(D_WIDTH-1 downto 0);
		TIN				: in std_logic_Vector(T_WIDTH-1 downto 0);
		-- Note: RESET must be asserted before using to ensure erase pointer is set in proper position
		RESET				: in std_logic;
		
		-- RD_CLK domain
		RD_CLK			: in std_logic;

		RD_ADDR			: in std_logic_vector(A_WIDTH_BUF-1 downto 0);
		DOUT				: out std_logic_vector(D_WIDTH-1 downto 0);
		TOUT				: out std_logic_vector(T_WIDTH-1 downto 0);

		RD_ADDR_IDX		: in std_logic_vector(T_WIDTH-1 downto 0);
		ADDR_IDX			: out std_logic_vector(A_WIDTH_BUF-1 downto 0);
		LEN_IDX			: out std_logic_vector(N_WIDTH-1 downto 0);
		VALID_IDX		: out std_logic
	);
end indexer;

architecture synthesis of indexer is
	signal TIN_Q						: std_logic_vector(T_WIDTH-1 downto 0) := (others=>'0');
	signal LEN							: std_logic_vector(N_WIDTH-1 downto 0) := (others=>'0');
	signal WR_Q							: std_logic := '0';
	signal WR_ADDR						: std_logic_vector(A_WIDTH_BUF-1 downto 0) := (others=>'0');
	signal WR_ADDR_BUF				: std_logic_vector(A_WIDTH_BUF-1 downto 0) := (others=>'0');
	signal WR_ADDR1					: std_logic_vector(T_WIDTH-1 downto 0) := (others=>'0');
	signal WR_IDX						: std_logic := '0';
	signal DIN_IDX						: std_logic_vector(A_WIDTH_BUF+N_WIDTH-1 downto 0) := (others=>'0');
	signal WR_ADDR_IDX				: std_logic_vector(T_WIDTH-1 downto 0) := (others=>'0');
	signal WR_IDX_Q					: std_logic := '0';
	signal DIN_IDX_Q					: std_logic_vector(A_WIDTH_BUF+N_WIDTH-1 downto 0) := (others=>'0');
	signal WR_ADDR_IDX_Q				: std_logic_vector(T_WIDTH-1 downto 0) := (others=>'0');
	signal WR_BUF						: std_logic := '0';
	signal DIN_BUF						: std_logic_vector(D_WIDTH+T_WIDTH-1 downto 0);
	signal DOUT_BUF					: std_logic_vector(D_WIDTH+T_WIDTH-1 downto 0) := (others=>'0');
	signal DOUT_IDX					: std_logic_vector(A_WIDTH_BUF+N_WIDTH downto 0) := (others=>'0');
	signal DOUT_BUF_UNREG			: std_logic_vector(D_WIDTH+T_WIDTH-1 downto 0) := (others=>'0');
	signal DOUT_IDX_UNREG			: std_logic_vector(A_WIDTH_BUF+N_WIDTH downto 0) := (others=>'0');
	signal WR_CLK_2X_CYCLE			: std_logic := '0';
	signal WR_IDX_2X					: std_logic := '0';
	signal WR_ADDR_IDX_2X			: std_logic_vector(T_WIDTH-1 downto 0) := (others=>'0');
	signal DIN_IDX_2X					: std_logic_vector(A_WIDTH_BUF+N_WIDTH downto 0) := (others=>'0');
	signal TIMEOUT_CNT_DONE			: std_logic := '0';
	signal TIMEOUT_CNT				: std_logic_vector(T_WIDTH-2 downto 0) := (others=>'0');
begin

	VALID_IDX <= DOUT_IDX(A_WIDTH_BUF+N_WIDTH);
	ADDR_IDX <= DOUT_IDX(A_WIDTH_BUF-1 downto 0);
	LEN_IDX <= DOUT_IDX(A_WIDTH_BUF+N_WIDTH-1 downto A_WIDTH_BUF);
	TOUT <= DOUT_BUF(T_WIDTH-1 downto 0);
	DOUT <= DOUT_BUF(T_WIDTH+D_WIDTH-1 downto T_WIDTH);

	DIN_IDX(A_WIDTH_BUF+N_WIDTH-1 downto A_WIDTH_BUF) <= LEN;

	process(WR_CLK)
	begin
		if rising_edge(WR_CLK) then
			if WR = '1' then
				TIMEOUT_CNT <= (others=>'0');
			elsif TIMEOUT_CNT_DONE = '0' then
				TIMEOUT_CNT <= TIMEOUT_CNT + 1;
			end if;
		end if;
	end process;

	-- Write Pointer
	process(WR_CLK)
	begin
		if rising_edge(WR_CLK) then
			WR_IDX <= WR;

			if WR = '1' then
				if (TIN /= TIN_Q) or (TIMEOUT_CNT_DONE = '1') then
			TIN_Q <= TIN;
					LEN <= conv_std_logic_vector(0, LEN'length);
					WR_ADDR_IDX <= TIN;
					DIN_IDX(A_WIDTH_BUF-1 downto 0) <= WR_ADDR;
				elsif LEN /= conv_std_logic_vector(2**LEN'length-1, LEN'length) then
					LEN <= LEN + 1;
				end if;
			end if;

			WR_IDX_Q <= WR_IDX;
			WR_ADDR_IDX_Q <= WR_ADDR_IDX;
			DIN_IDX_Q <= DIN_IDX;
		end if;
	end process;

	-- Write Buffer
	process(WR_CLK)
	begin
		if rising_edge(WR_CLK) then
			WR_BUF <= WR;
			DIN_BUF <= DIN & TIN;
			WR_ADDR_BUF <= WR_ADDR;
			if WR = '1' then
				WR_ADDR <= WR_ADDR + 1;
			end if;
		end if;
	end process;

	-- Cleanup old data
	process(WR_CLK)
	begin
		if rising_edge(WR_CLK) then
			-- Invalidates indexes at current time
			if RESET = '1' then
				WR_ADDR1 <= (others=>'0');
			else
				WR_ADDR1 <= WR_ADDR1 + 1;
			end if;
		end if;
	end process;

	-- Ping pong write interface at CLK_2X to effectively double # write ports
	process(WR_CLK_2X)
	begin
		if rising_edge(WR_CLK_2X) then
			if WR_CLK_2X_CYCLE = '0' then
				WR_CLK_2X_CYCLE <= '1';
				WR_IDX_2X <= WR_IDX_Q;
				WR_ADDR_IDX_2X <= WR_ADDR_IDX_Q;
				DIN_IDX_2X <= '1' & DIN_IDX_Q;
			else
				WR_CLK_2X_CYCLE <= '0';
				WR_IDX_2X <= '1';
				WR_ADDR_IDX_2X <= WR_ADDR1;
				DIN_IDX_2X <= '0' & DIN_IDX_Q;
			end if;
		end if;
	end process;

	process(RD_CLK)
	begin
		if rising_edge(RD_CLK) then
			DOUT_BUF <= DOUT_BUF_UNREG;
			DOUT_IDX <= DOUT_IDX_UNREG;
		end if;
	end process;

 	sdp_ram_inst_buf: sdp_ram
		generic map(
			D_WIDTH		=> D_WIDTH+T_WIDTH,
			A_WIDTH		=> A_WIDTH_BUF,
			DOUT_REG		=> false
		)
		port map(
			WR_CLK		=> WR_CLK,
			WR				=> WR_BUF,
			WR_ADDR		=> WR_ADDR_BUF,
			DIN			=> DIN_BUF,
			RD_CLK		=> RD_CLK,
			RD				=> '1',
			RD_ADDR		=> RD_ADDR,
			DOUT			=> DOUT_BUF_UNREG
		);

	sdp_ram_inst_idx: sdp_ram
		generic map(
			D_WIDTH		=> A_WIDTH_BUF+N_WIDTH+1,
			A_WIDTH		=> T_WIDTH,
			DOUT_REG		=> false
		)
		port map(
			WR_CLK		=> WR_CLK_2X,
			WR				=> WR_IDX_2X,
			WR_ADDR		=> WR_ADDR_IDX_2X,
			DIN			=> DIN_IDX_2X,
			RD_CLK		=> RD_CLK,
			RD				=> '1',
			RD_ADDR		=> RD_ADDR_IDX,
			DOUT			=> DOUT_IDX_UNREG
		);

end synthesis;
