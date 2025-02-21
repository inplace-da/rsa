-------------------------------------------------------------------------------
-- COMPANY NAME	: InPlace Design Automation
-- AUTHOR		: Alcides Silveira Costa
-------------------------------------------------------------------------------
-- RELEASE HISTORY
-- DATE 			AUTHOR			DESCRIPTION
-- 24-Feb-2025		Alcides			Design environment migration to a Windows 7
--									VM running on Ubuntu 22.04.
-- 04-Oct-2009		Alcides			Creation
-------------------------------------------------------------------------------
-- Resumo: controle de multiplexagem de dados para o display de 7 segmentos.
-- Multiplexa entrada entre toggle switches e outra entrada qualquer. Sempre 
-- que os switches forem alterados seu valor e multiplexado para a saida.
-- Interface:
--		 	   _________
--			  |	    	|
--	ctrl_clk -|	    	|
--	ctrl_rst -|	    	|
--	ctrl_din -|	    	|- ctrl_dout 
--	ctrl_sel -|	    	|
--	ctrl_c   -|			|
--			  |_________|
--
-- --------------------------------------------------------------------------
-- |Pino		|Tamanho|Direcao|Ativo	|Descricao							|
-- |------------------------------------------------------------------------|
-- |ctrl_clk	|1		|in		|user	|Relogio do sistema					|
-- |------------|-------|-------|-------|-----------------------------------|
-- |ctrl_rst	|1		|in		|user	|Reset assincrono					|
-- |------------|-------|-------|-------|-----------------------------------|
-- |ctrl_sel	|1		|in		|high	|Habilita entrada ctrl_c para ser	|
-- |			|		|		|		|registrada ma saida				|
-- |------------|-------|-------|-------|-----------------------------------|
-- |ctrl_din	|8		|in		|-		|Entrada de dados decodificada para |
-- |			|		|		|		|o display de 7 segmentos			|
-- |------------|-------|-------|-------|-----------------------------------|
-- |ctrl_c		|8		|in		|-		|Entrada do operador				|
-- |------------|-------|-------|-------|-----------------------------------|
-- |ctrl_dout	|8		|out	|-		|Saida multiplexada					|
-- --------------------------------------------------------------------------
--
-- Total de IOs: 27 pinos
-------------------------------------------------------------------------------
library ieee;
	use ieee.std_logic_1164.all;
-------------------------------------------------------------------------------
entity rsa_io_ctrl is
	generic(
		CLK_EDGE	: std_logic := '1';
		RST_ACTIVE	: std_logic := '0');		
	port(
		ctrl_clk	: in std_logic;
		ctrl_rst	: in std_logic;
		ctrl_din	: in std_logic_vector(7 downto 0);
		ctrl_sel	: in std_logic;
		ctrl_c		: in std_logic_vector(7 downto 0);
		ctrl_dout	: out std_logic_vector(7 downto 0));
end rsa_io_ctrl;
-------------------------------------------------------------------------------
architecture behavioral of rsa_io_ctrl is

	-- sinais da maquina de estados (FSM)
	attribute enum_encoding: string;
	type states is (a_st, b_st);
	attribute enum_encoding of states: type is "0 1";
	signal current_state, next_state: states;

	-- registrador de saida de dados
	signal dout_reg	: std_logic_vector(7 downto 0);
	signal c_reg	: std_logic_vector(7 downto 0);
	-- registrador de memorizacao da entrada do dip switch
	signal din_reg_0: std_logic_vector(7 downto 0);
	signal din_reg_1: std_logic_vector(7 downto 0);

begin

	fsm: process(current_state, ctrl_sel, din_reg_0, din_reg_1)
	begin
		case current_state is
			when a_st =>
				if (ctrl_sel = '0')then
					next_state <= a_st;
				else 
					next_state <= b_st;	
				end if;
				
			when b_st =>
				if (din_reg_0 = din_reg_1) then
					next_state <= b_st;
				else
					next_state <= a_st;
				end if;
	
			when others =>
				next_state <= a_st;			
		end case;
	end process fsm;
	
	rtl: process (ctrl_clk)
	begin
		if(ctrl_clk'event and ctrl_clk=CLK_EDGE)then
			if (ctrl_rst = RST_ACTIVE) then
				current_state <= a_st;
			else
				case current_state is
					when a_st =>
						dout_reg <= din_reg_0;

					when b_st =>	
						dout_reg <= c_reg;

					when others =>
						null;
				end case;
				
			din_reg_0		<= ctrl_din;
			din_reg_1		<= din_reg_0;
			c_reg			<= ctrl_c;
			current_state	<= next_state;
			end if;
		end if;	
	end process rtl;

	-- saida
	ctrl_dout <= dout_reg;
end behavioral ;
