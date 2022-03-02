`define DATA_W 32 
`define SEL_W 6
`define REG 32
`define REG_W 5
`define OPCODE_W 7
`define SHAMT_W 5
`define LANE_W 4
`define IMM_W 16
`define JIMM_W 26
`define DEPTH 65536

`define ALU_ADD 3'b000
`define ALU_SLL 3'b001
`define ALU_SRL 3'b101
`define ALU_SLT 3'b010
`define ALU_SLTU 3'b011
`define ALU_XOR 3'b100
`define ALU_OR 3'b110
`define ALU_AND 3'b111

`define ENABLE 1'b1
`define DISABLE 1'b0
`define ENABLE_N 1'b0
`define DISABLE_N 1'b1

`define OP_REG `OPCODE_W'b0110011
`define OP_IMM `OPCODE_W'b0010011
`define OP_BRA `OPCODE_W'b1100011
`define OP_JAL `OPCODE_W'b1101111
`define OP_JALR `OPCODE_W'b1100111
`define OP_LOAD `OPCODE_W'b0000011
`define OP_STORE `OPCODE_W'b0100011
`define OP_LUI `OPCODE_W'b0110111
`define OP_SPE `OPCODE_W'b1110011
`define NOP 32'b0000000000000000000000000_0110011

