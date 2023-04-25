`include "module/controller.v"
`include "module/datapath.v"

module top(
  input i_clk, i_reset,
  input [31:0] i_inst,

  output [31:0] o_PC,
  output [31:0] o_ALUOut,
  output o_memReq, o_memWrite,

  inout [31:0] io_dmemData  // in: readData, out: writeData
);

  wire w_regWrite;

  wire w_ALUSrc;
  wire [1:0] w_PCSrc;
  wire [2:0] w_immSrc;
  wire w_immPlusSrc;
  wire [1:0] w_readDataSrc;
  wire [1:0] w_resultSrc;
  wire [3:0] w_ALUCtrl;

  wire w_zero, w_neg, w_negU;


  datapath datapath(
    .i_clk(i_clk), .i_reset(i_reset),
    .i_inst(i_inst), .i_readData(io_dmemData),
    .i_regWrite(w_regWrite),
    .i_PCSrc(w_PCSrc), .i_ALUSrc(w_ALUSrc),
    .i_immSrc(w_immSrc), .i_immPlusSrc(w_immPlusSrc),
    .i_readDataSrc(w_readDataSrc), .i_resultSrc(w_resultSrc),
    .i_ALUCtrl(w_ALUCtrl),
    .o_PC(o_PC), .o_ALUOut(o_ALUOut), .o_writeData(io_dmemData),
    .o_zero(w_zero), .o_neg(w_neg), .o_negU(w_negU)
  );

  controller controller(
    .i_inst(i_inst),
    .i_zero(w_zero), .i_neg(w_neg), .i_negU(w_negU),
    .o_memReq(o_memReq), .o_memWrite(o_memWrite),

    .o_regWrite(w_regWrite), 
    .o_PCSrc(w_PCSrc), .o_ALUSrc(w_ALUSrc), 
    .o_immSrc(w_immSrc), .o_immPlusSrc(w_immPlusSrc), 
    .o_readDataSrc(o_readDataSrc), .o_resultSrc(w_resultSrc), 
    .o_ALUCtrl(w_ALUCtrl)
  );

endmodule