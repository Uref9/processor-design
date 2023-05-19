// `include "module/.v"

module controller_test ();
  reg [31:0] i_inst;

  reg i_zero, i_neg, i_negU;

  wire o_memReq, o_memWrite;
  wire [1:0] o_memSize;

  wire o_regWrite;
  wire [1:0] o_PCSrc;
  wire o_ALUSrc;
  wire [2:0] o_immSrc;
  wire o_immPlusSrc;
  wire       o_isLoadSigned;
  wire [1:0] o_resultSrc;
  wire [3:0] o_ALUCtr;


  reg [31:0] ans;
  reg res;

  wire [6:0] opcode = i_inst[6:0];

  controller controller(
    .i_inst,

    .i_zero, .i_neg, .i_negU,

    .o_memReq, .o_memWrite,
    .o_memSize,

    .o_regWrite, 
    .o_PCSrc, .o_ALUSrc, 
    .o_immSrc, .o_immPlusSrc, 
    .o_isLoadSigned, .o_resultSrc, 
    .o_ALUCtrl
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

  initial begin
    $display("++++++++++++++++++++++++");
    $display("++++++++++++++++++++++++");
    $monitor ();
  end

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