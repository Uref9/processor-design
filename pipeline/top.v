`include "pipeline/controller.v"
`include "pipeline/datapath.v"
`include "pipeline/hazard.v"

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
  wire [31:0] Dw_inst;
  wire        Ew_zero, Ew_neg, Ew_negU;
    // to hazard
  wire [4:0]  Dw_rs1, Dw_rs2;
  wire [4:0]  Ew_rs1, Ew_rs2;
  wire [4:0]  Ew_rd;
  wire [4:0]  Mw_rd;
  wire [4:0]  Ww_rd;

  // from controller
    // to datapath
  wire [2:0]  Dw_immSrc;
  wire        Dw_jal;   // and to hazard
  wire        Dw_mret;  // and to hazard
  wire        Dw_ecall;
  wire [3:0]  Ew_ALUCtrl;
  wire        Ew_ALUSrc;
  wire        Ew_immPlusSrc;
  wire [1:0]  Ew_prePCSrc; // and to hazard
  wire        Ew_csrWrite, Ew_csrSrc;
  wire [1:0]  Ew_csrLUCtrl;
  wire        Mw_isLoadSigned;
  wire [1:0]  Mw_resultMSrc;
  wire        Ww_resultWSrc;
  wire        Ww_regWrite;  // and to hazard
    // to hazard
  wire        Ew_resultWSrc;
  wire        Mw_regWrite;

  // from hazard
  wire [1:0]   Ew_forwardIn1Src, Ew_forwardIn2Src;
  wire         Fw_stall;
  wire         Dw_stall, Dw_flush;
  wire         Ew_flush;

  // wire        w_PCEnable;

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
    .Di_immSrc(Dw_immSrc), .Di_jal(Dw_jal), 
    .Di_mret(Dw_mret), .Di_ecall(Dw_ecall), 
    .Ei_ALUCtrl(Ew_ALUCtrl), .Ei_ALUSrc(Ew_ALUSrc), 
    .Ei_immPlusSrc(Ew_immPlusSrc), .Ei_prePCSrc(Ew_prePCSrc), 
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

    // to test imem
    .Fo_PC(IAD), 
    // to test dmem
    .Mo_ALUOut(DAD), .Mo_writeData(Mw_writeData),
    // to controller
    .Do_inst(Dw_inst),
    .Eo_zero(Ew_zero), .Eo_neg(Ew_neg), .Eo_negU(Ew_negU),
    // to hazard
    .Do_rs1(Dw_rs1), .Do_rs2(Dw_rs2),
    .Eo_rs1(Ew_rs1), .Eo_rs2(Ew_rs2),
    .Eo_rd(Ew_rd), .Mo_rd(Mw_rd), .Wo_rd(Ww_rd)

    // .i_PCEnable(w_PCEnable),
  );

  controller controller(
    // from test
    .clk(clk), .reset_x(rst),
    // from datapath
    .Di_inst(Dw_inst),
    .Ei_zero(Ew_zero), .Ei_neg(Ew_neg), .Ei_negU(Ew_negU),
    // from hazard
    .Ei_flush(Ew_flush),

    // to test dmem
    .Mo_memReq(MREQ), .Mo_memWrite(WRITE),
    .Mo_memSize(SIZE),
    // to datapath
    .Do_immSrc(Dw_immSrc), .Do_jal(Dw_jal), 
    .Do_mret(Dw_mret), .Do_ecall(Dw_ecall),
    .Eo_ALUCtrl(Ew_ALUCtrl), .Eo_ALUSrc(Ew_ALUSrc), 
    .Eo_immPlusSrc(Ew_immPlusSrc), 
    .Eo_prePCSrc(Ew_prePCSrc),
    .Eo_csrWrite(Ew_csrWrite), .Eo_csrSrc(Ew_csrSrc),
    .Eo_csrLUCtrl(Ew_csrLUCtrl),
    .Mo_isLoadSigned(Mw_isLoadSigned), 
    .Mo_resultMSrc(Mw_resultMSrc),
    .Wo_resultWSrc(Ww_resultWSrc),
    .Wo_regWrite(Ww_regWrite),
    // to hazard
    .Eo_resultWSrc(Ew_resultWSrc),
    .Mo_regWrite(Mw_regWrite)
  );

  hazard hazard(
    // from test
    // .clk(clk), .reset_x(rst),
    // from datapath
    .Di_rs1(Dw_rs1), .Di_rs2(Dw_rs2),
    .Ei_rs1(Ew_rs1), .Ei_rs2(Ew_rs2),
    .Ei_rd(Ew_rd), .Mi_rd(Mw_rd), .Wi_rd(Ww_rd),
    // from controller
    .Di_jal(Dw_jal), .Di_mret(Dw_mret),
    .Ei_prePCSrc(Ew_prePCSrc),
    .Ei_resultWSrc(Ew_resultWSrc),
    .Mi_regWrite(Mw_regWrite), .Wi_regWrite(Ww_regWrite),

    // to datapath
    .Eo_forwardIn1Src(Ew_forwardIn1Src),
    .Eo_forwardIn2Src(Ew_forwardIn2Src),
    // to both data and contl
    .Fo_stall(Fw_stall),
    .Do_stall(Dw_stall), .Do_flush(Dw_flush),
    .Eo_flush(Ew_flush)
  );

endmodule