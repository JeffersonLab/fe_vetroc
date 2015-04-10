library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

entity scfifo_generic is
	generic(
		D_WIDTH	: integer := 32;
		A_WIDTH	: integer := 10;
		DOUT_REG	: boolean := false;
		FWFT		: boolean := false
	);
	port(
		CLK		: in std_logic;
		RST		: in std_logic;

		DIN		: in std_logic_vector(D_WIDTH-1 downto 0);
		WR			: in std_logic;
		FULL		: out std_logic;

		DOUT		: out std_logic_vector(D_WIDTH-1 downto 0);
		RD			: in std_logic;
		EMPTY		: out std_logic
	);
end scfifo_generic;

--Note: FIFO conversion logic taken from http://billauer.co.il/reg_fifo.html
architecture synthesis of scfifo_generic is
	signal STD_DOUT		: std_logic_vector(D_WIDTH-1 downto 0);
	signal STD_RD			: std_logic;
	signal STD_EMPTY		: std_logic;
begin

	scfifo_std_inst: scfifo_std
		generic map(
			D_WIDTH	=> D_WIDTH,
			A_WIDTH	=> A_WIDTH
		)
		port map(
			CLK		=> CLK,
			RST		=> RST,
			DIN		=> DIN,
			WR			=> WR,
			FULL		=> FULL,
			DOUT		=> STD_DOUT,
			RD			=> STD_RD,
			EMPTY		=> STD_EMPTY
		);

	FWFT_gen_false: if FWFT = false generate

		-- STD non-fabric registered output
		DOUT_REG_gen_false: if DOUT_REG = false generate
			DOUT <= STD_DOUT;
			STD_RD <= RD;
			EMPTY <= STD_EMPTY;
		end generate;

		-- STD fabric registered output
		DOUT_REG_gen_true: if DOUT_REG = true generate
			signal MIDDLE_DOUT			: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			signal FIFO_VALID				: std_logic := '0';
			signal MIDDLE_VALID			: std_logic := '0';
			signal DOUT_VALID				: std_logic := '0';
			signal WILL_UPDATE_MIDDLE	: std_logic;
			signal WILL_UPDATE_DOUT		: std_logic;
		begin
			WILL_UPDATE_MIDDLE <= '1' when (FIFO_VALID = '1') and (MIDDLE_VALID = WILL_UPDATE_DOUT) else '0';
			WILL_UPDATE_DOUT <= (MIDDLE_VALID or FIFO_VALID) and RD;
			STD_RD <= not STD_EMPTY and not (MIDDLE_VALID and FIFO_VALID);
			EMPTY <= not (FIFO_VALID or MIDDLE_VALID);

			process(CLK)
			begin
				if rising_edge(CLK) then
					if RST = '1' then
						FIFO_VALID <= '0';
						MIDDLE_VALID <= '0';
						DOUT <= (others=>'0');
						MIDDLE_DOUT <= (others=>'0');
					else
						if WILL_UPDATE_MIDDLE = '1' then
							MIDDLE_DOUT <= STD_DOUT;
						end if;
						
						if WILL_UPDATE_DOUT = '1' then
							if MIDDLE_VALID = '1' then
								DOUT <= MIDDLE_DOUT;
							else
								DOUT <= STD_DOUT;
							end if;
						end if;
						
						if STD_RD = '1' then
							FIFO_VALID <= '1';
						elsif (WILL_UPDATE_MIDDLE = '1') or (WILL_UPDATE_DOUT = '1') then
							FIFO_VALID <= '0';
						end if;
						
						if WILL_UPDATE_MIDDLE = '1' then
							MIDDLE_VALID <= '1';
						elsif WILL_UPDATE_DOUT = '1' then
							MIDDLE_VALID <= '0';
						end if;
					end if;
				end if;
			end process;

		end generate;

	end generate;

	FWFT_gen_true: if FWFT = true generate

		-- FWFT non-fabric registered output
		DOUT_REG_gen_false: if DOUT_REG = false generate
			signal DOUT_VALID		: std_logic := '0';
		begin
			DOUT <= STD_DOUT;
			STD_RD <= not STD_EMPTY and (RD or not DOUT_VALID);
			EMPTY <= not DOUT_VALID;

			process(CLK)
			begin
				if rising_edge(CLK) then
					if RST = '1' then
						DOUT_VALID <= '0';
					elsif STD_RD = '1' then
						DOUT_VALID <= '1';
					elsif RD = '1' then
						DOUT_VALID <= '0';
					end if;
				end if;
			end process;
		end generate;

		-- FWFT fabric registered output
		DOUT_REG_gen_true: if DOUT_REG = true generate
			signal MIDDLE_DOUT			: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			signal FIFO_VALID				: std_logic := '0';
			signal MIDDLE_VALID			: std_logic := '0';
			signal DOUT_VALID				: std_logic := '0';
			signal WILL_UPDATE_MIDDLE	: std_logic;
			signal WILL_UPDATE_DOUT		: std_logic;
		begin
			WILL_UPDATE_MIDDLE <= '1' when (FIFO_VALID = '1') and (MIDDLE_VALID = WILL_UPDATE_DOUT) else '0';
			WILL_UPDATE_DOUT <= (MIDDLE_VALID or FIFO_VALID) and (RD or not DOUT_VALID);
			STD_RD <= not STD_EMPTY and not (MIDDLE_VALID and DOUT_VALID and FIFO_VALID);
			EMPTY <= not DOUT_VALID;

			process(CLK)
			begin
				if rising_edge(CLK) then
					if RST = '1' then
						FIFO_VALID <= '0';
						MIDDLE_VALID <= '0';
						DOUT_VALID <= '0';
						DOUT <= (others=>'0');
						MIDDLE_DOUT <= (others=>'0');
					else
						if WILL_UPDATE_MIDDLE = '1' then
							MIDDLE_DOUT <= STD_DOUT;
						end if;
						
						if WILL_UPDATE_DOUT = '1' then
							if MIDDLE_VALID = '1' then
								DOUT <= MIDDLE_DOUT;
							else
								DOUT <= STD_DOUT;
							end if;
						end if;
						
						if STD_RD = '1' then
							FIFO_VALID <= '1';
						elsif (WILL_UPDATE_MIDDLE = '1') or (WILL_UPDATE_DOUT = '1') then
							FIFO_VALID <= '0';
						end if;
						
						if WILL_UPDATE_MIDDLE = '1' then
							MIDDLE_VALID <= '1';
						elsif WILL_UPDATE_DOUT = '1' then
							MIDDLE_VALID <= '0';
						end if;
						
						if WILL_UPDATE_DOUT = '1' then
							DOUT_VALID <= '1';
						elsif RD = '1' then
							DOUT_VALID <= '0';
						end if;
					end if;
				end if;
			end process;

		end generate;
	end generate;

end synthesis;
