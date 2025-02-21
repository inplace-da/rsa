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
-- Resumo: Bloco contendo interface de IO necessaria para intefacear entre os
-- componentes da placa de desenvolvimento e o core do coprocessador.
--
-- Interface:
--		    ______
--		   |	  |
--	clk	  -|	  |
--	rst   -|	  |- display
--	btn   -|	  |
--	dip   -|	  |
--		   |______|
--
-- --------------------------------------------------------------------------
-- |Pino		|Tamanho|Direcao|Ativo	|Descricao							|
-- |------------------------------------------------------------------------|
-- |clk			|1		|in		|user	|Relogio do sistema					|
-- |------------|-------|-------|-------|-----------------------------------|
-- |rst			|1		|in		|user	|Reset sincrono. Limpa display e	|
-- |			|		|		|		|atualiza com valor selecionado no	|
-- |			|		|		|		|dip switch.						|
-- |------------|-------|-------|-------|-----------------------------------|
-- |btn			|1		|in		|user	|Push button. Carrega dados e		|
-- |			|		|		|		|realiza a cifragem					|
-- |------------|-------|-------|-------|-----------------------------------|
-- |dip			|8		|in		|-		|Entrada de dados					|
-- |------------|-------|-------|-------|-----------------------------------|
-- |display		|16		|out	|-		|Saida decodificada para o display	|
-- |			|		|		|		|de 7 segmentos						|
-- --------------------------------------------------------------------------
--
-- Total de IOs: 27 pinos
--
-- Parametros genericos:
--
-- --------------------------------------------------------------------------
-- |Parametro			|Descricao											|
-- |------------------------------------------------------------------------|
-- |DATA_BIT_LENGTH		|define largura dos operadores do rsa em bits 		|
-- |					|(mensagem M, expoente e e modulo n).				|
-- |------------------------------------------------------------------------|
-- |CLK_EDGE			|define sensibilidade do clock						|
-- |					|CLK_EDGE = 1 => borda de subida					|
-- |					|CLK_EDGE = 0 => borda de descida					|
-- |------------------------------------------------------------------------|
-- |RST_ACTIVE			|valor logico ativo do sinal de reset				|
-- |------------------------------------------------------------------------|
-- |BTN_ACTIVE			|valor logico ativo do botao 						|
-- --------------------------------------------------------------------------
-------------------------------------------------------------------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
-------------------------------------------------------------------------------
entity rsa_io is
	generic(
		CLK_EDGE		: std_logic := '1';	
		RST_ACTIVE		: std_logic := '0');
	port (
		io_rsa_clk	: in std_logic;
		io_rsa_rst	: in std_logic;
		io_rsa_din	: in std_logic_vector(7 downto 0);		
		io_core_rdy	: in std_logic;
		io_core_c	: in std_logic_vector(7 downto 0);
		io_rsa_lcd	: out std_logic_vector(15 downto 0));
end rsa_io;
-------------------------------------------------------------------------------
architecture structural of rsa_io is
	component rsa_io_dec is
		generic(
			CLK_EDGE	: std_logic := '1');
		port (
			dec_clk	: in	std_logic;
			dec_bin	: in 	std_logic_vector(7 downto 0);
			dec_lcd0: out 	std_logic_vector(7 downto 0);
			dec_lcd1: out 	std_logic_vector(7 downto 0));
	end component;

	component rsa_io_ctrl is
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
	end component;
	
	signal ctrl_dout_sig: std_logic_vector(7 downto 0);    

begin

	rsa_io_ctrl_blk: rsa_io_ctrl
		generic map(
			CLK_EDGE	=> CLK_EDGE,
			RST_ACTIVE	=> RST_ACTIVE)		
		port map(
			ctrl_clk	=> io_rsa_clk,
			ctrl_rst	=> io_rsa_rst,
			ctrl_din	=> io_rsa_din,
			ctrl_sel	=> io_core_rdy,
			ctrl_c		=> io_core_c,
			ctrl_dout	=> ctrl_dout_sig);
			
	rsa_io_dec_blk: rsa_io_dec
		generic map(
			CLK_EDGE	=> CLK_EDGE)
		port map(
			dec_clk		=> io_rsa_clk,
			dec_bin		=> ctrl_dout_sig,
			dec_lcd0	=> io_rsa_lcd(7 downto 0),
			dec_lcd1	=> io_rsa_lcd(15 downto 8));
end structural;
