`include "def.h"
module rfile (
	input clk,
	input [`REG_W-1:0] a1_a, a2_a, a3_a,
	input [`REG_W-1:0] a1_b, a2_b, a3_b,
	input [`DATA_W-1:0] wd3_a,
	input [`DATA_W-1:0] wd3_b,
	input we3_a,
	input we3_b,
	output [`DATA_W-1:0] rd1_a, rd2_a,
	output [`DATA_W-1:0] rd1_b, rd2_b
);

	reg [`DATA_W-1:0] rf[0:`REG-1];

	assign rd1_a = |a1_a == 0 ? 0: rf[a1_a];
	assign rd2_a = |a2_a == 0 ? 0: rf[a2_a];
	assign rd1_b = |a1_b == 0 ? 0: rf[a1_b];
	assign rd2_b = |a2_b == 0 ? 0: rf[a2_b];

	always @(negedge clk) begin
		if(we3_a) rf[a3_a] <= wd3_a;
		if(we3_b) rf[a3_b] <= wd3_b;
	end

endmodule
