`include "def.h"
module dmem (
	input clk,
	input [15:0] a_a,
	input [15:0] a_b,
	input [`DATA_W-1:0] wd_a,
	input [`DATA_W-1:0] wd_b,
	input we_a,
	input we_b,
	output [`DATA_W-1:0] rd_a,
	output [`DATA_W-1:0] rd_b
);

	reg [`DATA_W-1:0] mem[0:`DEPTH-1];

	assign rd_a = mem[a_a];
	assign rd_b = mem[a_b];

	always @(posedge clk)  begin
		if(we_a) mem[a_a] <= wd_a;
		if(we_b) mem[a_b] <= wd_b;
	end
	initial begin
        $readmemh("dmem.dat", mem);
    end

endmodule
