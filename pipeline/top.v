`include "pipeline/datapath.v"
`include "pipeline/controller.v"
`include "pipeline/hazard.v"
`include "pipeline/exceptionHandling.v"

module top(
  input         clk, rst,
  input         ACKD_n, ACKI_n,
  input [31:0]  IDT,
  input [2:0]   OINT_n,

  output [31:0] IAD, DAD,
  output        MREQ, WRITE,
  output [1:0]  SIZE,
  output        IACK_n,

  inout [31:0]  DDT  // in: readData, out: writeData
);

  // from datapath
    // to controller
  wire [31:0] Dw_inst;
  wire [1:0]  Dw_nowPrivMode;
  wire        Ew_exception; // and to exceptionHandling
  wire        Ew_zero, Ew_neg, Ew_negU;
    // to hazard
  wire [4:0]  Dw_rs1, Dw_rs2;
  wire [4:0]  Ew_rs1, Ew_rs2;
  wire [4:0]  Ew_rd;
  wire [4:0]  Mw_rd;
  wire [4:0]  Ww_rd;
    // to exceptionHandling
  wire [1:0] Ew_nowPrivMode;
  wire [31:0] Ew_PC, Ew_inst;
  wire [31:0] Ew_ALUOut;

  // from controller
    // to datapath
  wire [2:0]  Dw_immSrc;
  wire        Dw_jal;   // and to hazard
  wire [3:0]  Ew_ALUCtrl;
  wire        Ew_ALUSrc;
  wire        Ew_immPlusSrc;
  wire [1:0]  Ew_PCSrc; // and to hazard
  wire        Ew_mret;
  wire        Ew_csrWrite, Ew_csrSrc;
  wire [1:0]  Ew_csrLUCtrl;
  wire        Mw_isLoadSigned;
  wire [1:0]  Mw_resultMSrc;
  wire        Ww_resultWSrc;
  wire        Ww_regWrite;  // and to hazard
    // to hazard
  wire        Ew_resultWSrc;
  wire        Mw_regWrite;
    // to exceptionHandling
  wire        Ew_exceptionFromInst;
  wire [3:0]  Ew_causeFromInst;
  wire        Ew_memWrite, Ew_memReq;

  // from hazard
  wire [1:0]   Ew_forwardIn1Src, Ew_forwardIn2Src;
  wire         Fw_stall;
  wire         Dw_stall, Dw_flush;
  wire         Ew_flush;

  // from exceptionHandling
    // to datapath
  wire Ew_privRegEnable;
  wire [3:0] Ew_cause;

  /*** inout ***/
  wire [31:0] Mw_writeData;
  wire [31:0] Mw_readData;
  assign Mw_readData = DDT;
  assign DDT = WRITE? Mw_writeData : 32'bz;

  datapath datapath(
    // from test
    .clk(clk), .reset_x(rst),
    .Fi_inst(IDT), .Mi_readData(Mw_readData),
    // from controller
    .Di_immSrc(Dw_immSrc),
    .Di_jal(Dw_jal),
    .Ei_ALUCtrl(Ew_ALUCtrl), .Ei_ALUSrc(Ew_ALUSrc), 
    .Ei_immPlusSrc(Ew_immPlusSrc), .Ei_PCSrc(Ew_PCSrc), 
    .Ei_mret(Ew_mret), 
    .Ei_csrWrite(Ew_csrWrite), .Ei_csrSrc(Ew_csrSrc),
    .Ei_csrLUCtrl(Ew_csrLUCtrl),
    .Mi_memSize(SIZE), .Mi_isLoadSigned(Mw_isLoadSigned), 
    .Mi_resultMSrc(Mw_resultMSrc),
    .Wi_resultWSrc(Ww_resultWSrc),
    .Wi_regWrite(Ww_regWrite),
    // from hazard
    .Ei_forwardIn1Src(Ew_forwardIn1Src), 
    .Ei_forwardIn2Src(Ew_forwardIn2Src),
    .Fi_stall(Fw_stall), 
    .Di_stall(Dw_stall), .Di_flush(Dw_flush),
    .Ei_flush(Ew_flush),
    // from exceptionHandling
    .Ei_privRegEnable(Ew_privRegEnable),
    .Ei_cause(Ew_cause),

    // to test imem
    .Fo_PC(IAD), 
    // to test dmem
    .Mo_ALUOut(DAD), .Mo_writeData(Mw_writeData),
    // to controller
    .Do_inst(Dw_inst), .Do_nowPrivMode(Dw_nowPrivMode),
    .Eo_exception(Ew_exception),
    .Eo_zero(Ew_zero), .Eo_neg(Ew_neg), .Eo_negU(Ew_negU),
    // to hazard
    .Do_rs1(Dw_rs1), .Do_rs2(Dw_rs2),
    .Eo_rs1(Ew_rs1), .Eo_rs2(Ew_rs2),
    .Eo_rd(Ew_rd), .Mo_rd(Mw_rd), .Wo_rd(Ww_rd),
    // to exceptionHandling
    .Eo_nowPrivMode(Ew_nowPrivMode),
    .Eo_PC(Ew_PC), .Eo_inst(Ew_inst),
    .Eo_ALUOut(Ew_ALUOut)
  );

  controller controller(
    // from test
    .clk(clk), .reset_x(rst),
    // from datapath
    .Di_inst(Dw_inst), .Di_nowPrivMode(Dw_nowPrivMode),
    .Ei_exception(Ew_exception),
    .Ei_zero(Ew_zero), .Ei_neg(Ew_neg), .Ei_negU(Ew_negU),
    // from hazard
    .Ei_flush(Ew_flush),

    // to test dmem
    .Mo_memReq(MREQ), .Mo_memWrite(WRITE),
    .Mo_memSize(SIZE),
    // to datapath
    .Do_immSrc(Dw_immSrc),
    .Do_jal(Dw_jal), 
    .Eo_ALUCtrl(Ew_ALUCtrl), .Eo_ALUSrc(Ew_ALUSrc), 
    .Eo_immPlusSrc(Ew_immPlusSrc), 
    .Eo_PCSrc(Ew_PCSrc), .Eo_mret(Ew_mret), 
    .Eo_csrWrite(Ew_csrWrite), .Eo_csrSrc(Ew_csrSrc),
    .Eo_csrLUCtrl(Ew_csrLUCtrl),
    .Mo_isLoadSigned(Mw_isLoadSigned), 
    .Mo_resultMSrc(Mw_resultMSrc),
    .Wo_resultWSrc(Ww_resultWSrc),
    .Wo_regWrite(Ww_regWrite),
    // to hazard
    .Eo_resultWSrc(Ew_resultWSrc),
    .Mo_regWrite(Mw_regWrite),
    // to exceptionHandling
    .Eo_exceptionFromInst(Ew_exceptionFromInst),
    .Eo_causeFromInst(Ew_causeFromInst),
    .Eo_memWrite(Ew_memWrite), .Eo_memReq(Ew_memReq)
  );

  hazard hazard(
    // from test
    // .clk(clk), .reset_x(rst),
    // from datapath
    .Di_rs1(Dw_rs1), .Di_rs2(Dw_rs2),
    .Ei_rs1(Ew_rs1), .Ei_rs2(Ew_rs2),
    .Ei_rd(Ew_rd), .Mi_rd(Mw_rd), .Wi_rd(Ww_rd),
    // from controller
    .Di_jal(Dw_jal),
    .Ei_PCSrc(Ew_PCSrc),
    .Ei_resultWSrc(Ew_resultWSrc),
    .Mi_regWrite(Mw_regWrite), .Wi_regWrite(Ww_regWrite),
    // from exceptionHandling
    .Ei_exception(Ew_exception),

    // to datapath
    .Eo_forwardIn1Src(Ew_forwardIn1Src),
    .Eo_forwardIn2Src(Ew_forwardIn2Src),
    // to both data and contl
    .Fo_stall(Fw_stall),
    .Do_stall(Dw_stall), .Do_flush(Dw_flush),
    .Eo_flush(Ew_flush)
  );

  exceptionHandling exception_handling(
    // from datapath
    .Ei_nowPrivMode(Ew_nowPrivMode),
    .Ei_PC(Ew_PC), .Ei_inst(Ew_inst),
    .Ei_ALUOut(Ew_ALUOut),
    // from controller
    .Ei_exceptionFromInst(Ew_exceptionFromInst), 
    .Ei_causeFromInst(Ew_causeFromInst),
    .Ei_mret(Ew_mret),
    .Ei_memWrite(Ew_memWrite), .Ei_memReq(Ew_memReq),

    // to datapath
    .Eo_cause(Ew_cause), .Eo_privRegEnable(Ew_privRegEnable),
    // to controller
    .Eo_exception(Ew_exception)
  );

endmodule