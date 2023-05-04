`include "module/PCReg.v"
`include "module/adder.v"
`include "module/mux3.v"
`include "module/rf32x32.v"
`include "module/immExtend.v"
`include "module/mux2.v"
`include "module/ALU.v"
`include "module/readDataExtend.v"
`include "module/mux4.v"
`include "module/"

module datapath(
  input i_clk, i_reset_x,
  input [31:0] i_inst, i_readData,

  input [1:0] i_memSize,
  input i_regWrite,
  input [1:0] i_PCSrc,
  input i_ALUSrc,
  input [2:0] i_immSrc,
  input i_immPlusSrc,
  input i_readDataSrc,
  input [1:0] i_resultSrc,
  input [3:0] i_ALUCtrl,

  output [31:0] o_PC, o_ALUOut, o_writeData,

  output o_zero, o_neg, o_negU
);

  wire [31:0] w_PCNext, w_PCPlus4, w_PCPlusImm;
  wire [31:0] w_immExt;
  wire [31:0] w_ALUOutJalr;
  wire [4:0] w_rd, w_rs1, w_rs2;
  wire [31:0] w_result;
  wire [31:0] w_ALUIn1, w_ALUIn2;
  wire [31:0] w_readDataExt;
  wire [31:0] w_immPlus;

  assign w_rd = i_inst[11:7];
  assign w_rs1 = i_inst[19:15];
  assign w_rs2 = i_inst[24:20];
  assign w_ALUOutJalr = o_ALUOut & ~{32'd1};
  // assign w_opcode = i_inst[6:0];
  // assign w_funct3 = i_inst[14:12];
  // assign w_zimm = i_inst[19:15];
  // assign w_succ = i_inst[23:20];
  // assign w_pred = i_inst[27:24];
  // assign w_funct7 = i_inst[31:25];
  // assign w_csr = i_inst[31:20];

  // PC
  PCReg pc_reg(
    .i_clk(i_clk), .i_reset_x(i_reset_x), .i_d(w_PCNext),
    .o_q(o_PC)
  );
  adder add4(
    .i_1(o_PC), .i_2({32'd4}),
    .o_1(w_PCPlus4)
  );
  adder add_imm(
    .i_1(o_PC), .i_2(w_immExt),
    .o_1(w_PCPlusImm)
  );
  mux3 pc_next_mux(
    .i_1(w_PCPlus4), .i_2(w_PCPlusImm), .i_3(w_ALUOutJalr),
    .i_sel(i_PCSrc),
    .o_1(w_PCNext)
  );

  // register
  rf32x32 register(
    .clk(i_clk), .reset(i_reset_x),
    .wr_n(~i_regWrite),
    .rd1_addr(w_rs1), .rd2_addr(w_rs2), .wr_addr(w_rd),
    .data_in(w_result),

    .data1_out(w_ALUIn1), .data2_out(o_writeData)
  );
  immExtend imm_extend(
    .i_immSrc(i_immSrc), .i_inst(i_inst), 
    .o_immExt(w_immExt)
  );

  // ALU
  mux2 alu_in2_mux(
    .i_1(o_writeData), .i_2(w_immExt), .i_sel(i_ALUSrc), 
    .o_1(w_ALUIn2)
  );
  ALU alu(
    .i_ctrl(i_ALUCtrl),
    .i_1(w_ALUIn1), .i_2(w_ALUIn2),
    .o_1(o_ALUOut),
    .o_zero(o_zero), .o_neg(o_neg), .o_negU(o_negU)
  );
  readDataExtend read_data_extend(
    .i_readDataSrc(i_readDataSrc), .i_memSize(i_memSize),
    .i_readData(i_readData), 
    .o_readDataExt(w_readDataExt)
  );
  mux2 imm_plus_mux(
    .i_1(w_immExt), .i_2(w_PCPlusImm),
    .i_sel(i_immPlusSrc),
    .o_1(w_immPlus)
  );
  mux4 result_mux(
    .i_1(o_ALUOut), .i_2(w_readDataExt),
    .i_3(w_immPlus), .i_4(w_PCPlus4),
    .i_sel(i_resultSrc),
    .o_1(w_result)
  );

endmodule