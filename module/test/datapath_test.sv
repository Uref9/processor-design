// `include "module/.v"

module datapath_test ();
  input i_clk, i_reset;
  input [31:0] i_inst, i_readData;

  input [1:0] i_memSize;
  input i_regWrite;
  input [1:0] i_PCSrc;
  input i_ALUSrc;
  input [2:0] i_immSrc;
  input i_immPlusSrc;
  input i_isLoadSigned;
  input [1:0] i_resultSrc;
  input [3:0] i_ALUCtrl;

  output [31:0] o_PC, o_ALUOut, o_writeData;

  output o_zero, o_neg, o_negU;

  reg [31:0] ans;
  reg res;

  datapath datapath(
    .i_clk, .i_reset,
    .i_inst, .i_readData,

    .i_memSize,
    .i_regWrite,
    .i_PCSrc, .i_ALUSrc,
    .i_immSrc, .i_immPlusSrc,
    .i_isLoadSigned, .i_resultSrc,
    .i_ALUCtrl,

    .o_PC, .o_ALUOut, .o_writeData,

    .o_zero, .o_neg, .o_negU
  );

  function check;
    input [3:0] i_ctrl;
    input [31:0] o_1, ans;
    if (o_1 !== ans) begin
      $display("!!!!!!!!!!!!!!!!!!!!!!!!");
      $display("%b failed.", i_ctrl);
      $display("!!!!!!!!!!!!!!!!!!!!!!!!");
      $finish;
    end
  endfunction

  // initial begin
  //   $display("++++++++++++++++++++++++");
  //   $display("++++++++++++++++++++++++");
  //   $monitor ();
  // end

  initial begin
    #1
      i_ctrl = 4'b0000; // Add signed
        i_1 = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
        i_2 = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
        ans = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
        #1
        res = check(i_ctrl, o_1, ans);

    #1
    $display("unit test passed.");
    $finish;
  end
endmodule