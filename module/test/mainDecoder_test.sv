// `include "module/mainDecoder.v"

module mainDecoder_test();
  reg [6:0] i_opcode;
  reg [2:0] i_funct3;

  wire o_memReq, o_memWrite;
  wire o_regWrite;
  wire o_ALUSrc;
  wire [2:0] o_immSrc;
  wire o_immPlusSrc;
  wire o_isLoadSigned;
  wire [1:0] o_resultSrc;

  wire o_branch, o_jal, o_jalr;
  wire [1:0] o_ALUOp;


  reg [31:0] ans_ctrls;
  reg res;

  // AOp_ASrc_imSrc_resSrc_rgW_mRq_mW_br_jal_jalr
  wire [13:0] ctrls = {o_ALUOp, o_ALUSrc, o_immSrc, o_resultSrc,
                o_regWrite, o_memReq, o_memWrite,
                o_branch, o_jal, o_jalr
                };

  mainDecoder main_decoder(
    .i_opcode, .i_funct3,

    .o_memReq, .o_memWrite,
    .o_regWrite,
    .o_ALUSrc, .o_immSrc,
    .o_immPlusSrc, .o_isLoadSigned,
    .o_resultSrc,

    .o_branch,
    .o_jal, .o_jalr,
    .o_ALUOp
  );

  function check;
    input [6:0] i_opcode;
    input [2:0] i_funct3;
    input [31:0] ctrls, ans_ctrls;
    if (ctrls !== ans_ctrls) begin
      $display("!!!!!!!!!!!!!!!!!!!!!!!!");
      $display("op(%b), f3(%b) failed.", i_opcode, i_funct3);
      $display("!!!!!!!!!!!!!!!!!!!!!!!!");
      $finish;
    end
  endfunction

  initial begin
    $display("++++++++++++++++++++++++");
    $display("++++++++++++++++++++++++");
    $monitor ("%b %b %b", i_opcode, i_funct3, ctrls, "\n----");
  end

  initial begin
    // opcode
    #1 // 
      i_opcode  = 7'b00000_11;
      i_funct3  = 3'b000;
      ans_ctrls = 14'b00_1_000_01_1_1_0_0_0_0;
      #1
        res = check(i_opcode, i_funct3, ctrls, ans_ctrls);
      

    #1
    $display("Check passed.");
    $finish;
  end
endmodule