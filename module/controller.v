`include "module/mainDecoder.v"
`include "module/ALUDecoder.v"
`include "module/setPCSrc.v"
`include "module/setMemSize.v"
`include "module/load2Cycle.v"

module controller(
  input         i_clk,
  input [31:0]  i_inst,

  input         i_zero, i_neg, i_negU,

  output        o_memReq, o_memWrite,
  output [1:0]  o_memSize,

  output        o_regWrite,
  output [1:0]  o_PCSrc,
  output        o_ALUSrc,
  output [2:0]  o_immSrc,
  output        o_immPlusSrc,
  output        o_readDataSrc,
  output [1:0]  o_resultSrc,
  output [3:0]  o_ALUCtrl,
  output        o_PCEnable
);

  wire [6:0] w_opcode = i_inst[6:0];
  wire [2:0] w_funct3 = i_inst[14:12];
  wire [6:0] w_funct7 = i_inst[31:25];

  wire w_branch;
  wire w_jal, w_jalr;
  wire [1:0] w_ALUOp;
  wire w_regWrite;
  wire w_regWriteLoad;

  // todo Will move?
  assign o_regWrite = w_regWrite && w_regWriteLoad;

  mainDecoder main_decoder(
    .i_opcode(w_opcode), .i_funct3(w_funct3),

    .o_memReq(o_memReq), .o_memWrite(o_memWrite),
    .o_regWrite(w_regWrite),
    .o_ALUSrc(o_ALUSrc), .o_immSrc(o_immSrc),
    .o_immPlusSrc(o_immPlusSrc), .o_readDataSrc(o_readDataSrc),
    .o_resultSrc(o_resultSrc),

    .o_branch(w_branch),
    .o_jal(w_jal), .o_jalr(w_jalr),
    .o_ALUOp(w_ALUOp)
  );
  ALUDecoder alu_decoder(
    .i_ALUOp(w_ALUOp), .i_funct3(w_funct3),
    .i_opecodeb5(w_opcode[5]), .i_funct7b5(w_funct7[5]),

    .o_ALUCtrl(o_ALUCtrl)
  );
  setPCSrc set_pc_src(
    .i_branch(w_branch),
    .i_zero(i_zero), .i_neg(i_neg), .i_negU(i_negU),
    .i_funct3(w_funct3),
    .i_jal(w_jal), .i_jalr(w_jalr),

    .o_PCSrc(o_PCSrc)
  );
  setMemSize set_mem_size(
    .i_funct3(w_funct3),
    .o_memSize(o_memSize)
  );
  load2Cycle load_2cycle(
    .i_clk(i_clk), .i_opcode(w_opcode),
    .o_PCEnable(o_PCEnable),
    .o_regWriteLoad(w_regWriteLoad)
  );

endmodule