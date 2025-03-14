`timescale 1ns/1ps

module rsa_io_dec #(
    parameter CLK_EDGE = 1'b1  // Define a borda para captura dos dados: 1'b1 para subida, 1'b0 para descida
)(
    input             dec_clk,    // Relógio do sistema
    input      [7:0]  dec_bin,    // Entrada de dados (resultado da cifragem em binário)
    output     [7:0]  dec_lcd0,   // Saída multiplexada (display de 7 segmentos - parte 0)
    output     [7:0]  dec_lcd1    // Saída multiplexada (display de 7 segmentos - parte 1)
);

    // Registradores internos
    reg [7:0] bin_reg;
    reg [7:0] lcd_reg0;
    reg [7:0] lcd_reg1;

    // Sinais combinacionais internos
    reg [7:0] lcd_sig0;
    reg [7:0] lcd_sig1;

    // Transferência entre registradores: captura de dec_bin e dos sinais codificados
    generate
        if (CLK_EDGE == 1'b1) begin : pos_edge
            always @(posedge dec_clk) begin
                bin_reg  <= dec_bin;
                lcd_reg0 <= lcd_sig0;
                lcd_reg1 <= lcd_sig1;
            end
        end else begin : neg_edge
            always @(negedge dec_clk) begin
                bin_reg  <= dec_bin;
                lcd_reg0 <= lcd_sig0;
                lcd_reg1 <= lcd_sig1;
            end
        end
    endgenerate

    // Lógica combinacional para decodificar o nibble menos significativo (bits 3:0)
    always @(*) begin
        case (bin_reg[3:0])
            4'b0000: lcd_sig0 = 8'b00000010;
            4'b0001: lcd_sig0 = 8'b10011110;
            4'b0010: lcd_sig0 = 8'b00100100;
            4'b0011: lcd_sig0 = 8'b00001100;
            4'b0100: lcd_sig0 = 8'b10011000;
            4'b0101: lcd_sig0 = 8'b01001000;
            4'b0110: lcd_sig0 = 8'b01000000;
            4'b0111: lcd_sig0 = 8'b00011110;
            4'b1000: lcd_sig0 = 8'b00000000;
            4'b1001: lcd_sig0 = 8'b00001000;
            4'b1010: lcd_sig0 = 8'b00010001;
            4'b1011: lcd_sig0 = 8'b00000001;
            4'b1100: lcd_sig0 = 8'b01100011;
            4'b1101: lcd_sig0 = 8'b00000011;
            4'b1110: lcd_sig0 = 8'b01100001;
            default: lcd_sig0 = 8'b01110001;
        endcase
    end

    // Lógica combinacional para decodificar o nibble mais significativo (bits 7:4)
    always @(*) begin
        case (bin_reg[7:4])
            4'b0000: lcd_sig1 = 8'b00000010;
            4'b0001: lcd_sig1 = 8'b10011110;
            4'b0010: lcd_sig1 = 8'b00100100;
            4'b0011: lcd_sig1 = 8'b00001100;
            4'b0100: lcd_sig1 = 8'b10011000;
            4'b0101: lcd_sig1 = 8'b01001000;
            4'b0110: lcd_sig1 = 8'b01000000;
            4'b0111: lcd_sig1 = 8'b00011110;
            4'b1000: lcd_sig1 = 8'b00000000;
            4'b1001: lcd_sig1 = 8'b00001000;
            4'b1010: lcd_sig1 = 8'b00010001;
            4'b1011: lcd_sig1 = 8'b00000001;
            4'b1100: lcd_sig1 = 8'b01100011;
            4'b1101: lcd_sig1 = 8'b00000011;
            4'b1110: lcd_sig1 = 8'b01100001;
            default: lcd_sig1 = 8'b01110001;
        endcase
    end

    // Conecta os registradores de saída às portas do módulo
    assign dec_lcd0 = lcd_reg0;
    assign dec_lcd1 = lcd_reg1;

endmodule
