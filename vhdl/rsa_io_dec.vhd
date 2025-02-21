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
-- Resumo: decodificador de display de sete segmentos. Conversao de binario
-- hexadecimal. Saída multiplexada. Cada bit e representado por uma letra,
-- conforme esquema abaixo. Numeros hexadecimais A, B, C, D, E e F sao sinalizados
-- por mais um led (letra h).
--
-- Interface:
--			 _______
-- 			|		|
-- dec_clk -|		|- dec_lcd0
-- 			|		|
-- dec_bin -|		|- dec_lcd1
--			|_______|
--
-- --------------------------------------------------------------------------
-- |Pino	|Tamanho|Direcao|Ativo	|Descricao								|
-- |------------------------------------------------------------------------|
-- |dec_clk	|1		|in		|user	|Relogio do sistema.					|
-- |------------------------------------------------------------------------|
-- |dec_bin	|8		|in		|-		|Entrada de dados. Resultado da cifragem|
-- |		|		|		|		|cifragem do coprocessador em binario.	|
-- |------------------------------------------------------------------------|
-- |dec_lcd0|8		|out	|low	|Habilita leds do display de	_____	|
-- |		|		|		|		|sete segmentos quando em zero |  0  |  |
-- |		|		|		|		|logico, conforme indicado ao 5|     |1	|
-- |		|		|		|		|lado. O bit menos significa   |_____|  |
-- |		|		|		|		|tivo e utilizado para sina-   |  6  |  |
-- |		|		|		|		|lizar a ocorrencia de um nu- 4|     |2 |
-- |		|		|		|		|mero hexadecimal (pode ser    |_____|  |
-- |		|		|		|		|usado para ligar um led.         3     |
-- |------------------------------------------------------------------------|
-- |dec_lcd1|8		|out	|low	|Habilita leds do display de	_____	|
-- |		|		|		|		|sete segmentos quando em zero |  0  |  |
-- |		|		|		|		|logico, conforme indicado ao 5|     |1	|
-- |		|		|		|		|lado. O bit menos significa   |_____|  |
-- |		|		|		|		|tivo e utilizado para sina-   |  6  |  |
-- |		|		|		|		|lizar a ocorrencia de um nu- 4|     |2 |
-- |		|		|		|		|mero hexadecimal (pode ser    |_____|  |
-- |		|		|		|		|usado para ligar um led.         3     |
-- --------------------------------------------------------------------------
--
-- Total de IOs: 25 pinos
--
-- Parametros genericos:
--
-- --------------------------------------------------------------------------
-- |Parametro		|Descricao												|
-- |------------------------------------------------------------------------|
-- |CLK_EDGE		|define borda que dados serão capturados nos resgistra- |
-- |				|dores:													|
-- |				|														|
-- |				|CLK_EDGE = 1 => borda de subida						|
-- |				|CLK_EDGE = 0 => borda de descida						|
-- --------------------------------------------------------------------------
-------------------------------------------------------------------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
-------------------------------------------------------------------------------
entity rsa_io_dec is
	generic(
		CLK_EDGE	: std_logic := '1');
	port (
		dec_clk	: in	std_logic;
		dec_bin	: in 	std_logic_vector(7 downto 0);
		dec_lcd0: out 	std_logic_vector(7 downto 0);
		dec_lcd1: out 	std_logic_vector(7 downto 0));
end rsa_io_dec;
-------------------------------------------------------------------------------
architecture behavioral of rsa_io_dec is
	-- registradores internos
	signal bin_reg	: std_logic_vector(7 downto 0);
	signal lcd_reg0	: std_logic_vector(7 downto 0);
	signal lcd_reg1	: std_logic_vector(7 downto 0);

	-- sinais internos
	signal lcd_sig0	: std_logic_vector(7 downto 0);
	signal lcd_sig1	: std_logic_vector(7 downto 0);
	
begin

	-- tranferencia entre registradores
	rtl: process(dec_clk)
	begin
		if(dec_clk'event and dec_clk=CLK_EDGE)then
			-- registra dados de entrada
			bin_reg	<= dec_bin;
			-- registra dados codificados
			lcd_reg0 <= lcd_sig0;
			lcd_reg1 <= lcd_sig1;
		end if;
	end process rtl;
	
	dec_logic_0: with bin_reg(3 downto 0) select
		-- 			 76543210
		lcd_sig0<=	"00000010" when "0000",
					"10011110" when "0001",
					"00100100" when "0010",
					"00001100" when "0011",
					"10011000" when "0100",
					"01001000" when "0101",
					"01000000" when "0110",
					"00011110" when "0111",
					"00000000" when "1000",
					"00001000" when "1001",
					"00010001" when "1010",
					"00000001" when "1011",
					"01100011" when "1100",
					"00000011" when "1101",
					"01100001" when "1110",
					"01110001" when others;

	dec_logic_1: with bin_reg(7 downto 4) select
		-- 			 76543210
		lcd_sig1<=	"00000010" when "0000",
					"10011110" when "0001",
					"00100100" when "0010",
					"00001100" when "0011",
					"10011000" when "0100",
					"01001000" when "0101",
					"01000000" when "0110",
					"00011110" when "0111",
					"00000000" when "1000",
					"00001000" when "1001",
					"00010001" when "1010",
					"00000001" when "1011",
					"01100011" when "1100",
					"00000011" when "1101",
					"01100001" when "1110",
					"01110001" when others;
					
	-- conecta registrador a saida
	dec_lcd0 <= lcd_reg0;
	dec_lcd1 <= lcd_reg1;
end behavioral;
