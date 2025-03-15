`timescale 1ns / 1ps
// PARAMETROS:
//   DATA_WIDTH  : Largura dos dados (default 8)
//   CLK_EDGE    : Sensibilidade da borda do clock (1 para posedge, 0 para negedge)
//   RESET       : Nível ativo do reset (default 0)
//   START       : Nível ativo do sinal de início (default 1)

module rsa_core_mod #(
    parameter DATA_WIDTH = 8,
    parameter CLK_EDGE   = 1,   // 1: borda de subida, 0: borda de descida
    parameter RESET      = 0,   // Nível de reset ativo
    parameter START      = 1    // Nível ativo para mod_start
)(
    input                         mod_clk,
    input                         mod_rst,
    input                         mod_start,
    input      [2*DATA_WIDTH-1:0] mod_a,
    input      [DATA_WIDTH-1:0]    mod_b,
    output                        mod_done,
    output                        mod_err,
    output     [DATA_WIDTH-1:0]   mod_c
);

  // Definição dos estados da FSM (8 estados)
  localparam INIT     = 3'b000,
             CHECK    = 3'b001,
             PREPARE  = 3'b010,
             COMPARE  = 3'b011,
             SUBTRACT = 3'b100,
             SHIFT    = 3'b101,
             DONE     = 3'b110,
             ERROR    = 3'b111;

  // Declaração dos sinais internos
  reg 	[2:0] state_reg, state_ns;
  reg	[DATA_WIDTH:0] a_cnt;
  reg	[2*DATA_WIDTH-1:0] t_reg, n_reg;
  reg	[DATA_WIDTH-1:0] r_reg;
  reg	mod_done_ff, mod_err_ff;

  // Atribuição das saídas
  assign mod_done = mod_done_ff;
  assign mod_err  = mod_err_ff;
  assign mod_c    = r_reg;

  // Lógica combinacional para o cálculo do próximo estado (FSM)
  always @(mod_rst, mod_start, t_reg, n_reg, a_cnt, state_reg) begin
    if (mod_rst == RESET)
      state_ns = INIT;
    else begin
      case (state_reg)
        INIT: begin
          if (mod_start == START)
            state_ns = CHECK;
          else
            state_ns = INIT;
        end
        CHECK: begin
          if (n_reg[DATA_WIDTH-1:0] == {DATA_WIDTH{1'b0}})
            state_ns = ERROR;
          else
            state_ns = PREPARE;
        end
        PREPARE: begin
          if (n_reg[2*DATA_WIDTH-2] == 1'b0)
            state_ns = PREPARE;
          else
            state_ns = COMPARE;
        end
        COMPARE: begin
          if (t_reg >= n_reg)
            state_ns = SUBTRACT;
          else
            state_ns = SHIFT;
        end
        SUBTRACT: begin
          if (a_cnt != 0)
            state_ns = COMPARE;
          else
            state_ns = DONE;
        end
        SHIFT: begin
          if (a_cnt != 0)
            state_ns = COMPARE;
          else
            state_ns = DONE;
        end
        DONE:  state_ns = INIT;
        ERROR: state_ns = INIT;
        default: state_ns = INIT;
      endcase
    end
  end

  // Bloco sequencial – o clock edge (posedge ou negedge) é escolhido via generate
      always @(posedge mod_clk) begin
        case (state_reg)
          INIT: begin
            mod_done_ff <= 1'b0;
            t_reg       <= mod_a;
            n_reg[DATA_WIDTH-1:0] <= mod_b;
            n_reg[2*DATA_WIDTH-1:DATA_WIDTH] <= {DATA_WIDTH{1'b0}};
            a_cnt       <= {DATA_WIDTH+1{1'b0}};
          end
          CHECK: begin
            // Nada a transferir nesta fase
          end
          PREPARE: begin
            a_cnt <= a_cnt + 1'b1;
            n_reg <= { n_reg[2*DATA_WIDTH-2:0], 1'b0 };
          end
          COMPARE: begin
            // Nenhuma transferência nesta fase
          end
          SUBTRACT: begin
            t_reg <= t_reg - n_reg;
            n_reg <= { 1'b0, n_reg[2*DATA_WIDTH-1:1] };
            a_cnt <= a_cnt - 1'b1;
          end
          SHIFT: begin
            n_reg <= { 1'b0, n_reg[2*DATA_WIDTH-1:1] };
            a_cnt <= a_cnt - 1'b1;
          end
          DONE: begin
            r_reg       <= t_reg[DATA_WIDTH-1:0];
            mod_done_ff <= 1'b1;
            mod_err_ff  <= 1'b0;
          end
          ERROR: begin
            mod_err_ff  <= 1'b1;
            mod_done_ff <= 1'b1;
            r_reg       <= {DATA_WIDTH{1'b1}};
          end
          default: begin
            // Não faz nada
          end
        endcase
        state_reg <= state_ns;
      end
endmodule
