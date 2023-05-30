`include "module/mux2.v"
`include "module/mux3.v"
`include "module/mux4.v"
// `include "module/dffREC.v"
`include "module/adder.v"
`include "module/ALU.v"
`include "module/rf32x32.v"
`include "module/immExtend.v"
`include "module/readDataExtend.v"
`include "module/exceptionHandler.v"

`define HIGH  1'b1
`define LOW   1'b0

module datapath(
  // from test
  input         clk, reset_x,
  input [31:0]  Fi_inst,     // from imem
  input [31:0]  Mi_readData, // from dmem
  // from controller
  input [2:0]   Di_immSrc,
  input         Di_jal,
  input         Di_mret,
  input         Di_ecall,
  input [3:0]   Ei_ALUCtrl,
  input         Ei_ALUSrc,
  input         Ei_immPlusSrc,
  input [1:0]   Ei_prePCSrc,
  input         Ei_jal,
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

  // to test imem
  output [31:0] Fo_PC,
  // to test dmem
  output [31:0] Mo_ALUOut, Mo_writeData,
  // to controller
  output [31:0] Do_inst,
  output        Eo_zero, Eo_neg, Eo_negU,
  // to hazard
  output [4:0]  Do_rs1, Do_rs2,
  output [4:0]  Eo_rs1, Eo_rs2,
  output [4:0]  Eo_rd,
  output [4:0]  Mo_rd,
  output [4:0]  Wo_rd
);

/* wire */
  // IF stage wire
  wire [31:0] Fw_PCPlus4, Fw_ALUOutJalr;
  wire [31:0] Fw_prePCNext, Fw_PCNext;

  // ID stage wire
  wire [4:0]  Dw_rd   = Do_inst[11:7];   // to WB
  assign      Do_rs1  = Do_inst[19:15];  // to EX
  assign      Do_rs2  = Do_inst[24:20];  // to EX
  wire [31:0] Dw_PC; 
  wire [31:0] Dw_mepc; 
    // to EX
  wire [31:0] Dw_RD1, Dw_RD2;
  wire [31:0] Dw_immExt, Dw_PCPlusImm;
  wire [31:0] Dw_mtvec;
    // to WB
  wire [31:0] Dw_PCPlus4;

  // EX stage wire
  wire [31:0] Ew_RD1, Ew_RD2;
  wire [31:0] Ew_ALUIn1, Ew_ALUIn2;
  wire [31:0] Ew_immExt;
  wire [31:0] Ew_PCPlusImm;
  wire [31:0] Ew_mtvec;
    // to MEM
  wire [31:0] Ew_ALUOut;
  wire [31:0] Ew_writeData;
  wire [31:0] Ew_immPlus;
    // to WB
  wire [31:0] Ew_PCPlus4;
  wire [4:0] Eo_rd;

  // MEM stage wire
    // to WB
  wire [31:0] Mi_readDataExt;
  wire [31:0] Mw_immPlus;
  wire [31:0] Mw_PCPlus4, Mw_resultM;

  // WB stage wire 
  wire [31:0] Ww_resultM;
  wire [31:0] Ww_readDataExt;
  wire [31:0] Ww_resultW;
/* end wire */

// IF stage logic
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
  assign Fw_ALUOutJalr = Ew_ALUOut & ~{32'd1};
  mux4 pre_pc_next_mux(
    .i_1(Fw_PCPlus4), .i_2(Ew_PCPlusImm), 
    .i_3(Ew_mtvec), .i_4(Fw_ALUOutJalr),
    .i_sel(Ei_prePCSrc),
    .o_1(Fw_prePCNext)
  );
  mux3 pc_next_mux(
    .i_1(Fw_prePCNext), .i_2(Dw_PCPlusImm),
    .i_3(Dw_mepc),
    .i_sel({ Di_mret, Di_jal }),
    .o_1(Fw_PCNext)
  );

  // IF/ID reg
  dffREC #(96)
  IFID_datapath_register(
    .i_clock(clk), .i_reset_x(reset_x),
    .i_enable(~Di_stall), .i_clear(Di_flush),
    .i_d({ Fi_inst, Fo_PC, Fw_PCPlus4 }),
    .o_q({ Do_inst, Dw_PC, Dw_PCPlus4 })
  );

// ID stage logic
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

    // exception handle logic
  exceptionHandler exception_handler(
    .clk(clk), .reset_x(reset_x),
    .Di_PC(Dw_PC),
    .Di_ecall(Di_ecall), .Di_mret(Di_mret),
    .Do_mepc(Dw_mepc), .Do_mtvec(Dw_mtvec)
  );

  // ID/EX reg
  dffREC #(207)
  IDEX_datapath_register(
    .i_clock(clk), .i_reset_x(reset_x),
    .i_enable(`HIGH), .i_clear(Ei_flush),
    .i_d({
      Dw_RD1, Dw_RD2, Dw_immExt, Dw_mtvec,
      Dw_PCPlusImm, Dw_PCPlus4,
      Dw_rd, 
      Do_rs1, Do_rs2
    }),
    .o_q({
      Ew_RD1, Ew_RD2, Ew_immExt, Ew_mtvec,
      Ew_PCPlusImm, Ew_PCPlus4,
      Eo_rd, 
      Eo_rs1, Eo_rs2
    })
  );

// EX stage logic
  mux4 forward_in1_mux(
    .i_1(Ew_RD1), .i_2(Mw_resultM),
    .i_3(Ww_resultW), 
    .i_sel(Ei_forwardIn1Src), 
    .o_1(Ew_ALUIn1)
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
    .i_1(Ew_ALUIn1), .i_2(Ew_ALUIn2),
    .o_1(Ew_ALUOut),
    .o_zero(Eo_zero), .o_neg(Eo_neg), .o_negU(Eo_negU)
  );
  mux2 imm_plus_mux(
    .i_1(Ew_immExt), .i_2(Ew_PCPlusImm),
    .i_sel(Ei_immPlusSrc),
    .o_1(Ew_immPlus)
  );

  // EX/MEM reg
  dffREC #(133)
  EXMEM_datapath_register(
    .i_clock(clk), .i_reset_x(reset_x),
    .i_enable(`HIGH), .i_clear(`LOW),
    .i_d({
      Ew_ALUOut, Ew_writeData,
      Ew_immPlus, Ew_PCPlus4,
      Eo_rd
    }),
    .o_q({
      Mo_ALUOut, Mo_writeData,
      Mw_immPlus, Mw_PCPlus4,
      Mo_rd
    })
  );

// MEM stage logic
  readDataExtend read_data_extend(
    .i_isLoadSigned(Mi_isLoadSigned), .i_memSize(Mi_memSize),
    .i_readData(Mi_readData), 
    .o_readDataExt(Mi_readDataExt)
  );
  mux3 result_m_mux(
    .i_1(Mo_ALUOut), .i_2(Mw_immPlus),
    .i_3(Mw_PCPlus4),
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

// WB stage logic
  mux2 result_w_mux(
    .i_1(Ww_resultM), .i_2(Ww_readDataExt),
    .i_sel(Wi_resultWSrc),
    .o_1(Ww_resultW)
  );

/* single */
  // assign w_opcode = i_inst[6:0];
  // assign w_funct3 = i_inst[14:12];
  // assign w_zimm = i_inst[19:15];
  // assign w_succ = i_inst[23:20];
  // assign w_pred = i_inst[27:24];
  // assign w_funct7 = i_inst[31:25];
  // assign w_csr = i_inst[31:20];

endmodule