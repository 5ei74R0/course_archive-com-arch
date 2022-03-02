`include "def.h"
module rv32i(
    input clk, rst_n,
    input [`DATA_W-1:0] instr_a, instr_b,  // read from imem
    input [`DATA_W-1:0] readdata_a, readdata_b,  // read from dmem
    output reg [`DATA_W-1:0] pc,  // output to imem
    output [`DATA_W-1:0] adrdata_a, adrdata_b,  // output to dmem
    output [`DATA_W-1:0] writedata_a, writedata_b,  // output to dmem
    output we_a, we_b,  // output to dmem
    output ecall
);


    /*  Instruction Fetch Stage */
    reg [`DATA_W-1:0] pcplus8D;
    wire [`DATA_W-1:0] pcplus8;
    wire [`DATA_W-1:0] pcbranchD_a, pcbranchD_b;
    reg [`DATA_W-1:0] instrD_a, instrD_b;
    wire stall, stall_a, stall_b;
    wire btakenD_a, btakenD_b;
    wire bra_op_a, bra_op_b;
    assign pcplus8 = pc + 8;
    assign stall = stall_a | stall_b;

    // for each cycle in the Instruction Fetch Stage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin  // init
            instrD_a <= 0;
            instrD_b <= 0;
        end
        else begin  // for every cycle
            if (stall_a) begin
                // instrD_a <= instrD_a  // redecode instruction-a
                // instrD_b <= instrD_b  // redecode instruction-b
            end
            // else if (bra_op_a) begin
            else if (btakenD_a) begin
                instrD_a <= `NOP;  // disable fetched instruction-a
                instrD_b <= `NOP;  // disable fetched instruction-b
            end
            else if (stall_b) begin
                instrD_a <= `NOP;  // set NOP to the next instruction-a
                // instrD_b <= instrD_b  // redecode instruction-b
            end
            // else if (bra_op_b) begin
            else if (btakenD_b) begin
                instrD_a <= `NOP;  // disable fetched instruction-a
                instrD_b <= `NOP;  // disable fetched instruction-b
            end
            else begin  // 2 instructions are ready to exe.
                instrD_a <= instr_a;  // set next instruction to I.D. Stage
                instrD_b <= instr_b;  // set next instruction to I.D. Stage
            end
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin  // init
            pc <= 0;
        end
        else begin  // for every cycle
            if (stall_a) begin
                // pc <= pc  // stop the program counter
            end
            else if (btakenD_a) begin
                pc <= pcbranchD_a;  // jump!
            end
            else if (stall_b) begin
                // pc <= pc  // stop the program counter
            end
            else if (btakenD_b) begin
                pc <= pcbranchD_b;  // jump!
            end
            else begin  // 2 instructions are ready to exe.
                pc <= pcplus8;  // read next 2 instructions
            end
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin  // init
            pcplus8D <= 0;
        end
        else begin  // for every cycle
            if (!stall) pcplus8D <= pcplus8;
            // else pcplus8D <= pcplus8D;  // stop the program counter
        end
    end


    /*  Instruction Decoder Stage */
    wire addcom_a, addcom_b;
    wire [2:0] funct3_a, funct3_b;
    wire [6:0] funct7_a, funct7_b;
    wire [`REG_W-1:0] rs1_a, rs2_a, rd_a;
    wire [`REG_W-1:0] rs1_b, rs2_b, rd_b;
    wire [`DATA_W-1:0] reg1_a, reg2_a, reg1f_a, reg2f_a;
    wire [`DATA_W-1:0] reg1_b, reg2_b, reg1f_b, reg2f_b;
    wire [`OPCODE_W-1:0] opcode_a, opcode_b;
    wire [`SHAMT_W-1:0] shamt_a, shamt_b;
    wire [`OPCODE_W-1:0] func_a, func_b;
    wire [11:0] imm_i_a, imm_s_a;
    wire [11:0] imm_i_b, imm_s_b;
    wire [12:0] imm_b_a, imm_b_b;
    wire [20:0] imm_j_a, imm_u_a;
    wire [20:0] imm_j_b, imm_u_b;
    wire rwe_a, rwe_b;
    wire alu_op_a, imm_op_a;
    wire alu_op_b, imm_op_b;
    wire sw_op_a, beq_op_a, bne_op_a, blt_op_a, bge_op_a, bltu_op_a, bgeu_op_a, lw_op_a;
    wire sw_op_b, beq_op_b, bne_op_b, blt_op_b, bge_op_b, bltu_op_b, bgeu_op_b, lw_op_b;
    wire slt_op_a, ecall_op_a;
    wire slt_op_b, ecall_op_b;
    wire lui_op_a, lui_op_b;
    wire ext_a, ext_b;
    wire signed [31:0] sreg1_a, sreg2_a;
    wire [19:0] sext_a, sext_b;
    wire [`DATA_W-1:0] imm_a, imm_b;

    // pipeline registers
    reg [`DATA_W-1:0] immE_a, reg1E_a, reg2E_a;
    reg [`DATA_W-1:0] immE_b, reg1E_b, reg2E_b;
    wire [`DATA_W-1:0] resultdata_a, resultdata_b;
    reg [`REG_W-1:0] rdE_a, rdW_a;
    reg [`REG_W-1:0] rdE_b, rdW_b;
    reg [2:0] funct3E_a, funct3E_b;
    reg extE_a, sw_opE_a, lw_opE_a, lw_opM_a, lui_opE_a, ecall_opE_a, rweE_a, rweM_a, addcomE_a;
    reg extE_b, sw_opE_b, lw_opE_b, lw_opM_b, lui_opE_b, ecall_opE_b, rweE_b, rweM_b, addcomE_b;
    reg [`REG_W-1:0] rdM_a, rdM_b;
    reg rweW_a, alu_opE_a;
    reg rweW_b, alu_opE_b;
    reg [`REG_W-1:0] rs1E_a, rs2E_a;
    reg [`REG_W-1:0] rs1E_b, rs2E_b;
    wire lwstall_a, branchstall_a;
    wire lwstall_b, branchstall_b, parallelstall_b;
    reg [`DATA_W-1:0] resultM_a, resultM_b;

    assign sreg1_a = $signed(reg1f_a);
    assign sreg1_b = $signed(reg1f_b);
    assign sreg2_a = $signed(reg2f_a);
    assign sreg2_b = $signed(reg2f_b);
    assign {funct7_a, rs2_a, rs1_a, funct3_a, rd_a, opcode_a} = instrD_a;
    assign {funct7_b, rs2_b, rs1_b, funct3_b, rd_b, opcode_b} = instrD_b;
    assign sext_a = {20{instrD_a[31]}};
    assign sext_b = {20{instrD_b[31]}};
    assign imm_i_a = {funct7_a, rs2_a};
    assign imm_i_b = {funct7_b, rs2_b};
    assign imm_s_a = {funct7_a, rd_a};
    assign imm_s_b = {funct7_b, rd_b};
    assign imm_b_a = {funct7_a[6], rd_a[0], funct7_a[5:0], rd_a[4:1], 1'b0};
    assign imm_b_b = {funct7_b[6], rd_b[0], funct7_b[5:0], rd_b[4:1], 1'b0};
    assign imm_j_a = {instrD_a[31], instrD_a[19:12], instrD_a[20], instrD_a[30:21], 1'b0};
    assign imm_j_b = {instrD_b[31], instrD_b[19:12], instrD_b[20], instrD_b[30:21], 1'b0};
    assign imm_u_a = instrD_a[31:12];
    assign imm_u_b = instrD_b[31:12];

    // Decoder
    assign sw_op_a = (opcode_a == `OP_STORE) & (funct3_a == 3'b010);
    assign sw_op_b = (opcode_b == `OP_STORE) & (funct3_b == 3'b010);
    assign lw_op_a = (opcode_a == `OP_LOAD) & (funct3_a == 3'b010);
    assign lw_op_b = (opcode_b == `OP_LOAD) & (funct3_b == 3'b010);
    assign alu_op_a = (opcode_a == `OP_REG);
    assign alu_op_b = (opcode_b == `OP_REG);
    assign imm_op_a = (opcode_a == `OP_IMM);
    assign imm_op_b = (opcode_b == `OP_IMM);
    assign bra_op_a = (opcode_a == `OP_BRA);
    assign bra_op_b = (opcode_b == `OP_BRA);
    assign lui_op_a = (opcode_a == `OP_LUI);
    assign lui_op_b = (opcode_b == `OP_LUI);
    assign beq_op_a = bra_op_a & (funct3_a == 3'b000);
    assign beq_op_b = bra_op_b & (funct3_b == 3'b000);
    assign bne_op_a = bra_op_a & (funct3_a == 3'b001);
    assign bne_op_b = bra_op_b & (funct3_b == 3'b001);
    assign blt_op_a = bra_op_a & (funct3_a == 3'b100);
    assign blt_op_b = bra_op_b & (funct3_b == 3'b100);
    assign bge_op_a = bra_op_a & (funct3_a == 3'b101);
    assign bge_op_b = bra_op_b & (funct3_b == 3'b101);
    assign bltu_op_a = bra_op_a & (funct3_a == 3'b110);
    assign bltu_op_b = bra_op_b & (funct3_b == 3'b110);
    assign bgeu_op_a = bra_op_a & (funct3_a == 3'b111);
    assign bgeu_op_b = bra_op_b & (funct3_b == 3'b111);
    assign ecall_op_a = (opcode_a == `OP_SPE) & (funct3_a == 3'b000);
    assign ecall_op_b = (opcode_b == `OP_SPE) & (funct3_b == 3'b000);
    assign ext_a = alu_op_a  & funct7_a[5];
    assign ext_b = alu_op_b  & funct7_b[5];

    assign imm_a = imm_op_a | lw_op_a ? {sext_a, imm_i_a}:
                   sw_op_a ? {sext_a, imm_s_a}:
                   lui_op_a ? {imm_u_a, 12'b0}:
                   {sext_a[10:0], imm_j_a};
    assign imm_b = imm_op_b | lw_op_b ? {sext_b, imm_i_b}:
                   sw_op_b ? {sext_b, imm_s_b}:
                   lui_op_b ? {imm_u_b, 12'b0}:
                   {sext_b[10:0], imm_j_b};

    assign rwe_a = lw_op_a | alu_op_a | imm_op_a | lui_op_a;
    assign rwe_b = lw_op_b | alu_op_b | imm_op_b | lui_op_b;
    assign addcom_a = (lw_op_a | sw_op_a);
    assign addcom_b = (lw_op_b | sw_op_b);

    rfile rfile_1(
        .clk(clk),
        .a1_a(rs1_a),
        .a2_a(rs2_a),
        .a3_a(rdW_a),
        .a1_b(rs1_b),
        .a2_b(rs2_b),
        .a3_b(rdW_b),
        .wd3_a(resultdata_a),
        .wd3_b(resultdata_b),
        .we3_a(rweW_a),
        .we3_b(rweW_b),
        .rd1_a(reg1_a),
        .rd2_a(reg2_a),
        .rd1_b(reg1_b),
        .rd2_b(reg2_b)
    );

    // Stall instruction-a
    assign lwstall_a = (
        ((rs1_a == rdE_a) | ((rs2_a == rdE_a) & !imm_op_a)) & lw_opE_a |
        ((rs1_a == rdE_b) | ((rs2_a == rdE_b) & !imm_op_a)) & lw_opE_b
    );

    assign branchstall_a = (
        bra_op_a & rweE_a & (rs1_a == rdE_a | rs2_a == rdE_a) |
        bra_op_a & rweE_b & (rs1_a == rdE_b | rs2_a == rdE_b) |
        bra_op_a & lw_opM_a & (rs1_a == rdM_a | rs2_a == rdM_a) |
        bra_op_a & lw_opM_b & (rs1_a == rdM_b | rs2_a == rdM_b)
    );

    assign stall_a = lwstall_a | branchstall_a;

    // Stall instruction-b
    assign lwstall_b = (
        ((rs1_b == rdE_a) | ((rs2_b == rdE_a) & !imm_op_b)) & lw_opE_a |
        ((rs1_b == rdE_b) | ((rs2_b == rdE_b) & !imm_op_b)) & lw_opE_b
    );

    assign branchstall_b = (
        rdE_a != 0 & bra_op_b & rweE_a & (rs1_b == rdE_a | rs2_b == rdE_a) |
        rdE_b != 0 & bra_op_b & rweE_b & (rs1_b == rdE_b | rs2_b == rdE_b) |
        rdM_a != 0 & bra_op_b & lw_opM_a & (rs1_b == rdM_a | rs2_b == rdM_a) |
        rdM_b != 0 & bra_op_b & lw_opM_b & (rs1_b == rdM_b | rs2_b == rdM_b)
    );

    assign parallelstall_b = (
        (rs1_b == rd_a | rs2_b == rd_a) & rd_a != 0
    );

    assign stall_b = lwstall_b | branchstall_b | parallelstall_b;

    // Forwarding
    assign reg1f_a = (rs1_a != 0) & (rs1_a == rdM_b) & rweM_b ? resultM_b:
                     (rs1_a != 0) & (rs1_a == rdM_a) & rweM_a ? resultM_a:
                     reg1_a;
    assign reg1f_b = (rs1_b != 0) & (rs1_b == rdM_b) & rweM_b ? resultM_b:
                     (rs1_b != 0) & (rs1_b == rdM_a) & rweM_a ? resultM_a:
                     reg1_b;
    assign reg2f_a = (rs2_a != 0) & (rs2_a == rdM_b) & rweM_b ? resultM_b:
                     (rs2_a != 0) & (rs2_a == rdM_a) & rweM_a ? resultM_a:
                     reg2_a;
    assign reg2f_b = (rs2_b != 0) & (rs2_b == rdM_b) & rweM_b ? resultM_b:
                     (rs2_b != 0) & (rs2_b == rdM_a) & rweM_a ? resultM_a:
                     reg2_b;

    // Branch
    assign btakenD_a = (  // detects in the instruction _a
        beq_op_a & (reg1f_a == reg2f_a) | bne_op_a & (reg1f_a != reg2f_a) |
        blt_op_a & (sreg1_a < sreg2_a) | bge_op_a & (sreg1_a >= sreg2_a) |
        bltu_op_a & (reg1f_a < reg2f_a) | bgeu_op_a & (reg1f_a >= reg2f_a)
    );
    assign btakenD_b = (  // detects in the instruction _b
        beq_op_b & (reg1f_b == reg2f_b) | bne_op_b & (reg1f_b != reg2f_b) |
        blt_op_b & (sreg1_b < sreg2_b) | bge_op_b & (sreg1_b >= sreg2_b) |
        bltu_op_b & (reg1f_b < reg2f_b) | bgeu_op_b & (reg1f_b >= reg2f_b)
    );
    assign pcbranchD_a = pcplus8D - 4 + {sext_a[18:0], imm_b_a};
    assign pcbranchD_b = pcplus8D + {sext_b[18:0], imm_b_b};

    // for each cycle in the Instruction Decoder Stage
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin  // init
            // instruction: a
            reg1E_a <= 0; reg2E_a <= 0; rdE_a <= 0;
            rs1E_a <= 0; rs2E_a <= 0; funct3E_a <= 0;
            sw_opE_a <= 0; lw_opE_a <= 0; ecall_opE_a <= 0;
            lui_opE_a <= 0; alu_opE_a <= 0; rweE_a <= 0;
            addcomE_a <= 0; extE_a <= 0; immE_a <= 0;
            // instruction: b
            reg1E_b <= 0; reg2E_b <= 0; rdE_b <= 0;
            rs1E_b <= 0; rs2E_b <= 0; funct3E_b <= 0;
            sw_opE_b <= 0; lw_opE_b <= 0; ecall_opE_b <= 0;
            lui_opE_b <= 0; alu_opE_b <= 0; rweE_b <= 0;
            addcomE_b <= 0; extE_b <= 0; immE_b <= 0;
        end
        else if (stall_a) begin
            // eliminate the effects of decoded instruction
            // (these instruction will be decoded again until the next clock)
            sw_opE_a <= 0; rweE_a <= 0; lw_opE_a <= 0;
            sw_opE_b <= 0; rweE_b <= 0; lw_opE_b <= 0;
        end
        else begin
            // in these case, instruction-a must go ahead
            reg1E_a <= reg1f_a;
            reg2E_a <= reg2f_a;
            rdE_a <= rd_a;
            rs1E_a <= rs1_a;
            rs2E_a <= rs2_a;
            funct3E_a <= funct3_a;
            sw_opE_a <= sw_op_a;
            lw_opE_a <= lw_op_a;
            ecall_opE_a <= ecall_op_a;
            lui_opE_a <= lui_op_a;
            alu_opE_a <= alu_op_a;
            rweE_a <= rwe_a;
            addcomE_a <= addcom_a;
            extE_a <= ext_a;
            immE_a <= imm_a;
            if (btakenD_a) begin
                // eliminate the effects of decoded instruction
                // (timing of this instruction is invalid)
                sw_opE_b <= 0; rweE_b <= 0; lw_opE_b <= 0;
            end
            else if (stall_b) begin
                // execute only the instruction-a in the next step
                // eliminate the effects of decoded instruction
                // (this instruction will be decoded again until the next clock)
                sw_opE_b <= 0; rweE_b <= 0; lw_opE_b <= 0;
            end
            else begin
                // 2 instructions are ready to exe.
                // pass the decoded information of instruction-b too
                reg1E_b <= reg1f_b;
                reg2E_b <= reg2f_b;
                rdE_b <= rd_b;
                rs1E_b <= rs1_b;
                rs2E_b <= rs2_b;
                funct3E_b <= funct3_b;
                sw_opE_b <= sw_op_b;
                lw_opE_b <= lw_op_b;
                ecall_opE_b <= ecall_op_b;
                lui_opE_b <= lui_op_b;
                alu_opE_b <= alu_op_b;
                rweE_b <= rwe_b;
                addcomE_b <= addcom_b;
                extE_b <= ext_b;
                immE_b <= imm_b;
            end
        end
    end


    /*  Execution Stage */
    wire [`DATA_W-1:0] srca_a, srcb_a, alub_a, result_a, aluresult_a;
    wire [`DATA_W-1:0] srca_b, srcb_b, alub_b, result_b, aluresult_b;
    reg [`DATA_W-1:0] alubM_a, alubM_b;
    reg sw_opM_a, ecall_opM_a, sw_opM_b, ecall_opM_b;
    wire [`DATA_W-1:0] fdata_a, fdata_b;
    reg [`DATA_W-1:0] fdataW_a, fdataW_b;
    assign result_a = lui_opE_a ? immE_a: aluresult_a;
    assign result_b = lui_opE_b ? immE_b: aluresult_b;

    // Forwarding
    assign srca_a = rweM_b & rs1E_a != 0 & rdM_b == rs1E_a ? resultM_b:
                    rweW_b & rs1E_a != 0 & rdW_b == rs1E_a ? fdataW_b:
                    rweM_a & rs1E_a != 0 & rdM_a == rs1E_a ? resultM_a:
                    rweW_a & rs1E_a != 0 & rdW_a == rs1E_a ? fdataW_a:
                    reg1E_a;
    assign srca_b = rweM_b & rs1E_b != 0 & rdM_b == rs1E_b ? resultM_b:
                    rweW_b & rs1E_b != 0 & rdW_b == rs1E_b ? fdataW_b:
                    rweM_a & rs1E_b != 0 & rdM_a == rs1E_b ? resultM_a:
                    rweW_a & rs1E_b != 0 & rdW_a == rs1E_b ? fdataW_a:
                    reg1E_b;
    assign srcb_a = alu_opE_a ? alub_a : immE_a;
    assign srcb_b = alu_opE_b ? alub_b : immE_b;
    assign alub_a = rweM_b & rs2E_a != 0 & rdM_b == rs2E_a ? resultM_b:
                    rweW_b & rs2E_a != 0 & rdW_b == rs2E_a ? fdataW_b:
                    rweM_a & rs2E_a != 0 & rdM_a == rs2E_a ? resultM_a:
                    rweW_a & rs2E_a != 0 & rdW_a == rs2E_a ? fdataW_a:
                    reg2E_a;
    assign alub_b = rweM_b & rs2E_b != 0 & rdM_b == rs2E_b ? resultM_b:
                    rweW_b & rs2E_b != 0 & rdW_b == rs2E_b ? fdataW_b:
                    rweM_a & rs2E_b != 0 & rdM_a == rs2E_b ? resultM_a:
                    rweW_a & rs2E_b != 0 & rdW_a == rs2E_b ? fdataW_a:
                    reg2E_b;

    alu alu_a(
        .a(srca_a),
        .b(srcb_a),
        .s(funct3E_a),
        .ext(extE_a),
        .addcom(addcomE_a),
        .y(aluresult_a)
    );

    alu alu_b(
        .a(srca_b),
        .b(srcb_b),
        .s(funct3E_b),
        .ext(extE_b),
        .addcom(addcomE_b),
        .y(aluresult_b)
    );

    // for each cycle in the Execution Stage
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin  // init
            // instruction: a
            resultM_a <= 0; alubM_a <= 0;
            rdM_a <=0; rweM_a <=0; sw_opM_a <= 0;
            lw_opM_a <=0; ecall_opM_a <= 0;
            // instruction: b
            resultM_b <= 0; alubM_b <= 0;
            rdM_b <=0; rweM_b <=0; sw_opM_b <= 0;
            lw_opM_b <=0; ecall_opM_b <= 0;
        end
        else begin
            // instruction: a
            resultM_a <= result_a; alubM_a <= alub_a;
            rdM_a <= rdE_a; rweM_a <= rweE_a; sw_opM_a <= sw_opE_a;
            lw_opM_a <= lw_opE_a; ecall_opM_a <= ecall_opE_a;
            // instruction: b
            resultM_b <= result_b; alubM_b <= alub_b;
            rdM_b <= rdE_b; rweM_b <= rweE_b; sw_opM_b <= sw_opE_b;
            lw_opM_b <= lw_opE_b; ecall_opM_b <= ecall_opE_b;
        end
    end


    /*  Memory Access Stage */
    reg lw_opW_a, ecall_opW_a, lw_opW_b, ecall_opW_b;
    reg [`DATA_W-1:0] resultW_a, resultW_b;
    reg [`DATA_W-1:0] readdataW_a, readdataW_b;
    assign we_a = sw_opM_a;
    assign we_b = sw_opM_b;
    assign adrdata_a = resultM_a;
    assign adrdata_b = resultM_b;
    assign writedata_a = alubM_a;
    assign writedata_b = alubM_b;
    assign fdata_a = lw_opM_a ? readdata_a : resultM_a;
    assign fdata_b = lw_opM_b ? readdata_b : resultM_b;

    // for each cycle in the Memory Access Stage
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin  // init
            // instruction: a
            lw_opW_a <= 0; ecall_opW_a <= 0;
            rdW_a <= 0; rweW_a <= 0;
            fdataW_a <= 0;
            resultW_a <= 0;
            readdataW_a <= 0;
            // instruction: b
            lw_opW_b <= 0; ecall_opW_b <= 0;
            rdW_b <= 0; rweW_b <= 0;
            fdataW_b <= 0;
            resultW_b <= 0;
            readdataW_b <= 0;
        end
        else begin
            // instruction: a
            lw_opW_a <= lw_opM_a; ecall_opW_a <= ecall_opM_a;
            rdW_a <= rdM_a; rweW_a <= rweM_a;
            readdataW_a <= readdata_a;
            fdataW_a <= fdata_a;
            resultW_a <= resultM_a;
            // instruction: b
            lw_opW_b <= lw_opM_b; ecall_opW_b <= ecall_opM_b;
            rdW_b <= rdM_b; rweW_b <= rweM_b;
            readdataW_b <= readdata_b;
            fdataW_b <= fdata_b;
            resultW_b <= resultM_b;
        end
    end


    /*  Write back Stage */
    assign ecall = (ecall_opW_a | ecall_opW_b);	
    assign resultdata_a = lw_opW_a ? readdataW_a : resultW_a;
    assign resultdata_b = lw_opW_b ? readdataW_b : resultW_b;

endmodule
