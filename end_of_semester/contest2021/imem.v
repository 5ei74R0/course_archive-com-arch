`include "def.h"
module imem (
    input [15:0] a,  // (/ward)
    output [`DATA_W-1:0] rd_a,
    output [`DATA_W-1:0] rd_b
);

	reg [`DATA_W-1:0] mem[0:`DEPTH-1];

	assign rd_a = mem[a];
	assign rd_b = mem[a + 1];

	initial begin
        $readmemb("imem.dat", mem);
    end

endmodule
