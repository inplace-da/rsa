-------------------------------------------------------------------------------
-- COMPANY NAME	: InPlace Design Automation
-- AUTHOR		: Alcides Silveira Costa
-------------------------------------------------------------------------------
-- RELEASE HISTORY
-- DATE 			AUTHOR			DESCRIPTION
-- 24-Feb-2025		Alcides			Design environment migration to a Windows 7
--									VM running on Ubuntu 22.04.
-- 10-Oct-2009		Alcides			Creation
-------------------------------------------------------------------------------
-- KEYWORDS		: modulo, operation, mod_c
-- ----------------------------------------------------------------------------
-- PURPOSE		: Compute the remainder of a division operation (modulus)
-- 				  mod_c = mod_a mod mod_b
-- ----------------------------------------------------------------------------
-- INTERFACE:
--				  ______
--				 |		|
--	mod_clk		-|		|
--	mod_rst		-|		|- mod_done
--	mod_start	-|		|- mod_err
--	mod_a		-|		|- mod_c
--	mod_b		-|		|
--		  	 	 |______|
--
-- ----------------------------------------------------------------------------
-- PIN NAME		SIZE	DIRECTION	ACTIVE	DESCRIPTION
-- mod_clk		1		in			user	System clock
-- mod_rst		1		in			user	Reset
-- mod_start	1		in			user	Start modulo operation when active
--											on a clock edge.
-- mod_a		N		in			-		Data input A (dividend)
-- mod_b		N		in			-		Data input B (divisor)
-- mod_done		1		out			high	Data ready. Active for one clock
--											cycle when mod_c is ready.
-- mod_err		1		out			high	Error status (division by zero)
-- mod_c		N		out			-		Data output C (result: a mod b)
-- ----------------------------------------------------------------------------
-- PARAMETER NAME 	RANGE	DEFAULT			DESCRIPTION
-- DATA_WIDTH		[N,1]	8				data width (bits)
-- CLK_EDGE			[1,0]	1				clock edge sensitivity
-- RESET			[1,0]	0				logic level activity
-- START			[1,0]	1				logic level activity
-- ----------------------------------------------------------------------------
-- REUSE ISSUES
-- Reset Strategy	: Synchronous
-- Clock Domains	: system_clk
-- Critical Timing	: N/A
-- Instantiations	: N/A
-- Synthesizable	: Yes
-- ----------------------------------------------------------------------------
-- LIBRARY & USES
library ieee;
	use	ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.std_logic_arith.all;
-------------------------------------------------------------------------------
-- ENTITY
entity rsa_core_mod is
	generic(
		DATA_WIDTH	: integer := 8;
		CLK_EDGE	: std_logic:='1';
		RESET		: std_logic:='0';
		START		: std_logic:='1');
	port(
		mod_clk		: in std_logic;
		mod_rst		: in std_logic;
		mod_start	: in std_logic;
		mod_a		: in std_logic_vector(2*DATA_WIDTH-1 downto 0);
		mod_b		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		mod_done	: out std_logic;
		mod_err		: out std_logic;
		mod_c	: out std_logic_vector(DATA_WIDTH-1 downto 0));
end rsa_core_mod;
-------------------------------------------------------------------------------
-- ARCHITECTURE
architecture behavioral of rsa_core_mod is
	-- FSM
	type states is (INIT,		-- clear registers
					CHECK,		-- check if divisor is zero
					PREPARE,	-- prepare divisor 
					COMPARE,	-- compare if dividend is greater than divisor
					SUBTRACT,	-- subtract dividend and shift divisor
					SHIFT,		-- shift divisor
					DONE,		-- modulus operation done
					ERROR);		-- operation error (division by zero)
					
	signal state_reg, state_ns: states;

	-- DATAPATH
	-- control counter
	signal a_cnt: std_logic_vector(DATA_WIDTH downto 0);
	-- Dividend and temporary remainder
	signal t_reg: std_logic_vector(2*DATA_WIDTH-1 downto 0);	
	-- Divisor
	signal n_reg: std_logic_vector(2*DATA_WIDTH-1 downto 0);	
	-- Remainder
	signal r_reg: std_logic_vector(DATA_WIDTH-1 downto 0);
	-- Modulus operation done 
	signal mod_done_ff: std_logic;
	-- Zero division
	signal mod_err_ff: std_logic;

begin
	-- OUTPUT SIGNALS CONNECTIONS
	mod_done <= mod_done_ff;
	mod_err	<= mod_err_ff;
	mod_c	<= r_reg;                                                          

	-- NEXT STATE DECODE LOGIC
	fsm: process(mod_rst, mod_start, t_reg, n_reg, a_cnt, state_reg)
	begin
		if (mod_rst = RESET) then
			state_ns 	<= INIT;
		else
			case state_reg is
				when INIT =>
					if (mod_start = START) then
						state_ns <= CHECK;
					else
						state_ns <= INIT;
					end if;
	
				when CHECK =>
					if (n_reg(DATA_WIDTH-1 downto 0) = 0) then
						state_ns <= ERROR;
					else
						state_ns <= PREPARE;						
					end if;
	
				when PREPARE =>
					if (n_reg(2*DATA_WIDTH-2) = '0')then
						state_ns <= PREPARE;
					else
						state_ns <= COMPARE;
					end if;
	
				when COMPARE =>
					if(t_reg >= n_reg) then
						state_ns <= SUBTRACT;
					else
						state_ns <= SHIFT;
					end if;
										
				when SUBTRACT =>
					if (a_cnt /= 0)then
						state_ns <= COMPARE;
					else
						state_ns <= DONE;
					end if;
	
				when SHIFT =>
					if (a_cnt /= 0)then
						state_ns <= COMPARE;
					else
						state_ns <= DONE;
					end if;
					
				when DONE =>
					state_ns <= INIT;

				when ERROR =>
					state_ns <= INIT;
	
				when others =>
					state_ns <= INIT;			
			end case;
		end if;
	end process fsm;

	-- RTL TRANSFERS (DATAPATH)
	rtl: process (mod_clk)
	begin
		if(mod_clk'event and mod_clk=CLK_EDGE)then		
			case state_reg is
				when INIT =>
					mod_done_ff	<= '0';
					t_reg <= mod_a;
					n_reg(DATA_WIDTH-1 downto 0) <= mod_b;
					n_reg(2*DATA_WIDTH-1 downto DATA_WIDTH) <= (others => '0');
					a_cnt <= (others => '0');
					
				when CHECK =>
					null;
					
				when PREPARE =>
					a_cnt	<= a_cnt + 1;
					n_reg	<= n_reg(2*DATA_WIDTH-2 downto 0) &'0';
					
				when COMPARE =>
					null;					
	
				when SUBTRACT =>
					t_reg 	<= t_reg - n_reg;
					n_reg	<= '0' & n_reg(2*DATA_WIDTH-1 downto 1);
					a_cnt 	<= a_cnt - 1;
	
				when SHIFT =>
					n_reg	<= '0' & n_reg(2*DATA_WIDTH-1 downto 1);
					a_cnt 	<= a_cnt - 1;

				when DONE =>
					r_reg		<= t_reg(DATA_WIDTH-1 downto 0);
					mod_done_ff	<= '1';
					mod_err_ff	<= '0';

				when ERROR =>
					mod_err_ff	<= '1';
					mod_done_ff	<= '1';
					r_reg		<= (others => '1');

				when others =>
					null;
			end case;	
			state_reg <= state_ns;
		end if;	
	end process rtl;
end behavioral;
