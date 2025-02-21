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
-- Projeto: coprocessador criptografico RSA. Operadores de entrada selecionados
-- através dos toggle switches localizados nas placasa. Controle de multiplexa-
-- gem de dados para visualizacao de operadores de entrada. Resultado final da
-- cigragem no display de 7 segmentos.
--
-- Algoritmo implementado: C =  M exp(e) mod n
-- Interface:
--		    ______
--		   |	  |
--	clk	  -|	  |
--	arst  -|	  |
--	       |      |- c
--	load  -|	  |
--	data  -|	  |
--		   |______|
--
-- --------------------------------------------------------------------------
-- |Pino		|Tamanho|Direcao|Ativo	|Descricao							|
-- |------------------------------------------------------------------------|
-- |clk			|1		|in		|user	|Relogio do sistema					|
-- |------------|-------|-------|-------|-----------------------------------|
-- |arst		|1		|in		|user	|Reset assincrono. Inicializa o co- |
-- |			|		|		|		|processador. Atualiza saída "c" com|
-- |			|		|		|		|valor selecionado em "data".       |
-- |------------|-------|-------|-------|-----------------------------------|
-- |load		|1		|in		|user	|Carrega dados em "data" e iniciali-|
-- |			|		|		|		|za processo de cifragem/decifragem.|
-- |------------|-------|-------|-------|-----------------------------------|
-- |data		|8		|in		|-		|Entrada da mensagem M e da chave	|
-- |			|		|		|		|publica/privada (e, d, n).			|
-- |------------|-------|-------|-------|-----------------------------------|
-- |c			|16		|out	|-		|Resultado da cifragem. Saida deco- |
-- |			|		|		|		|dificada para o display de 7 seg-  |
-- |			|		|		|		|mentos, em hexadecimal.			|
-- --------------------------------------------------------------------------
--
-- Total de IOs: 27 pinos
--
-- Parametros genericos:
--
-- --------------------------------------------------------------------------
-- |Parametro		|Descricao												|
-- |------------------------------------------------------------------------|
-- |DATA_SIZE		|define largura dos operadores do rsa em bits 			|
-- |				|(mensagem (M/C), expoente (e/d) e modulo n).			|
-- |------------------------------------------------------------------------|
-- |CLK_EDGE		|define borda que dados serão capturados nos resgistra- |
-- |				|registradores:											|
-- |				|														|
-- |				|CLK_EDGE = 1 => borda de subida						|
-- |				|CLK_EDGE = 0 => borda de descida						|
-- |------------------------------------------------------------------------|
-- |RST_ACTIVE		|define valor logico em que o sinal de reset esta ativo	|
-- |------------------------------------------------------------------------|
-- |LOAD_ACTIVE		|define valor logico em que o sinal de load esta ativo 	|
-- --------------------------------------------------------------------------
-------------------------------------------------------------------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
-------------------------------------------------------------------------------
entity rsa is
	generic(
 		DATA_WIDTH		: positive:= 8;
		CLK_EDGE		: std_logic := '1';	
		RESET			: std_logic := '0';
		LOAD			: std_logic := '0');

	port (
		-- entradas
		rsa_clk	: in std_logic;
		rsa_load: in std_logic;
		rsa_rst	: in std_logic;
		rsa_din	: in std_logic_vector(7 downto 0);
		
		-- saidas
		rsa_err : out std_logic;
		rsa_lcd	: out std_logic_vector(15 downto 0));
end rsa;
-------------------------------------------------------------------------------
architecture structural of rsa is
	component rsa_core is
		generic(
			DATA_WIDTH	: integer	:= 8;
			CLK_EDGE	: std_logic := '1';	
			RESET		: std_logic := '0';
			LOAD		: std_logic := '1');
		port (
			core_clk	: in std_logic;
			core_rst	: in std_logic;
			core_load	: in std_logic;
			core_din	: in std_logic_vector(DATA_WIDTH-1 downto 0);
			core_done	: out std_logic;
			core_err	: out std_logic;		
			core_dout	: out std_logic_vector(DATA_WIDTH-1 downto 0));
	end component;

	component rsa_io
		generic(
			CLK_EDGE	: std_logic := '1';	
			RST_ACTIVE	: std_logic := '0');
		port (
			io_rsa_clk	: in std_logic;
			io_rsa_rst	: in std_logic;
			io_rsa_din	: in std_logic_vector(7 downto 0);		
			io_core_rdy	: in std_logic;
			io_core_c	: in std_logic_vector(7 downto 0);
			io_rsa_lcd	: out std_logic_vector(15 downto 0));
	end component;	

	signal core_done_sig: std_logic;
	signal core_dat_o_sig: std_logic_vector(7 downto 0);
		
begin
	rsa_core_blk: rsa_core
		generic map(
			DATA_WIDTH	=> DATA_WIDTH,
			CLK_EDGE	=> CLK_EDGE,	
			RESET		=> RESET,
			LOAD		=> LOAD)
		port map(
			core_clk	=> rsa_clk,
			core_rst	=> rsa_rst,
			core_load	=> rsa_load,
			core_din	=> rsa_din,
			core_done	=> core_done_sig,
			core_err	=> rsa_err,	
			core_dout	=> core_dat_o_sig);

	rsa_io_blk: rsa_io
		generic map(
			CLK_EDGE	=> CLK_EDGE,
			RST_ACTIVE	=> RESET)
		port map(
			io_rsa_clk	=> rsa_clk,
			io_rsa_rst	=> rsa_rst,
			io_rsa_din	=> rsa_din,
			io_core_rdy	=> core_done_sig,
			io_core_c	=> core_dat_o_sig,
			io_rsa_lcd	=> rsa_lcd);			
end structural;
