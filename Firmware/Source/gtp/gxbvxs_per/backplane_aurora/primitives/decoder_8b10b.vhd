library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- synthesis translate_off
library stratixiv;
use stratixiv.stratixiv_components.all;
-- synthesis translate_on

entity decoder_8b10b is
	generic(
		METHOD		: integer := 1
	);
	port(
		clk			: in std_logic;
		din_ena		: in std_logic;
		din_dat		: in std_logic_vector(9 downto 0);
		din_rd		: in std_logic;
		dout_val		: out std_logic := '0';
		dout_kerr	: out std_logic := '0';
		dout_dat		: out std_logic_vector(7 downto 0) := "00000000";
		dout_k		: out std_logic := '0';
		dout_rderr	: out std_logic := '0';
		dout_rdcomb	: out std_logic;
		dout_rdreg	: out std_logic := '0'
	);
end decoder_8b10b;

architecture Synthesis of decoder_8b10b is
	component stratixiv_lcell_comb
		generic (
			dont_touch	:	string := "off";
			extended_lut	:	string := "off";
			lut_mask	:	std_logic_vector(63 downto 0) := "0000000000000000000000000000000000000000000000000000000000000000";
			shared_arith	:	string := "off";
			lpm_type	:	string := "stratixiv_lcell_comb"
		);
		port(
			cin	:	in std_logic := '0';
			combout	:	out std_logic;
			cout	:	out std_logic;
			dataa	:	in std_logic := '0';
			datab	:	in std_logic := '0';
			datac	:	in std_logic := '0';
			datad	:	in std_logic := '0';
			datae	:	in std_logic := '0';
			dataf	:	in std_logic := '0';
			datag	:	in std_logic := '0';
			sharein	:	in std_logic := '0';
			shareout	:	out std_logic;
			sumout	:	out std_logic
		);
	end component;

	constant rd1_when_din_rd_0_mask						: std_logic_vector(63 downto 0) := x"ffe8e880e8808000";
	constant rd1_when_din_rd_1_mask						: std_logic_vector(63 downto 0) := x"fffefee8fee8e800";

	signal AI, BI, CI, DI, EI, II, FI, GI, HI, JI	: std_logic;
	signal P04, P13, P22, P31, P40						: std_logic;
	signal A, B, C, D, E, F, G, H, K						: std_logic;
	signal rd1n, rd1p, rd1e, rd1_err						: std_logic;
	signal rd1_when_din_rd_0								: std_logic;
	signal rd1_when_din_rd_1								: std_logic;
	signal rd1													: std_logic;
	signal rd2n, rd2p, rd2_err								: std_logic;
	signal dout_rdcomb_special								: std_logic;
	signal dout_rdcomb_i										: std_logic;
	signal k_err												: std_logic;
	signal din_datn											: std_logic_vector(9 downto 0);
begin

	dout_rdcomb <= dout_rdcomb_i;

	AI <= din_dat(0);
	BI <= din_dat(1);
	CI <= din_dat(2);
	DI <= din_dat(3);
	EI <= din_dat(4);
	II <= din_dat(5);
	FI <= din_dat(6);
	GI <= din_dat(7);
	HI <= din_dat(8);
	JI <= din_dat(9);

	din_datn <= not din_dat;

	--classification
	P04 <= (not AI and not BI and not CI and not DI);

	P13 <= (not AI and not BI and not CI and DI) or
	       (not AI and not BI and CI and not DI) or
	       (not AI and BI and not CI and not DI) or
	       (AI and not BI and not CI and not DI);

	P22 <= (not AI and not BI and CI and DI) or
	       (not AI and BI and CI and not DI) or
	       (AI and BI and not CI and not DI) or
	       (AI and not BI and CI and not DI) or
	       (AI and not BI and not CI and DI) or
	       (not AI and BI and not CI and DI);

	P31 <= (AI and BI and CI and not DI) or
	       (AI and BI and not CI and DI) or
	       (AI and not BI and CI and DI) or
	       (not AI and BI and CI and DI);

	P40 <= (AI and BI and CI and DI);


	------------------------------------------------
	-- data outputs
	------------------------------------------------
	A <= not AI when (P22 and not BI and not CI and not (EI xor II)) = '1' else
	     not AI when (P31 and II) = '1' else
	     not AI when (P13 and DI and EI and II) = '1' else
	     not AI when (P22 and not AI and not CI and not (EI xor II)) = '1' else
	     not AI when (P13 and not EI) = '1' else
	     not AI when (AI and BI and EI and II) = '1' else
	     not AI when (not CI and not DI and not EI and not II) = '1' else
	     AI;

	B <= not BI when (P22 and BI and CI and not (EI xor II)) = '1' else
	     not BI when (P31 and II) = '1' else
	     not BI when (P13 and DI and EI and II) = '1' else
	     not BI when (P22 and AI and CI and not (EI xor II)) = '1' else
	     not BI when (P13 and not EI) = '1' else
	     not BI when (AI and BI and EI and II) = '1' else
	     not BI when (not CI and not DI and not EI and not II) = '1' else
	     BI;

	C <= not CI when (P22 and BI and CI and not (EI xor II)) = '1' else
	     not CI when (P31 and II) = '1' else
	     not CI when (P13 and DI and EI and II) = '1' else
	     not CI when (P22 and not AI and not CI and not (EI xor II)) = '1' else
	     not CI when (P13 and not EI) = '1' else
	     not CI when (not AI and not BI and not EI and not II) = '1' else
	     not CI when (not CI and not DI and not EI and not II) = '1' else
	     CI;

	D <= not DI when (P22 and not BI and not CI and not (EI xor II)) = '1' else
	     not DI when (P31 and II) = '1' else
	     not DI when (P13 and DI and EI and II) = '1' else
	     not DI when (P22 and AI and CI and not (EI xor II)) = '1' else
	     not DI when (P13 and not EI) = '1' else
	     not DI when (AI and BI and EI and II) = '1' else
	     not DI when (not CI and not DI and not EI and not II) = '1' else
	     DI;

	E <= not EI when (P22 and not BI and not CI and not (EI xor II)) = '1' else
	     not EI when (P13 and not II) = '1' else
	     not EI when (P13 and DI and EI and II) = '1' else
	     not EI when (P22 and not AI and not CI and not (EI xor II)) = '1' else
	     not EI when (P13 and not EI) = '1' else
	     not EI when (not AI and not BI and not EI and not II) = '1' else
	     not EI when (not CI and not DI and not EI and not II) = '1' else
	     EI;

	F <= not FI when (FI and HI and JI) = '1' else
	     not FI when (not CI and not DI and not EI and not II and (HI xor JI)) = '1' else
	     not FI when (not FI and not GI and HI and JI) = '1' else
	     not FI when (FI and GI and JI) = '1' else
	     not FI when (not FI and not GI and not HI) = '1' else
	     not FI when (GI and HI and JI) = '1' else
	     FI;

	G <= not GI when (not FI and not HI and not JI) = '1' else
	     not GI when (not CI and not DI and not EI and not II and (HI xor JI)) = '1' else
	     not GI when (not FI and not GI and HI and JI) = '1' else
	     not GI when (FI and GI and JI) = '1' else
	     not GI when (not FI and not GI and not HI) = '1' else
	     not GI when (not GI and not HI and not JI) = '1' else
	     GI;

	H <= not HI when (FI and HI and JI) = '1' else
	     not HI when (not CI and not DI and not EI and not II and (HI xor JI)) = '1' else
	     not HI when (not FI and not GI and HI and JI) = '1' else
	     not HI when (FI and GI and JI) = '1' else
	     not HI when (not FI and not GI and not HI) = '1' else
	     not HI when (not GI and not HI and not JI) = '1' else
	     HI;

	K <= (CI and DI and EI and II) or
	     (not CI and not DI and not EI and not II) or
	     (P13 and not EI and II and GI and HI and JI) or
	     (P31 and EI and not II and not GI and not HI and not JI);

	------------------------------------------------
	--running disparity - generate and err check
	------------------------------------------------

	rd1n <= P04 or (P13 and not (EI and II)) or (P22 and not EI and not II) or (P13 and DI and EI and II);
	rd1p <= P40 or (P31 and not (not EI and not II)) or (P22 and EI and II) or (P31 and not DI and not EI and not II);
	rd1e <= (P13 and not DI and EI and II) or (P22 and (EI  xor  II)) or (P31 and DI and not EI and not II);
	rd1_err <= (not din_rd and rd1n) or (din_rd and rd1p);

	-----------------------------
	-- factored rd1 generation
	-----------------------------
	rd1_when_din_rd_0 <= rd1_when_din_rd_0_mask(conv_integer(din_dat(5 downto 0)));
	rd1_when_din_rd_1 <= rd1_when_din_rd_1_mask(conv_integer(din_dat(5 downto 0)));
	rd1 <= rd1_when_din_rd_1 when din_rd = '1' else rd1_when_din_rd_0;

	rd2n <= (not FI and not GI and not HI) or
	       (not FI and not GI and not JI) or
	       (not FI and not HI and not JI) or
	       (not GI and not HI and not JI) or
	       (not FI and not GI and HI and JI);

	rd2p <= (FI and GI and HI) or
	        (FI and GI and JI) or
	        (FI and HI and JI) or
	        (GI and HI and JI) or
	        (FI and GI and not HI and not JI);

	rd2_err <= (not rd1 and rd2n) or (rd1 and rd2p);


	-- these two conditions appear in rd2p and rd2n with the
	-- opposite associated rdcomb output.
	dout_rdcomb_special <= (not FI and not GI and HI and  JI) or (FI and GI and not HI and not JI);

	dout_rdcomb_i <= not dout_rdcomb_special when rd2p = '1' else
	               dout_rdcomb_special when rd2n = '1' else
	               rd1;

	------------------------------------------------
	-- K error check - this is by far the most
	--   complex expression in the decoder. 
	--   It appears to require depth 3.  Please let
	--   me know if you identify a depth 2 mapping.
	------------------------------------------------

	Method_gen_0: if METHOD = 0 generate
		k_err <= 
			--5b6b errors
			(P04) or
			(P13 and not EI and not II) or
			(P31 and EI and II) or
			(P40) or
			--3b4b errors
			( FI and  GI and  HI and  JI) or
			(not FI and not GI and not HI and not JI) or

			--any 2nd phase rd error, except if rd1 is even
			(rd2_err and not rd1e) or

			-- + some odd ones, dx.7 - specials ...
			-- d11.7,d13.7,d14.7,d17.7,d18.7,d20.7  use 1000/0111
			-- k23.7,k27.7,k29.7,k30.7 are legal    use 1000/0111
			-- other x.7                            use 0001/1110
			-- P22 & xxxx01 1110 - ok, d12.7
			-- P22 & xxxx10 1110 - ok, d28.7
			-- P22 & 011000 1110 - ok, d0.7
			-- P22 & 101000 1110 - ok, d15.7
			-- P22 & 100100 1110 - ok, d16.7
			-- P22 & 001100 1110 - ok, d24.7
			-- P22 & 010100 1110 - ok, d31.7
			-- P22 & 110000 1110 - illegal
			--       xxxx11 1110 - illegal
			( AI and  BI and not CI and not DI and not EI and not II and  FI and  GI and  HI and not JI) or
			(                     EI and  II and  FI and  GI and  HI and not JI) or
			-- P22 & xxxx01 0001 - ok, d6.7
			-- P31 & xxxx01 0001 - ok, d1.7
			-- P31 & xxxx10 0001 - ok, d23.7
			-- P22 & xxxx10 0001 - ok, d19.7
			-- P13 & xxxx11 0001 - ok, d7.7
			--       110011 0001 - ok, d24.7
			--       101011 0001 - ok, d31.7
			--       011011 0001 - ok, d16.7
			--       100111 0001 - ok, d0.7
			--       010111 0001 - ok, d15.7
			--       001111 0001 - illegal
			--       xxxx00 0001 - illegal
			(not AI and not BI and  CI and  DI and  EI and  II and not FI and not GI and not HI and  JI) or
			(                    not EI and not II and not FI and not GI and not HI and  JI) or

			--       110000 0111 - ok, k28.7
			-- P13 & xxxx01 0111 = ok, kxx.7
			--       100011 0111 = ok, d17.7
			--       010011 0111 = ok, d18.7
			--       001011 0111 = ok, d20.7
			--       000111 0111 = illegal (rderr)
			-- else  xxxxxx 0111 - illegal
			(not (P22 and not CI and not DI)        and not EI and not II and not FI and GI and HI and JI) or
			(not (P13)                  and not EI and  II and not FI and GI and HI and JI) or
			(not (P13 and (AI or BI or CI))    and  EI and  II and not FI and GI and HI and JI) or
			(                           EI and not II and not FI and GI and HI and JI) or

			--       001111 1000 - ok, k28.7
			-- P31 & xxxx10 1000 = ok, kxx.7
			--       110100 1000 - ok, d11.7
			--       101100 1000 - ok, d13.7
			--       011100 1000 - ok, d14.7
			--       111000 1000 - illegal (rderr)
			-- else  xxxxxx 1000 - illegal
			(not (P22 and CI and DI)          and  EI and  II and FI and not GI and not HI and not JI) or
			(not (P31)                  and  EI and not II and FI and not GI and not HI and not JI) or
			(not (P31 and (not AI or not BI or not CI)) and not EI and not II and FI and not GI and not HI and not JI) or
			(                          not EI and  II and FI and not GI and not HI and not JI);
	end generate;

	Method_gen_1: if METHOD = 1 generate
		constant kerr_mask_ai		: std_logic_vector(63 downto 0) := x"6881800180018117";
		constant kerr_mask_ej		: std_logic_vector(63 downto 0) := x"f20000018000004f";
		signal kerr_out_ai		: std_logic;
		signal kerr_out_ej		: std_logic;
		signal rd2_err_lc			: std_logic;
		signal kerr6				: std_logic;
		signal kerr7				: std_logic;
		signal kerr8				: std_logic;
		signal kerr9				: std_logic;
		signal kerr6n				: std_logic;
		signal kerr7n				: std_logic;
		signal kerr8n				: std_logic;
		signal kerr9n				: std_logic;
		signal kerr_remainder	: std_logic;
	begin
		-------------------------------------
		-- use the upper and lower portions only
		-- to identify definite errors
		-------------------------------------
		kerr_out_ai <=  kerr_mask_ai(conv_integer(din_dat(5 downto 0)));
		kerr_out_ej <=  kerr_mask_ej(conv_integer(din_dat(9 downto 4)));
		rd2_err_lc <= rd2_err;

		kerr6n <= not kerr6;
		kerr7n <= not kerr7;
		kerr8n <= not kerr8;
		kerr9n <= not kerr9;

		kerr6_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"0C0000300C000030",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> kerr6,
				cout		=> open,
				dataa		=> '1',
				datab		=> din_datn(7),
				datac		=> din_datn(6),
				datad		=> din_datn(8),
				datae		=> din_datn(9),
				dataf		=> '1',
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		kerr7_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"0002403000024030",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> kerr7,
				cout		=> open,
				dataa		=> din_datn(3),
				datab		=> din_datn(7),
				datac		=> din_datn(6),
				datad		=> din_datn(8),
				datae		=> din_datn(9),
				dataf		=> '1',
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		kerr8_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"6868960868689608",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> kerr8,
				cout		=> open,
				dataa		=> din_datn(0),
				datab		=> din_datn(1),
				datac		=> din_datn(2),
				datad		=> din_datn(4),
				datae		=> din_datn(3),
				dataf		=> '1',
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		kerr9_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"1001161E1001161E",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> kerr9,
				cout		=> open,
				dataa		=> din_datn(0),
				datab		=> din_datn(1),
				datac		=> din_datn(2),
				datad		=> din_datn(4),
				datae		=> din_datn(3),
				dataf		=> '1',
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		kerr_rem_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"2331223029110325",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> kerr_remainder,
				cout		=> open,
				dataa		=> din_datn(5),
				datab		=> kerr6n,
				datac		=> kerr7n,
				datad		=> din_datn(4),
				datae		=> kerr8n,
				dataf		=> kerr9n,
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		k_err <= kerr_out_ai or kerr_out_ej or (rd2_err_lc and not rd1e) or kerr_remainder;
	end generate;

	process(clk)
	begin
		if rising_edge(clk) then
			dout_val <= '0';
			if din_ena = '1' then
				dout_k <= K;
				dout_val <= din_ena;
				dout_dat <= H & G & F & E & D & C & B & A;
				dout_rdreg <= dout_rdcomb_i;
				dout_rderr <= rd1_err or rd2_err;
				dout_kerr <= k_err;
			end if;
		end if;
	end process;

end Synthesis;
