// `include "module/dffREC.v"
`include "module/mainDecoder.v"
`include "module/ALUDecoder.v"
`include "module/exceptionDecoder.v"
`include "module/setPCSrc.v"
`include "module/setMemSize.v"


module controller(
  // from test
  input         clk, reset_x,
  // from datapath
  input [31:0]  Di_inst,
  input [1:0]   Di_nowPrivMode,
  input         Ei_zero, Ei_neg, Ei_negU,
  // from hazard
  input Ei_flush,

  // to test (dmem)
  output        Mo_memWrite, Mo_memReq,
  output [1:0]  Mo_memSize,
  // to datapath
  output [2:0]  Do_immSrc,
  output [3:0]  Do_causeNum,
  output        Do_jal,   // to hazard
  output        Do_mret,  // to hazard, exception
  output        Do_exceptionFromInst, // to exception
  output [3:0]  Eo_ALUCtrl,
  output        Eo_ALUSrc,
  output        Eo_immPlusSrc,
  output [1:0]  Eo_PCSrc,    // and to hazard
  output        Eo_csrWrite, Eo_csrSrc,
  output [1:0]  Eo_csrLUCtrl,
  output        Mo_isLoadSigned,
  output [1:0]  Mo_resultMSrc,
  output        Wo_resultWSrc,
  output        Wo_regWrite,   // and to hazard
  // to hazard
  output        Eo_resultWSrc,
  output        Mo_regWrite
);

// wire
  // ID stage wire
  wire [6:0]  Dw_opcode   = Di_inst[6:0];
  wire [6:0]  Dw_funct7   = Di_inst[31:25];
  wire [11:0] Dw_funct12  = Di_inst[31:20];
  wire [1:0]  Dw_ALUOp;
  wire [1:0]  Dw_EXCOp;
    // to EX
  wire [3:0]  Dw_ALUCtrl;
  wire        Dw_ALUSrc;
  wire [2:0]  Dw_funct3 = Di_inst[14:12];
  wire        Dw_immPlusSrc;
  wire        Dw_branch, Dw_jalr;
  wire        Dw_csrWrite, Dw_csrSrc;
  wire [1:0]  Dw_csrLUCtrl;
    // to MEM
  wire        Dw_memWrite, Dw_memReq;
  wire [1:0]  Dw_memSize;
  wire        Dw_isLoadSigned;
  wire [1:0]  Dw_resultMSrc;
    // to WB
  wire        Dw_resultWSrc;
  wire        Dw_regWrite;

  // EX stage wire
  wire [2:0]  Ew_funct3;
  wire        Ew_branch, Ew_jalr;
  wire        Ew_exceptionFromInst;
    // to MEM
  wire        Ew_memWrite, Ew_memReq;
  wire [1:0]  Ew_memSize;
  wire        Ew_isLoadSigned;
  wire [1:0]  Ew_resultMSrc;
    // to WB
  // wire        Ew_resultWSrc;
  wire        Ew_regWrite;

  // MEM stage wire
    // to WB
  wire        Mw_resultWSrc;
  
  // WB stage wire
// end wire

// ID stage
  mainDecoder main_decoder(
    // .clk(clk), .reset_x(reset_x),
    .i_opcode(Dw_opcode), .i_funct3(Dw_funct3),

    .o_memReq(Dw_memReq), .o_memWrite(Dw_memWrite),
    .o_regWrite(Dw_regWrite),
    .o_ALUSrc(Dw_ALUSrc), .o_immSrc(Do_immSrc),
    .o_immPlusSrc(Dw_immPlusSrc), .o_isLoadSigned(Dw_isLoadSigned),
    .o_resultMSrc(Dw_resultMSrc), .o_resultWSrc(Dw_resultWSrc),
    .o_csrWrite(Dw_csrWrite), .o_csrSrc(Dw_csrSrc),
    .o_csrLUCtrl(Dw_csrLUCtrl),

    .o_branch(Dw_branch),
    .o_jal(Do_jal), .o_jalr(Dw_jalr),
    .o_ALUOp(Dw_ALUOp),
    .o_EXCOp(Dw_EXCOp)
  );
  ALUDecoder alu_decoder(
    .i_ALUOp(Dw_ALUOp), .i_funct3(Dw_funct3),
    .i_opecodeb5(Dw_opcode[5]), .i_funct7b5(Dw_funct7[5]),

    .o_ALUCtrl(Dw_ALUCtrl)
  );
  exceptionDecoder exc_decoder(
    .i_EXCOp(Dw_EXCOp),
    .i_funct3(Dw_funct3), .i_funct12(Dw_funct12),
    .i_nowPrivMode(Di_nowPrivMode),
    
    .o_causeNum(Do_causeNum), .o_exceptionFromInst(Do_exceptionFromInst),
    .o_mret(Do_mret)
  );
  setMemSize set_mem_size(
    .i_funct3(Dw_funct3),
    .o_memSize(Dw_memSize)
  );
  // ID/EX reg
  dffREC #(25)
  IDEX_controll_register(
    .i_clock(clk), .i_reset_x(reset_x),
    .i_enable(1'b1), .i_clear(Ei_flush),
    .i_d({
      Dw_ALUCtrl, Dw_ALUSrc, 
      Dw_immPlusSrc, Do_exceptionFromInst,
      Dw_funct3, Dw_branch, Dw_jalr,
      Dw_csrWrite, Dw_csrSrc, Dw_csrLUCtrl,

      Dw_memWrite, Dw_memReq, Dw_memSize,
      Dw_isLoadSigned,
      Dw_resultMSrc,
      
      Dw_resultWSrc, Dw_regWrite
    }),
    .o_q({
      Eo_ALUCtrl, Eo_ALUSrc, 
      Eo_immPlusSrc, Ew_exceptionFromInst,
      Ew_funct3, Ew_branch, Ew_jalr, 
      Eo_csrWrite, Eo_csrSrc, Eo_csrLUCtrl,

      Ew_memWrite, Ew_memReq, Ew_memSize,
      Ew_isLoadSigned,
      Ew_resultMSrc,

      Eo_resultWSrc, Ew_regWrite
    })
  );
// end ID stage

// EX stage
  setPrePCSrc set_pre_pc_src(
    .i_zero(Ei_zero), .i_neg(Ei_neg), .i_negU(Ei_negU),
    .i_branch(Ew_branch),
    .i_funct3(Ew_funct3), .i_jalr(Ew_jalr), 
    .i_exceptionFromInst(Ew_exceptionFromInst),

    .o_PCSrc(Eo_PCSrc)
  );
  // EX/MEM reg
  dffREC #(9)
  EXMEM_controll_register(
    .i_clock(clk), .i_reset_x(reset_x),
    .i_enable(1'b1), .i_clear(1'b0),
    .i_d({
      Ew_memWrite, Ew_memReq, Ew_memSize,
      Ew_isLoadSigned,
      Ew_resultMSrc,
      
      Eo_resultWSrc, Ew_regWrite
    }),
    .o_q({
      Mo_memWrite, Mo_memReq, Mo_memSize,
      Mo_isLoadSigned,
      Mo_resultMSrc,

      Mw_resultWSrc, Mo_regWrite
    })
  );
// end EX stage

// MEM stage
  // MEM/WB reg
  dffREC #(2)
  MEMWB_controll_register(
    .i_clock(clk), .i_reset_x(reset_x),
    .i_enable(1'b1), .i_clear(1'b0),
    .i_d({
      Mw_resultWSrc, Mo_regWrite
    }),
    .o_q({
      Wo_resultWSrc, Wo_regWrite
    })
  );
// end MEM stage

endmodule