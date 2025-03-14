`timescale 1ns/1ps

// Nome do Arquivo: rsa_io_ctrl.vhd
// Descrição: Controle de multiplexagem de dados para display de 7 segmentos.
// Multiplexa entrada entre os toggle switches e outra entrada (ctrl_c). Sempre que os
// switches forem alterados, seu valor é multiplexado para a saída.

module rsa_io_ctrl #(
    parameter CLK_EDGE   = 1'b1,  // Define a borda de clock (1'b1 para posedge, 1'b0 para negedge)
    parameter RST_ACTIVE = 1'b0   // Nível ativo de reset
)(
    input        ctrl_clk,      // Relógio do sistema
    input        ctrl_rst,      // Reset assíncrono (reset síncrono conforme código original)
    input  [7:0] ctrl_din,      // Entrada de dados (display de 7 segmentos)
    input        ctrl_sel,      // Habilita entrada ctrl_c para ser registrada na saída
    input  [7:0] ctrl_c,        // Entrada do operador
    output [7:0] ctrl_dout      // Saída multiplexada
);

    // Definição dos estados da FSM
    localparam A_ST = 1'b0;
    localparam B_ST = 1'b1;

    reg current_state, next_state;

    // Registradores internos
    reg [7:0] dout_reg;     // Registrador de saída
    reg [7:0] c_reg;        // Registrador para memorizar ctrl_c
    reg [7:0] din_reg_0;    // Registrador para memorizar a entrada do dip switch
    reg [7:0] din_reg_1;    // Registrador de atraso para comparar com din_reg_0

    // Bloco combinacional: Máquina de Estados (FSM)
    always @(*) begin
        case (current_state)
            A_ST: begin
                if (ctrl_sel == 1'b0)
                    next_state = A_ST;
                else
                    next_state = B_ST;
            end
            B_ST: begin
                if (din_reg_0 == din_reg_1)
                    next_state = B_ST;
                else
                    next_state = A_ST;
            end
            default: next_state = A_ST;
        endcase
    end

    // Bloco sequencial: Registro e atualizações (síncrono com o clock)
    generate
        if (CLK_EDGE == 1'b1) begin : pos_edge
            always @(posedge ctrl_clk) begin
                if (ctrl_rst == RST_ACTIVE)
                    current_state <= A_ST;
                else begin
                    case (current_state)
                        A_ST: dout_reg <= din_reg_0;
                        B_ST: dout_reg <= c_reg;
                        default: ;
                    endcase
                    // Atualização dos registradores
                    din_reg_0    <= ctrl_din;
                    din_reg_1    <= din_reg_0;
                    c_reg        <= ctrl_c;
                    current_state <= next_state;
                end
            end
        end else begin : neg_edge
            always @(negedge ctrl_clk) begin
                if (ctrl_rst == RST_ACTIVE)
                    current_state <= A_ST;
                else begin
                    case (current_state)
                        A_ST: dout_reg <= din_reg_0;
                        B_ST: dout_reg <= c_reg;
                        default: ;
                    endcase
                    // Atualização dos registradores
                    din_reg_0    <= ctrl_din;
                    din_reg_1    <= din_reg_0;
                    c_reg        <= ctrl_c;
                    current_state <= next_state;
                end
            end
        end
    endgenerate

    // Atribuição da saída
    assign ctrl_dout = dout_reg;

endmodule
