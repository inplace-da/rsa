`timescale 1ns / 1ps
module rsa_io #(
    parameter CLK_EDGE   = 1'b1,
    parameter RST_ACTIVE = 1'b0
)(
    input           io_rsa_clk,
    input           io_rsa_rst,
    input   [7:0]   io_rsa_din,
    input           io_core_rdy,
    input   [7:0]   io_core_c,
    output  [15:0]  io_rsa_lcd
);

    // Sinal interna para conexão entre os blocos
    wire [7:0] ctrl_dout_sig;
    
    // Instancia do bloco rsa_io_ctrl
    rsa_io_ctrl #(
        .CLK_EDGE   (CLK_EDGE),
        .RST_ACTIVE (RST_ACTIVE)
    ) rsa_io_ctrl_blk (
        .ctrl_clk  (io_rsa_clk),
        .ctrl_rst  (io_rsa_rst),
        .ctrl_din  (io_rsa_din),
        .ctrl_sel  (io_core_rdy),
        .ctrl_c    (io_core_c),
        .ctrl_dout (ctrl_dout_sig)
    );
    
    // Instancia do bloco rsa_io_dec
    rsa_io_dec #(
        .CLK_EDGE (CLK_EDGE)
    ) rsa_io_dec_blk (
        .dec_clk   (io_rsa_clk),
        .dec_bin   (ctrl_dout_sig),
        .dec_lcd0  (io_rsa_lcd[7:0]),
        .dec_lcd1  (io_rsa_lcd[15:8])
    );

endmodule
