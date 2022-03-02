`include "def.h"

module alu (
    input [`DATA_W-1:0] a, b, 
    input [2:0] s, 
    input ext,addcom,
    output [`DATA_W-1:0] y
);

    wire [4:0] shamt;
    wire signed [31:0] sa, sb, sy, slt;
    wire [31:0] sltu;
    wire [31:0] yy;
    assign sa = $signed(a);
    assign sb = $signed(b);
    assign shamt = b[4:0];
    assign sy = sa >>> shamt;
    assign sltu = a < b ? 1 : 0;
    assign slt = sa < sb ? 1 : 0;
    assign y = addcom ? a + b : yy;
    assign yy = s == `ALU_ADD & ext ? a-b:
                s == `ALU_ADD & ~ext ? a+b:
                s == `ALU_XOR ? a ^ b:
                s == `ALU_OR ? a | b:
                s == `ALU_AND ? a & b:
                s == `ALU_SLT ? slt:
                s == `ALU_SLTU ? sltu:
                s == `ALU_SLL ? a << shamt:
                s == `ALU_SRL & ~ext ? a >> shamt:
                s == `ALU_SRL & ext ? sy: 0;

endmodule
