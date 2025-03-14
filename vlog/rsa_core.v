`timescale 1ns / 1ps

module rsa_core #(
    parameter DATA_WIDTH = 8,
    parameter CLK_EDGE = 1'b1,
    parameter RESET = 1'b0,
    parameter LOAD = 1'b0
)
(
    input wire core_clk,
    input wire core_rst,
    input wire core_load,
    input wire [DATA_WIDTH-1:0] core_din,
    output wire core_done,
    output wire core_err,
    output wire [DATA_WIDTH-1:0] core_dout
);

    // Internal signals
    wire ctrl_start_sig;
    wire [DATA_WIDTH-1:0] ctrl_m_sig;
    wire [DATA_WIDTH-1:0] ctrl_n_sig;
    wire [DATA_WIDTH-1:0] ctrl_doutx_sig;

    wire mult_done_sig;
    wire [2*DATA_WIDTH-1:0] mult_c_sig;

    wire mod_done_sig;
    wire [DATA_WIDTH-1:0] mod_c_sig;

    // Component instantiations
    rsa_core_mult #(
        .DATA_WIDTH(DATA_WIDTH),
        .CLK_EDGE(CLK_EDGE),
        .RESET(RESET)
    ) rsa_core_mult_blk (
        .mult_clk(core_clk),
        .mult_rst(core_rst),
        .mult_start(ctrl_start_sig),
        .mult_a(ctrl_m_sig),
        .mult_b(ctrl_doutx_sig),
        .mult_done(mult_done_sig),
        .mult_c(mult_c_sig)
    );

    rsa_core_mod #(
        .DATA_WIDTH(DATA_WIDTH),
        .CLK_EDGE(CLK_EDGE),
        .RESET(RESET)
    ) rsa_core_mod_blk (
        .mod_clk(core_clk),
        .mod_rst(core_rst),
        .mod_start(mult_done_sig),
        .mod_a(mult_c_sig),
        .mod_b(ctrl_n_sig),
        .mod_done(mod_done_sig),
        .mod_err(), // Deixe isso desconectado apenas se for realmente necessário
        .mod_c(mod_c_sig)
    );

    rsa_core_ctrl #(
        .DATA_WIDTH(DATA_WIDTH),
        .CLK_EDGE(CLK_EDGE),
        .RESET(RESET),
        .LOAD(LOAD)
    ) rsa_core_ctrl_blk (
        .ctrl_clk(core_clk),
        .ctrl_rst(core_rst),
        .ctrl_load(core_load),
        .ctrl_din(core_din),
        .ctrl_loadx(mod_done_sig),
        .ctrl_dinx(mod_c_sig),
        .ctrl_done(core_done),
        .ctrl_err(core_err),
        .ctrl_c(core_dout),
        .ctrl_start(ctrl_start_sig),
        .ctrl_n(ctrl_n_sig),
        .ctrl_m(ctrl_m_sig),
        .ctrl_doutx(ctrl_doutx_sig)
    );

endmodule
