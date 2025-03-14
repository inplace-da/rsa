`timescale 1ns / 1ps

module rsa #(
    parameter DATA_WIDTH = 8,
    parameter CLK_EDGE   = 1'b1,
    parameter RESET      = 1'b0,
    parameter LOAD       = 1'b0
)(
    // Entradas
    input            rsa_clk,
    input            rsa_load,
    input            rsa_rst,
    input  [7:0]     rsa_din,
    // Saídas
    output           rsa_err,
    output [15:0]    rsa_lcd
);

    // Sinais internos
    wire             core_done_sig;
    wire  [7:0]      core_dat_o_sig;

    // Instanciação do módulo rsa_core
    rsa_core #(
        .DATA_WIDTH(DATA_WIDTH),
        .CLK_EDGE  (CLK_EDGE),
        .RESET     (RESET),
        .LOAD      (LOAD)
    ) rsa_core_blk (
        .core_clk  (rsa_clk),
        .core_rst  (rsa_rst),
        .core_load (rsa_load),
        .core_din  (rsa_din),
        .core_done(core_done_sig),
        .core_err (rsa_err),
        .core_dout(core_dat_o_sig)
    );

    // Instanciação do módulo rsa_io
    rsa_io #(
        .CLK_EDGE  (CLK_EDGE),
        .RST_ACTIVE(RESET)
    ) rsa_io_blk (
        .io_rsa_clk (rsa_clk),
        .io_rsa_rst (rsa_rst),
        .io_rsa_din (rsa_din),
        .io_core_rdy(core_done_sig),
        .io_core_c  (core_dat_o_sig),
        .io_rsa_lcd (rsa_lcd)
    );

endmodule
