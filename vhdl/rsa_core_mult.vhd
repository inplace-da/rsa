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
-- KEYWORDS		: multiplication, interleaving 
-- ----------------------------------------------------------------------------
-- PURPOSE		: Multiply operands using the interleaving algorithm
-- 				  mult_c = mult_a * mult_b
-- ----------------------------------------------------------------------------
-- INTERFACE:
--				  ______
--				 |		|
--	mult_clk	-|		|
--	mult_rst	-|		|- mult_done
--	mult_start	-|		|
--	mult_a		-|		|- mult_c
--	mult_b		-|		|
--		  	 	 |______|
--
-- ----------------------------------------------------------------------------
-- PIN NAME		SIZE	DIRECTION	ACTIVE	DESCRIPTION
-- mult_clk		1		in			user	System clock
-- mult_rst		1		in			user	Reset
-- mult_start	1		in			user	Start multiplication when active
--											on a clock edge.
-- mult_a		N		in			-		Data input A
-- mult_b		N		in			-		Data input B
-- mult_done	1		out			high	Data ready. Active for one clock
--											cycle when mult_c is ready.
-- mult_c		2*N		out			-		Data output C (result)
-- ----------------------------------------------------------------------------
-- PARAMETER NAME 	RANGE		DEFAULT		DESCRIPTION
-- DATA_WIDTH		[N,1]		8			data width (bits)
-- CLK_EDGE			[1,0]		1			clock edge sensitivity
-- RESET			[1,0]		0			logic level activity
-- START			[1,0]		1			logic level activity
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
entity rsa_core_mult is
	generic(	
		DATA_WIDTH	: integer := 8;
		CLK_EDGE	: std_logic:='1';
		RESET		: std_logic:='0';
		START		: std_logic:='1');
	port(
		mult_clk	: in std_logic;
		mult_rst	: in std_logic;
		mult_start	: in std_logic;
		mult_a		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		mult_b		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		mult_done	: out std_logic;
		mult_c		: out std_logic_vector(2*DATA_WIDTH-1 downto 0));
end rsa_core_mult;
-------------------------------------------------------------------------------
-- ARCHITECTURE
architecture behavioral of rsa_core_mult is
	-- FSM
	type states is (INIT,		-- clear registers
					ANALYZE,	-- analyze msb of b register
					SHIFT_ADD,	-- add and shift p_reg
					SHIFT,		-- shift p_reg
					DONE);		-- multiplication done
					
	signal state_reg, state_ns: states;
		
	-- DATAPATH
	signal a_cnt	: integer range 0 to DATA_WIDTH;
	signal a_reg	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal b_reg	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal p_reg	: std_logic_vector(2*DATA_WIDTH-1 downto 0);
	signal c_reg	: std_logic_vector(2*DATA_WIDTH-1 downto 0);
	signal done_ff	: std_logic;
	
begin	
	-- OUTPUT SIGNALS CONNECTIONS
	mult_done	<= done_ff;
	mult_c		<= c_reg;	

	-- NEXT STATE DECODE LOGIC
	fsm: process(mult_rst, mult_start, b_reg(7), a_cnt, state_reg)
	begin
		if (mult_rst = RESET) then
			state_ns 	<= INIT;
		else
			case state_reg is
				when INIT =>
					if (mult_start = START) then
						state_ns <= ANALYZE;
					else
						state_ns <= INIT;						
					end if;
	
				when ANALYZE =>
					if (b_reg(DATA_WIDTH-1) = '1')then
						state_ns <= SHIFT_ADD;
					else
						state_ns <= SHIFT;
					end if;
	
				when SHIFT_ADD =>
					if (a_cnt /= (DATA_WIDTH-1))then
						if (b_reg(DATA_WIDTH-1) = '1')then
							state_ns <= SHIFT_ADD;
						else
							state_ns <= SHIFT;
						end if;
					else
						state_ns <= DONE;
					end if;
	
				when SHIFT =>
					if (a_cnt /= (DATA_WIDTH-1))then
						if (b_reg(DATA_WIDTH-1) = '0')then
							state_ns <= SHIFT;
						else
							state_ns <= SHIFT_ADD;
						end if;
					else
						state_ns <= DONE;
					end if;
					
				when DONE =>
					state_ns <= INIT;
	
				when others =>
					state_ns <= INIT;			
			end case;
		end if;
	end process fsm;

	-- RTL TRANSFERS (DATAPATH)
	rtl: process (mult_clk)
	begin
		if(mult_clk'event and mult_clk=CLK_EDGE)then		
			case state_reg is
				when INIT =>
					p_reg	<= (others => '0');
					a_cnt 	<= 0;
					done_ff <= '0';
					a_reg 	<= mult_a;
					b_reg 	<= mult_b;

				when ANALYZE =>
					b_reg 	<= b_reg(DATA_WIDTH-2 downto 0)&'0';
	
				when SHIFT_ADD =>
					p_reg 	<= a_reg + (p_reg(2*DATA_WIDTH-2 downto 0)&'0');
					a_cnt 	<= a_cnt + 1;
					b_reg 	<= b_reg(6 downto 0)&'0';
	
				when SHIFT =>
					p_reg 	<= p_reg(14 downto 0)&'0';
					a_cnt 	<= a_cnt + 1;
					b_reg 	<= b_reg(DATA_WIDTH-2 downto 0)&'0';
	
				when DONE =>
					done_ff <= '1';
					c_reg 	<= p_reg;

				when others =>
					null;
			end case;	
			state_reg <= state_ns;
		end if;	
	end process rtl;
end behavioral;
