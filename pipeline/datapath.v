`include "module/mux2.v"
`include "module/mux3.v"
`include "module/mux4.v"
`include "module/dffREC.v"
`include "module/adder.v"
`include "module/ALU.v"
`include "module/immExtend.v"
`include "module/readDataExtend.v"
`include "module/rf32x32.v"
`include "module/CSRs.v"
`include "module/csrLU.v"
`include "module/privilegeMode.v"

`define HIGH  1'b1
`define LOW   1'b0

// CSRs addres
`define MTVEC = 12'h305

module datapath(
  // from test
  input         clk, reset_x,
  input [31:0]  Fi_inst,     // from imem
  input [31:0]  Mi_readData, // from dmem
  // from controller
  input [2:0]   Di_immSrc,
  input         Di_jal,
  input [3:0]   Ei_ALUCtrl,
  input         Ei_ALUSrc,
  input         Ei_immPlusSrc,
  input [1:0]   Ei_PCSrc,
  input         Ei_mret,
  input         Ei_csrWrite, Ei_csrSrc,
  input [1:0]   Ei_csrLUCtrl,
  input [1:0]   Mi_memSize,
  input         Mi_isLoadSigned,
  input [1:0]   Mi_resultMSrc,
  input         Wi_resultWSrc,
  input         Wi_regWrite,
  // from hazard
  input [1:0]   Ei_forwardIn1Src, Ei_forwardIn2Src,
  input         Fi_stall,
  input         Di_stall, Di_flush,
  input         Ei_flush,
  // from exceptionHandling
  input Ei_privRegEnable,
  input [3:0]  Ei_cause,

  // to test imem
  output [31:0] Fo_PC,
  // to test dmem
  output [31:0] Mo_ALUOut, Mo_writeData,
  // to controller
  output [31:0] Do_inst,
  output [1:0]  Do_nowPrivMode,
  output        Eo_exception, // and to exceptionHandling
  output        Eo_zero, Eo_neg, Eo_negU,
  // to hazard
  output [4:0]  Do_rs1, Do_rs2,
  output [4:0]  Eo_rs1, Eo_rs2,
  output [4:0]  Eo_rd,
  output [4:0]  Mo_rd,
  output [4:0]  Wo_rd,
  // to exceptionHandling
  output [1:0]  Eo_nowPrivMode,
  output [31:0] Eo_PC, Eo_inst,
  output [31:0] Eo_ALUOut
);

/* wire */
  // IF stage wire
  wire [31:0] Fw_PCPlus4, Fw_ALUOutJalr;
  wire [31:0] Fw_prePCNext, Fw_PCNext;

  // ID stage wire
  // decode
  wire [4:0]  Dw_rd   = Do_inst[11:7];   // to WB
  wire [4:0]  Dw_zimm = Do_inst[19:15];
  assign      Do_rs1  = Do_inst[19:15];  // to EX
  assign      Do_rs2  = Do_inst[24:20];  // to EX
  wire [11:0] Dw_csr  = Do_inst[31:20];  // to EX

    // to EX
  wire [31:0] Dw_RD1, Dw_RD2;
  wire [31:0] Dw_immExt, Dw_zimmExt;
  wire [31:0] Dw_PC, Dw_PCPlusImm;
  wire [31:0] Dw_mstatusOut, Dw_mtvecOut;
  wire [31:0] Dw_mepcOut;
  wire [1:0]  Dw_nextPrivMode;
    // to MEM
  wire [31:0] Dw_CSRsData;
    // to WB
  wire [31:0] Dw_PCPlus4;

  // EX stage wire
  wire [31:0] Ew_RD1, Ew_RD2;
  wire [31:0] Ew_RD1Fwd, Ew_ALUIn2;
  wire [31:0] Ew_immExt, Ew_zimmExt;
  wire [31:0] Ew_PCPlusImm;
  wire [31:0] Ew_mstatusOut, Ew_mtvecOut;
  wire [31:0] Ew_mepcOut;
  wire [31:0] Ew_mtvecmretOut;
  wire [11:0] Ew_csr;
  wire [31:0] Ew_csrLUIn2;
  wire [31:0] Ew_csrLUOut;
    // to MEM
  wire [31:0] Ew_writeData;
  wire [31:0] Ew_immPlus;
  wire [31:0] Ew_CSRsData;
    // to WB
  wire [31:0] Ew_PCPlus4;
  wire [4:0] Eo_rd;

  // MEM stage wire
  wire [31:0] Mw_CSRsData;

    // to WB
  wire [31:0] Mi_readDataExt;
  wire [31:0] Mw_immPlus;
  wire [31:0] Mw_PCPlus4, Mw_resultM;

  // WB stage wire 
  wire [31:0] Ww_resultM;
  wire [31:0] Ww_readDataExt;
  wire [31:0] Ww_resultW;
/* end wire */

/*** IF stage logic ***/
  dffREC #(32, 32'h1_0000)
  pc_reg(
    .i_clock(clk), .i_reset_x(reset_x),
    .i_enable(~Fi_stall), .i_clear(`LOW),
    .i_d(Fw_PCNext),
    .o_q(Fo_PC)
  );
  adder add4(
    .i_1(Fo_PC), .i_2(32'd4),
    .o_1(Fw_PCPlus4)
  );
  assign Fw_ALUOutJalr = Eo_ALUOut & ~{32'd1};
  mux2 pre_pc_next_mux(
    .i_1(Fw_PCPlus4), .i_2(Dw_PCPlusImm),
    .i_sel(Di_jal),
    .o_1(Fw_prePCNext)
  );
  mux4 pc_next_mux(
    .i_1(Fw_prePCNext), .i_2(Ew_PCPlusImm), 
    .i_3(Ew_mtvecmretOut), .i_4(Fw_ALUOutJalr),
    .i_sel(Ei_PCSrc),
    .o_1(Fw_PCNext)
  );

  // IF/ID reg
  dffREC #(96, {32'h13, 32'b0, 32'b0}) // inst = nop(addi x0 x0 0)
  IFID_datapath_register(
    .i_clock(clk), .i_reset_x(reset_x),
    .i_enable(~Di_stall), .i_clear(Di_flush),
    .i_d({ Fi_inst, Fo_PC, Fw_PCPlus4 }),
    .o_q({ Do_inst, Dw_PC, Dw_PCPlus4 })
  );

/*** ID stage logic ***/
  rf32x32 register(
    .clk(clk), .reset(reset_x),
    .wr_n(~Wi_regWrite),
    .rd1_addr(Do_rs1), .rd2_addr(Do_rs2), 
    .wr_addr(Wo_rd),
    .data_in(Ww_resultW),

    .data1_out(Dw_RD1), .data2_out(Dw_RD2)
  );
  immExtend imm_extend(
    .i_immSrc(Di_immSrc), .i_inst(Do_inst), 
    .o_immExt(Dw_immExt)
  );
  adder add_imm(
    .i_1(Dw_PC), .i_2(Dw_immExt),
    .o_1(Dw_PCPlusImm)
  );
  // Privilege Mode
  privilegeMode priv_register(
    .clk(clk), .reset_x(reset_x),
    .enable(Ei_privRegEnable),
    .i_nextPrivMode(Dw_nextPrivMode),

    .o_nowPrivMode(Do_nowPrivMode)
  );
  // CSRs
  CSRs csregister(
    .clk(clk), .reset_x(reset_x),
    .csr_addr(Dw_csr), 
    .wr1_addr(Ew_csr), .data1_in(Ew_csrLUOut),
    
    .mstatus_in(Ew_mstatusOut),
    .mepc_in(Eo_PC), .mtval_in(Eo_inst),
    .mcause_in(Ei_cause),
    .nowPrivMode(Eo_nowPrivMode),
      // special
      .exception(Eo_exception), 
      .mret(Ei_mret),
    // from controller
    .wcsr_n(!Ei_csrWrite),

    .data_out(Dw_CSRsData),
    .nextPrivMode(Dw_nextPrivMode),
    .mstatus_out(Dw_mstatusOut),
    .mtvec_out(Dw_mtvecOut), .mepc_out(Dw_mepcOut)
  );
  assign Dw_zimmExt = {17'b0, Dw_zimm};
  
  // ID/EX reg
  dffREC #(413)
  IDEX_datapath_register(
    .i_clock(clk), .i_reset_x(reset_x),
    .i_enable(`HIGH), .i_clear(Ei_flush),
    .i_d({
      Dw_RD1, Dw_RD2,
      Dw_immExt, Dw_zimmExt,
      Dw_PC, Dw_PCPlusImm, 
      Dw_mstatusOut, Dw_mtvecOut, Dw_mepcOut,
      Do_nowPrivMode,
      Do_inst, Dw_csr,
      Do_rs1, Do_rs2,

      Dw_CSRsData, Dw_PCPlus4,
      Dw_rd
    }),
    .o_q({
      Ew_RD1, Ew_RD2,
      Ew_immExt, Ew_zimmExt,
      Eo_PC, Ew_PCPlusImm, 
      Ew_mstatusOut, Ew_mtvecOut, Ew_mepcOut,
      Eo_nowPrivMode,
      Eo_inst, Ew_csr, 
      Eo_rs1, Eo_rs2,

      Ew_CSRsData, Ew_PCPlus4,
      Eo_rd
    })
  );

/*** EX stage logic ***/
  mux4 forward_in1_mux(
    .i_1(Ew_RD1), .i_2(Mw_resultM),
    .i_3(Ww_resultW), 
    .i_sel(Ei_forwardIn1Src), 
    .o_1(Ew_RD1Fwd)
  );
  mux4 forward_in2_mux(
    .i_1(Ew_RD2), .i_2(Mw_resultM),
    .i_3(Ww_resultW), 
    .i_sel(Ei_forwardIn2Src), 
    .o_1(Ew_writeData)
  );
  mux2 alu_in2_mux(
    .i_1(Ew_writeData), .i_2(Ew_immExt), .i_sel(Ei_ALUSrc), 
    .o_1(Ew_ALUIn2)
  );
  ALU alu(
    .i_ctrl(Ei_ALUCtrl),
    .i_1(Ew_RD1Fwd), .i_2(Ew_ALUIn2),
    .o_1(Eo_ALUOut),
    .o_zero(Eo_zero), .o_neg(Eo_neg), .o_negU(Eo_negU)
  );
  mux2 imm_plus_mux(
    .i_1(Ew_immExt), .i_2(Ew_PCPlusImm),
    .i_sel(Ei_immPlusSrc),
    .o_1(Ew_immPlus)
  );
  mux2 csr_lu_in2_mux(
    .i_1(Ew_RD1Fwd), .i_2(Ew_zimmExt),
    .i_sel(Ei_csrSrc),
    .o_1(Ew_csrLUIn2)
  );
  csrLU csr_lu(
    .i_ctrl(Ei_csrLUCtrl),
    .i_1(Ew_CSRsData), .i_2(Ew_csrLUIn2),
    .o_1(Ew_csrLUOut)
  );
  mux2 mtvec_or_mret_mux(
    .i_1(Ew_mtvecOut), .i_2(Ew_mepcOut),
    .i_sel(Ei_mret),
    .o_1(Ew_mtvecmretOut)
  );

  // EX/MEM reg
  dffREC #(165)
  EXMEM_datapath_register(
    .i_clock(clk), .i_reset_x(reset_x),
    .i_enable(`HIGH), .i_clear(`LOW),
    .i_d({
      Eo_ALUOut, Ew_writeData,
      Ew_immPlus, Ew_CSRsData, Ew_PCPlus4,

      Eo_rd
    }),
    .o_q({
      Mo_ALUOut, Mo_writeData,
      Mw_immPlus, Mw_CSRsData, Mw_PCPlus4,

      Mo_rd
    })
  );

/*** MEM stage logic ***/
  readDataExtend read_data_extend(
    .i_isLoadSigned(Mi_isLoadSigned), .i_memSize(Mi_memSize),
    .i_readData(Mi_readData), 
    .o_readDataExt(Mi_readDataExt)
  );
  mux4 result_m_mux(
    .i_1(Mo_ALUOut), .i_2(Mw_immPlus),
    .i_3(Mw_PCPlus4), .i_4(Mw_CSRsData),
    .i_sel(Mi_resultMSrc),
    .o_1(Mw_resultM)
  );

  // MEM/WB reg
  dffREC #(69)
  MEMWB_datapath_register(
    .i_clock(clk), .i_reset_x(reset_x),
    .i_enable(`HIGH), .i_clear(`LOW),
    .i_d({
      Mw_resultM, Mi_readDataExt,
      Mo_rd
    }),
    .o_q({
      Ww_resultM, Ww_readDataExt,
      Wo_rd
    })
  );

/*** WB stage logic ***/
  mux2 result_w_mux(
    .i_1(Ww_resultM), .i_2(Ww_readDataExt),
    .i_sel(Wi_resultWSrc),
    .o_1(Ww_resultW)
  );

/* single */
  // assign w_opcode = i_inst[6:0];
  // assign w_funct3 = i_inst[14:12];
  // assign w_succ = i_inst[23:20];
  // assign w_pred = i_inst[27:24];
  // assign w_funct7 = i_inst[31:25];

endmodule