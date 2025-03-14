`timescale 1ns/1ps

module rsa_core_mult #(
  parameter DATA_WIDTH = 8,
  parameter CLK_EDGE   = 1,
  parameter RESET      = 0,
  parameter START      = 1
) (
  input                       mult_clk,
  input                       mult_rst,
  input                       mult_start,
  input  [DATA_WIDTH-1:0]     mult_a,
  input  [DATA_WIDTH-1:0]     mult_b,
  output                      mult_done,
  output [2*DATA_WIDTH-1:0]   mult_c
);

  // Manual calculation of the number of bits required for a_cnt
  localparam BIT_WIDTH =
   (DATA_WIDTH == 1) ? 1:
   (DATA_WIDTH <= 2) ? 1:
   (DATA_WIDTH <= 4) ? 2:
   (DATA_WIDTH <= 8) ? 3:
   (DATA_WIDTH <= 16) ? 4:
   (DATA_WIDTH <= 32) ? 5:6;

  // Explicitly size the state constants as 3-bit numbers
  localparam [2:0] INIT      = 3'd0,
                   ANALYZE   = 3'd1,
                   SHIFT_ADD = 3'd2,
                   SHIFT     = 3'd3,
                   DONE      = 3'd4;

  reg [2:0] state_reg, state_ns;
  reg [BIT_WIDTH-1:0] a_cnt;
  reg [DATA_WIDTH-1:0] a_reg, b_reg;
  reg [2*DATA_WIDTH-1:0] p_reg, c_reg;
  reg done_ff;

  wire actual_clk = CLK_EDGE ? mult_clk : ~mult_clk;

  assign mult_done = done_ff;
  assign mult_c    = c_reg;

  always @* begin
    if (mult_rst == RESET) begin
      state_ns = INIT;
    end else begin
      case(state_reg)
        INIT: state_ns = (mult_start == START) ? ANALYZE : INIT;
        ANALYZE: state_ns = (b_reg[DATA_WIDTH-1]) ? SHIFT_ADD : SHIFT;
        SHIFT_ADD: begin
          if (a_cnt != (DATA_WIDTH-1))
            state_ns = (b_reg[DATA_WIDTH-1]) ? SHIFT_ADD : SHIFT;
          else
            state_ns = DONE;
        end
        SHIFT: begin
          if (a_cnt != (DATA_WIDTH-1))
            state_ns = (b_reg[DATA_WIDTH-1]) ? SHIFT_ADD : SHIFT;
          else
            state_ns = DONE;
        end
        DONE: state_ns = INIT;
        default: state_ns = INIT;
      endcase
    end
  end

  always @(posedge actual_clk) begin
    if (mult_rst == RESET) begin
      state_reg <= INIT;
      p_reg     <= 0;
      a_cnt     <= 0;
      done_ff   <= 0;
      a_reg     <= 0;
      b_reg     <= 0;
      c_reg     <= 0;
    end else begin
      state_reg <= state_ns;
      case(state_reg)
        INIT: begin
          p_reg   <= 0;
          a_cnt   <= 0;
          done_ff <= 0;
          a_reg   <= mult_a;
          b_reg   <= mult_b;
        end
        ANALYZE: begin
          b_reg <= {b_reg[DATA_WIDTH-2:0], 1'b0};
        end
        SHIFT_ADD: begin
          p_reg <= a_reg + {p_reg[2*DATA_WIDTH-2:0], 1'b0};
          a_cnt <= a_cnt + 1'b1;
          b_reg <= {b_reg[DATA_WIDTH-2:0], 1'b0};
        end
        SHIFT: begin
          p_reg <= {p_reg[2*DATA_WIDTH-2:0], 1'b0};
          a_cnt <= a_cnt + 1'b1;
          b_reg <= {b_reg[DATA_WIDTH-2:0], 1'b0};
        end
        DONE: begin
          done_ff <= 1'b1;
          c_reg   <= p_reg;
        end
      endcase
    end
  end

endmodule
