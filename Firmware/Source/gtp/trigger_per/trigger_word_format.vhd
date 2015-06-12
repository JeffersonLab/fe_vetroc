library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

library utils;
use utils.utils_pkg.all;

use work.trigger_per_pkg.all;

entity trigger_word_format is
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
end trigger_word_format;

architecture synthesis of trigger_word_format is
	signal WRREQ						: std_logic_vector(15 downto 0);
	signal RDREQ						: std_logic_vector(15 downto 0);
	signal RDEMPTY						: std_logic_vector(15 downto 0);
	signal Q								: slv128a(0 to 15);
	signal RDREQ_EN					: std_logic;
begin

	WRREQ <= not RX_SRC_RDY_N;

	rx_d_fifo_gen: for I in 0 to 15 generate
		dcfifo_mixed_widths_inst0: dcfifo_mixed_widths
			generic map(
				intended_device_family	=> "Stratix IV",
				lpm_hint						=> "RAM_BLOCK_TYPE=M9K",
				lpm_numwords				=> 1024,
				lpm_showahead				=> "ON",
				lpm_type						=> "dcfifo_mixed_widths",
				lpm_width					=> 32,
				lpm_widthu					=> 10,
				lpm_widthu_r				=> 8,
				lpm_width_r					=> 128,
				overflow_checking			=> "ON",
				rdsync_delaypipe			=> 3,
				read_aclr_synch			=> "ON",
				underflow_checking		=> "ON",
				use_eab						=> "ON",
				write_aclr_synch			=> "ON",
				wrsync_delaypipe			=> 3
			)
			port map(
				aclr		=> SYNC,
				data		=> RX_D(I),
				rdclk		=> CLK_DIV4,
				rdreq		=> RDREQ(I),
				wrclk		=> CLK,
				wrreq		=> WRREQ(I),
				wrfull	=> open,
				q			=> Q(I),
				rdempty	=> RDEMPTY(I)
			);
	end generate;

	process(CLK_DIV4)
	begin
		if rising_edge(CLK_DIV4) then
			if TRG_EN = (not RDEMPTY) then
				RDREQ <= TRG_EN;
				RDREQ_EN <= '1';
			else
				RDREQ <= (others=>'0');
				RDREQ_EN <= '0';
			end if;

			for I in RDREQ'range loop
				if RDREQ(I) = '1' then
					HITS(PAYLOAD_TO_SLOTIDX(I)) <= Q(I);
				else
					HITS(PAYLOAD_TO_SLOTIDX(I)) <= (others=>'0');
				end if;
			end loop;

			HITS_EN <= RDREQ_EN;
		end if;
	end process;

end synthesis;
