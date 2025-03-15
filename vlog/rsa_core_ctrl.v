`timescale 1ns / 1ps

module rsa_core_ctrl #(
    parameter DATA_WIDTH = 8,
    parameter CLK_EDGE = 1'b1,
    parameter RESET = 1'b0,
    parameter LOAD = 1'b0
)(
    input wire ctrl_clk,
    input wire ctrl_rst,
    input wire ctrl_load,
    input wire [DATA_WIDTH-1:0] ctrl_din,
    input wire ctrl_loadx,
    input wire [DATA_WIDTH-1:0] ctrl_dinx,
    output ctrl_done,
    output ctrl_err,
    output [DATA_WIDTH-1:0] ctrl_c,
    output ctrl_start,
    output [DATA_WIDTH-1:0] ctrl_n,
    output [DATA_WIDTH-1:0] ctrl_m,
    output [DATA_WIDTH-1:0] ctrl_doutx
);

    localparam ONE = 8'd1;
    
    localparam [3:0] 
        INIT    = 4'd0,
        LOAD_M  = 4'd1,
        WAIT_M  = 4'd2,
        LOAD_E  = 4'd3,
        WAIT_E  = 4'd4,
        LOAD_N  = 4'd5,
        WAIT_N  = 4'd6,
        ERROR   = 4'd7,
        CASE0   = 4'd8,
        ANALYZE = 4'd9,
        DONE    = 4'd10,
        CASE1   = 4'd11,
        CASE2   = 4'd12,
        START   = 4'd13;
    
    reg [3:0]state_reg, state_ns;
    
    reg [DATA_WIDTH-1:0] n_reg;
    reg [DATA_WIDTH-1:0] e_reg;
    reg [DATA_WIDTH-1:0] m_reg;
    reg [DATA_WIDTH-1:0] x_reg;
    reg [DATA_WIDTH-1:0] c_reg;
    reg err_ff;
    reg start_ff;
    reg done_ff;
    
    assign ctrl_c = c_reg;
    assign ctrl_n = n_reg;
    assign ctrl_m = m_reg;
    assign ctrl_doutx = x_reg;
    
    assign ctrl_done = done_ff;
    assign ctrl_start = start_ff;
    assign ctrl_err = err_ff;
    
    always @(ctrl_rst, ctrl_load, n_reg, e_reg, ctrl_loadx, state_reg) begin
    	if (ctrl_rst == RESET)
			state_ns = INIT;
    	else
        	case (state_reg)
        	    INIT:	state_ns = LOAD_M;
        	    LOAD_M: state_ns = (ctrl_load == LOAD) ? WAIT_M : LOAD_M;
        	    WAIT_M: state_ns = (ctrl_load == LOAD) ? WAIT_M : LOAD_E;
        	    LOAD_E: state_ns = (ctrl_load == LOAD) ? WAIT_E : LOAD_E;
        	    WAIT_E: state_ns = (ctrl_load == LOAD) ? WAIT_E : LOAD_N;
        	    LOAD_N: state_ns = (ctrl_load == LOAD) ? WAIT_N : LOAD_N;
        	    WAIT_N: begin
        	        if (ctrl_load == LOAD)
        	            state_ns = WAIT_N;
        	        else if (n_reg == 0)
        	            state_ns = ERROR;
        	        else if (e_reg == 0)
        	            state_ns = CASE0;
        	        else if (e_reg == 1)
        	            state_ns = CASE1;
        	        else
        	            state_ns = CASE2;
        	    end
        	    ERROR: state_ns = LOAD_M;
        	    CASE0: state_ns = ANALYZE;
        	    
        	    ANALYZE: begin
        	        if (!ctrl_loadx)
        	            state_ns = ANALYZE;
        	        else
        	        	if (e_reg == 0)
        	            	state_ns = DONE;
	        	        else
        	            	state_ns = START;
        	    end
        	    DONE:	state_ns = LOAD_M;
        	    CASE1: state_ns = ANALYZE;
        	    CASE2: state_ns = ANALYZE;
        	    START: state_ns = ANALYZE;
        	    default: state_ns = INIT;
        	endcase
    end
    
    always @(posedge ctrl_clk) begin
		case (state_reg)
        	INIT: begin
            	err_ff <= 1'b0;
                start_ff <= 1'b0;
                done_ff <= 1'b0;
        	end
			LOAD_M: begin
            	m_reg <= ctrl_din;
                x_reg <= ctrl_din;
                done_ff <= 1'b0;
            end
            LOAD_E:
            	e_reg <= ctrl_din;
			LOAD_N:
				n_reg <= ctrl_din;
            ERROR: begin
            	done_ff <= 1'b1;
                err_ff <= 1'b1;
                c_reg <= {DATA_WIDTH{1'b1}};
            end
            CASE0: begin
				start_ff	<= 1'b1;
				m_reg		<= ONE;
				x_reg		<= ONE;
			end
			ANALYZE: begin
				x_reg		<= ctrl_dinx;
				start_ff	<= 1'b0;
			end	
			DONE: begin
				c_reg	<= x_reg;
				done_ff		<= 1'b1;
				err_ff		<= 1'b0;				
			end	
			CASE1: begin
				x_reg		<= ONE;
				start_ff	<= 1'b1;
				e_reg		<= e_reg - 1;
			end
			START: begin
				start_ff	<= 1'b1;
				e_reg		<= e_reg - 1;
            end
		endcase
        state_reg <= state_ns;
    end
endmodule
