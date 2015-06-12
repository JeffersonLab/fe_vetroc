library ieee;
use ieee.std_logic_1164.all;

-- synthesis translate_off
library stratixiv;
use stratixiv.stratixiv_components.all;
-- synthesis translate_on

entity encoder_8b10b is
	generic(
		METHOD		: integer := 1
	);
	port(
		clk			: in std_logic;

		kin_ena		: in std_logic;
		ein_ena		: in std_logic;
		ein_dat		: in std_logic_vector(7 downto 0);
		ein_rd		: in std_logic;

		eout_val		: out std_logic;
		eout_dat		: out std_logic_vector(9 downto 0);
		eout_rdcomb	: out std_logic;
		eout_rdreg	: out std_logic
	);
end encoder_8b10b;

architecture Synthesis of encoder_8b10b is
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

	signal eout_rdcomb_i	: std_logic;
	signal AO, BO, CO, DO, EO, FO, GO, HO, IO, JO				: std_logic;

	signal eout_val_i		: std_logic := '0';
	signal eout_dat_i		: std_logic_vector(9 downto 0) := "0000000000";
	signal eout_rdreg_i	: std_logic := '0';
begin

	eout_val <= eout_val_i;
	eout_dat <= eout_dat_i;
	eout_rdreg <= eout_rdreg_i;

	Method_0_gen: if METHOD = 0 generate
		signal AI, BI, CI, DI, EI, FI, GI, HI							: std_logic;
		signal AIn, BIn, CIn, DIn, EIn, FIn, GIn, HIn				: std_logic;
		signal AOn, BOn, COn, DOn, EOn, FOn, GOn, HOn, IOn, JOn	: std_logic;

		signal K					: std_logic;
		signal Kn				: std_logic;

		signal rd1_part		: std_logic;
		signal rd1				: std_logic;

		signal ein_rdn			: std_logic;
		signal ein_datn		: std_logic_vector(7 downto 0);

		signal SorK				: std_logic;

		signal L04, L13, L22, L31, L40									: std_logic;
		signal disp0, disp1, disp2, disp3, disp4, disp5, disp6	: std_logic;
		signal invert_fj														: std_logic;
		signal invert_ai														: std_logic;
	begin

		AI <= ein_dat(0);
		BI <= ein_dat(1);
		CI <= ein_dat(2);
		DI <= ein_dat(3);
		EI <= ein_dat(4);
		FI <= ein_dat(5);
		GI <= ein_dat(6);
		HI <= ein_dat(7);

		AIn <= not ein_dat(0);
		BIn <= not ein_dat(1);
		CIn <= not ein_dat(2);
		DIn <= not ein_dat(3);
		EIn <= not ein_dat(4);
		FIn <= not ein_dat(5);
		GIn <= not ein_dat(6);
		HIn <= not ein_dat(7);

		K <= kin_ena;
		Kn <= not kin_ena;

		ein_datn <= not ein_dat;
		ein_rdn <= not ein_rd;

		--classification
		L04 <= (AIn and BIn and CIn and DIn);

		L13 <= (AIn and BIn and CIn and DI) or
		       (AIn and BIn and CI and DIn) or
		       (AIn and BI and CIn and DIn) or
		       (AI and BIn and CIn and DIn);

		L22 <= (AIn and BIn and CI and DI) or
		       (AIn and BI and CI and DIn) or
		       (AI and BI and CIn and DIn) or
		       (AI and BIn and CI and DIn) or
		       (AI and BIn and CIn and DI) or
		       (AIn and BI and CIn and DI);

		L31 <= (AI and BI and CI and DIn) or
		       (AI and BI and CIn and DI) or
		       (AI and BIn and CI and DI) or
		       (AIn and BI and CI and DI);

		L40 <= (AI and BI and CI and DI);

		disp0 <= (not L22 and not L31 and EIn);
		disp1 <= (L31 and DIn and EIn);
		disp2 <= (L13 and DI and EI);
		disp3 <= (not L22 and not L13 and EI);
		invert_ai <= not (disp3 or disp1 or K) when ein_rd = '1' else not (disp0 or disp2);

		AOn <= not AI;

		BOn <= '0' when L04 = '1' else
		      '1' when L40 = '1' else
		      not BI;

		COn <= '0' when L04 = '1' else
		      '0' when (L13 and DI and EI) = '1' else
		      not CI;

		DOn <= '1' when L40 = '1' else
		      not DI;

		EOn <= '0' when (L13 and EIn) = '1' else
		      '1' when (L13 and DI and EI) = '1' else
				not EI;

		IOn <= '0' when (L22 and not EI) = '1' else
		      '0' when (L04 and EI) = '1' else
		      '0' when (L13 and not DI and EI) = '1' else
		      '0' when (L40 and EI) = '1' else
		      '0' when (L22 and K) = '1' else
		      '1';
		
		rd1_part <= (disp0 or disp2 or disp3);
		rd1 <= (rd1_part or K) xor ein_rd;

		SorK <= (EO and IO and not rd1) or (not EO and not IO and rd1) or K;
		
		disp4 <= (not FI and not GI);
		disp5 <= (FI and GI);
		disp6 <= ((FI xor GI) and K);

		invert_fj <= not disp5 when rd1 = '1' else
		             not (disp4 or disp6);

		FOn <= '1' when (FI and GI and HI and SorK) = '1' else
		      not FI;

		GOn <= '0' when (not FI and not GI and not HI) = '1' else
		      not GI;

		HOn <= not HI;

		JOn <= '0' when ((FI xor GI) and not HI) = '1' else
		      '0' when (FI and GI and HI and SorK) = '1' else
		      '1';

		eout_rdcomb_i <= (disp4 or (FI and GI and HI)) xor rd1;

		AO <= invert_ai xor AOn;
		BO <= invert_ai xor BOn;
		CO <= invert_ai xor COn;
		DO <= invert_ai xor DOn;
		EO <= invert_ai xor EOn;
		IO <= invert_ai xor IOn;

		FO <= invert_fj xor FOn;
		GO <= invert_fj xor GOn;
		HO <= invert_fj xor HOn;
		JO <= invert_fj xor JOn;
	end generate;

	Method_1_gen: if METHOD = 1 generate
		signal FI, GI															: std_logic;
		signal AIn, BIn, CIn, DIn, EIn, FIn, GIn, HIn				: std_logic;
		signal AOn, BOn, COn, DOn, EOn, FOn, GOn, HOn, IOn, JOn	: std_logic;

		signal K					: std_logic;
		signal Kn				: std_logic;

		signal rd1_part		: std_logic;
		signal rd1				: std_logic;

		signal ein_rdn			: std_logic;
		signal ein_datn		: std_logic_vector(7 downto 0);

		signal SorK				: std_logic;

		signal rdout_x, rdout_y		: std_logic;
		signal rdout_xn				: std_logic;
		signal disp4					: std_logic;
		signal disp5					: std_logic;
		signal disp6					: std_logic;
		signal invert_fj				: std_logic;
		signal f0,f1,f2,f3,f4		: std_logic;
		signal f0n,f1n,f2n,f4n		: std_logic;
		signal j0,j1,j2,j3,j4,j5	: std_logic;
		signal j0n,j1n,j2n,j3n,j4n	: std_logic;
	begin

		FI <= ein_dat(5);
		GI <= ein_dat(6);

		AIn <= not ein_dat(0);
		BIn <= not ein_dat(1);
		CIn <= not ein_dat(2);
		DIn <= not ein_dat(3);
		EIn <= not ein_dat(4);
		FIn <= not ein_dat(5);
		GIn <= not ein_dat(6);
		HIn <= not ein_dat(7);

		K <= kin_ena;
		Kn <= not kin_ena;

		ein_datn <= not ein_dat;
		ein_rdn <= not ein_rd;

		f0n <= not f0;
		f1n <= not f1;
		f2n <= not f2;
		f4n <= not f4;

		j0n <= not j0;
		j1n <= not j1;
		j2n <= not j2;
		j3n <= not j3;
		j4n <= not j4;

		eout_rdcomb_i <= rdout_y;

		rdoutx: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"157E7EE800000000",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> rdout_x,
				cout		=> open,
				dataa		=> BIn,
				datab		=> DIn,
				datac		=> EIn,
				datad		=> AIn,
				datae		=> CIn,
				dataf		=> Kn,
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		rdout_xn <= not rdout_x;

		rdouty: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"3CC99663699CC336",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> rdout_y,
				cout		=> open,
				dataa		=> HIn,
				datab		=> ein_rdn,
				datac		=> FIn,
				datad		=> GIn,
				datae		=> rdout_xn,
				dataf		=> rdout_xn,
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		process(ein_rd, ein_dat, kin_ena)
			variable val_i		: std_logic_vector(7 downto 0);
			variable val_o		: std_logic_vector(7 downto 0);
		begin
			val_i := '0' & ein_rd & ein_dat(4 downto 0) & kin_ena;

			case val_i is
				when x"00" => val_o := x"39";
				when x"01" => val_o := x"39";
				when x"02" => val_o := x"2e";
				when x"03" => val_o := x"2e";
				when x"04" => val_o := x"2d";
				when x"05" => val_o := x"2d";
				when x"06" => val_o := x"23";
				when x"07" => val_o := x"23";
				when x"08" => val_o := x"2b";
				when x"09" => val_o := x"2b";
				when x"0a" => val_o := x"25";
				when x"0b" => val_o := x"25";
				when x"0c" => val_o := x"26";
				when x"0d" => val_o := x"26";
				when x"0e" => val_o := x"07";
				when x"0f" => val_o := x"07";
				when x"10" => val_o := x"27";
				when x"11" => val_o := x"27";
				when x"12" => val_o := x"29";
				when x"13" => val_o := x"29";
				when x"14" => val_o := x"2a";
				when x"15" => val_o := x"2a";
				when x"16" => val_o := x"0b";
				when x"17" => val_o := x"0b";
				when x"18" => val_o := x"2c";
				when x"19" => val_o := x"2c";
				when x"1a" => val_o := x"0d";
				when x"1b" => val_o := x"0d";
				when x"1c" => val_o := x"0e";
				when x"1d" => val_o := x"0e";
				when x"1e" => val_o := x"3a";
				when x"1f" => val_o := x"3a";
				when x"20" => val_o := x"36";
				when x"21" => val_o := x"36";
				when x"22" => val_o := x"31";
				when x"23" => val_o := x"31";
				when x"24" => val_o := x"32";
				when x"25" => val_o := x"32";
				when x"26" => val_o := x"13";
				when x"27" => val_o := x"33";
				when x"28" => val_o := x"34";
				when x"29" => val_o := x"34";
				when x"2a" => val_o := x"15";
				when x"2b" => val_o := x"35";
				when x"2c" => val_o := x"16";
				when x"2d" => val_o := x"36";
				when x"2e" => val_o := x"17";
				when x"2f" => val_o := x"17";
				when x"30" => val_o := x"33";
				when x"31" => val_o := x"33";
				when x"32" => val_o := x"19";
				when x"33" => val_o := x"39";
				when x"34" => val_o := x"1a";
				when x"35" => val_o := x"3a";
				when x"36" => val_o := x"1b";
				when x"37" => val_o := x"1b";
				when x"38" => val_o := x"1c";
				when x"39" => val_o := x"3c";
				when x"3a" => val_o := x"1d";
				when x"3b" => val_o := x"1d";
				when x"3c" => val_o := x"1e";
				when x"3d" => val_o := x"1e";
				when x"3e" => val_o := x"35";
				when x"3f" => val_o := x"35";
				when x"40" => val_o := x"06";
				when x"41" => val_o := x"39";
				when x"42" => val_o := x"11";
				when x"43" => val_o := x"2e";
				when x"44" => val_o := x"12";
				when x"45" => val_o := x"2d";
				when x"46" => val_o := x"23";
				when x"47" => val_o := x"1c";
				when x"48" => val_o := x"14";
				when x"49" => val_o := x"2b";
				when x"4a" => val_o := x"25";
				when x"4b" => val_o := x"1a";
				when x"4c" => val_o := x"26";
				when x"4d" => val_o := x"19";
				when x"4e" => val_o := x"38";
				when x"4f" => val_o := x"38";
				when x"50" => val_o := x"18";
				when x"51" => val_o := x"27";
				when x"52" => val_o := x"29";
				when x"53" => val_o := x"16";
				when x"54" => val_o := x"2a";
				when x"55" => val_o := x"15";
				when x"56" => val_o := x"0b";
				when x"57" => val_o := x"34";
				when x"58" => val_o := x"2c";
				when x"59" => val_o := x"13";
				when x"5a" => val_o := x"0d";
				when x"5b" => val_o := x"32";
				when x"5c" => val_o := x"0e";
				when x"5d" => val_o := x"31";
				when x"5e" => val_o := x"05";
				when x"5f" => val_o := x"3a";
				when x"60" => val_o := x"09";
				when x"61" => val_o := x"09";
				when x"62" => val_o := x"31";
				when x"63" => val_o := x"0e";
				when x"64" => val_o := x"32";
				when x"65" => val_o := x"0d";
				when x"66" => val_o := x"13";
				when x"67" => val_o := x"0c";
				when x"68" => val_o := x"34";
				when x"69" => val_o := x"0b";
				when x"6a" => val_o := x"15";
				when x"6b" => val_o := x"0a";
				when x"6c" => val_o := x"16";
				when x"6d" => val_o := x"09";
				when x"6e" => val_o := x"28";
				when x"6f" => val_o := x"28";
				when x"70" => val_o := x"0c";
				when x"71" => val_o := x"33";
				when x"72" => val_o := x"19";
				when x"73" => val_o := x"06";
				when x"74" => val_o := x"1a";
				when x"75" => val_o := x"05";
				when x"76" => val_o := x"24";
				when x"77" => val_o := x"24";
				when x"78" => val_o := x"1c";
				when x"79" => val_o := x"03";
				when x"7a" => val_o := x"22";
				when x"7b" => val_o := x"22";
				when x"7c" => val_o := x"21";
				when x"7d" => val_o := x"21";
				when x"7e" => val_o := x"0a";
				when x"7f" => val_o := x"0a";
				when others => val_o := x"00";
			end case;

			AO <= val_o(0);
			BO <= val_o(1);
			CO <= val_o(2);
			DO <= val_o(3);
			EO <= val_o(4);
			IO <= val_o(5);

		end process;

		process(ein_dat)
			variable val_i		: std_logic_vector(7 downto 0);
		begin
			val_i := "000" & ein_dat(4 downto 0);

			case val_i is
				when x"00" => rd1_part <= '1';	
				when x"01" => rd1_part <= '1';
				when x"02" => rd1_part <= '1';
				when x"03" => rd1_part <= '0';
				when x"04" => rd1_part <= '1';
				when x"05" => rd1_part <= '0';
				when x"06" => rd1_part <= '0';
				when x"07" => rd1_part <= '0';
				when x"08" => rd1_part <= '1';
				when x"09" => rd1_part <= '0';
				when x"0a" => rd1_part <= '0';
				when x"0b" => rd1_part <= '0';
				when x"0c" => rd1_part <= '0';
				when x"0d" => rd1_part <= '0';
				when x"0e" => rd1_part <= '0';
				when x"0f" => rd1_part <= '1';
				when x"10" => rd1_part <= '1';
				when x"11" => rd1_part <= '0';
				when x"12" => rd1_part <= '0';
				when x"13" => rd1_part <= '0';
				when x"14" => rd1_part <= '0';
				when x"15" => rd1_part <= '0';
				when x"16" => rd1_part <= '0';
				when x"17" => rd1_part <= '1';
				when x"18" => rd1_part <= '1';
				when x"19" => rd1_part <= '0';
				when x"1a" => rd1_part <= '0';
				when x"1b" => rd1_part <= '1';
				when x"1c" => rd1_part <= '0';
				when x"1d" => rd1_part <= '1';
				when x"1e" => rd1_part <= '1';
				when x"1f" => rd1_part <= '1';
				when others => rd1_part <= '0';
			end case;

		end process;
			
		disp4 <= FIn and GIn;
		disp5 <= FI and GI;
		disp6 <= (FI xor GI) and K;

		invert_fj <= not disp5 when ((rd1_part or K) xor ein_rd) = '1' else not (disp4 or disp6);

		GO <= invert_fj xor (not (FIn and HIn) and GIn);
		HO <= invert_fj xor HIn;

		f0_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"0224244002242440",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> f0,
				cout		=> open,
				dataa		=> ein_datn(3),
				datab		=> ein_datn(4),
				datac		=> ein_datn(1),
				datad		=> ein_datn(2),
				datae		=> ein_datn(0),
				dataf		=> '1',
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		f1_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"0F03AA590F03AA59",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> f1,
				cout		=> open,
				dataa		=> ein_rdn,
				datab		=> ein_datn(7),
				datac		=> ein_datn(6),
				datad		=> ein_datn(5),
				datae		=> Kn,
				dataf		=> '1',
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		f2_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"00F355A600F355A6",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> f2,
				cout		=> open,
				dataa		=> ein_rdn,
				datab		=> ein_datn(7),
				datac		=> ein_datn(6),
				datad		=> ein_datn(5),
				datae		=> Kn,
				dataf		=> '1',
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		f3_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"7800FF597800FF59",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> f3,
				cout		=> open,
				dataa		=> f4n,
				datab		=> f0n,
				datac		=> ein_rdn,
				datad		=> f1n,
				datae		=> f2n,
				dataf		=> '1',
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		f4_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"055E5EE8055E5EE8",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> f4,
				cout		=> open,
				dataa		=> ein_datn(3),
				datab		=> ein_datn(4),
				datac		=> ein_datn(1),
				datad		=> ein_datn(2),
				datae		=> ein_datn(0),
				dataf		=> '1',
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		FO <= f3;

		j0_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"117676E8117676E8",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> j0,
				cout		=> open,
				dataa		=> ein_datn(1),
				datab		=> ein_datn(3),
				datac		=> ein_datn(4),
				datad		=> ein_datn(2),
				datae		=> ein_datn(0),
				dataf		=> '1',
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		j1_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"0418182004181820",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> j1,
				cout		=> open,
				dataa		=> ein_datn(1),
				datab		=> ein_datn(3),
				datac		=> ein_datn(4),
				datad		=> ein_datn(2),
				datae		=> ein_datn(0),
				dataf		=> '1',
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		j2_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"5339A6665339A666",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> j2,
				cout		=> open,
				dataa		=> ein_rdn,
				datab		=> ein_datn(7),
				datac		=> ein_datn(5),
				datad		=> ein_datn(6),
				datae		=> Kn,
				dataf		=> '1',
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		j3_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"F00F0000F00F0000",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> j3,
				cout		=> open,
				dataa		=> '1',
				datab		=> '1',
				datac		=> ein_datn(5),
				datad		=> ein_datn(6),
				datae		=> Kn,
				dataf		=> '1',
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		j4_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"0003000000030000",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> j4,
				cout		=> open,
				dataa		=> '1',
				datab		=> ein_datn(7),
				datac		=> ein_datn(5),
				datad		=> ein_datn(6),
				datae		=> Kn,
				dataf		=> '1',
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		j5_I: stratixiv_lcell_comb
			generic map(
				extended_lut	=> "off",
				lut_mask			=> x"F07870A6F07870A6",
				shared_arith	=> "off"
			)
			port map(
				cin		=> '1',
				combout	=> j5,
				cout		=> open,
				dataa		=> j0n,
				datab		=> j1n,
				datac		=> j2n,
				datad		=> j3n,
				datae		=> j4n,
				dataf		=> '1',
				datag		=> '1',
				sharein	=> '0',
				shareout	=> open,
				sumout	=> open
			);

		JO <= j5;

	end generate;

	eout_rdcomb <= eout_rdcomb_i;
	
	process(clk)
	begin
		if rising_edge(clk) then
			eout_val_i <= '0';

			if (ein_ena = '1') or (kin_ena = '1') then
				eout_rdreg_i <= eout_rdcomb_i;
				eout_val_i <= ein_ena or kin_ena;
				eout_dat_i <= JO & HO & GO & FO & IO & EO & DO & CO & BO & AO;
			end if;
		end if;
	end process;

end Synthesis;
