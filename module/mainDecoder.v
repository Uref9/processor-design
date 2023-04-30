module mainDecoder (
  input [6:0] i_opcode,
  input [2:0] i_funct3,

  output o_memReq, o_memWrite,
  output o_regWrite,
  output o_ALUSrc,
  output [2:0] o_immSrc,
  output o_immPlusSrc,
  output o_readDataSrc,
  output [1:0] o_resultSrc,

  output o_branch, o_jal, o_jalr,
  output [1:0] o_ALUOp
);

  assign o_readDataSrc = i_funct3[2];
  assign o_immPlusSrc = ~i_opcode[5];
  assign {o_ALUOp, o_ALUSrc, o_immSrc, o_resultSrc,
          o_regWrite, o_memReq, o_memWrite,
          o_branch, o_jal, o_jalr}
          = mainDecoder(i_opcode, i_funct3);
  
  function [13:0] mainDecoder;
    input [6:0] i_opcode;
    input [2:0] i_funct3;
    casex (i_opcode[6:2])
    // AOp_ASrc_imSrc_resSrc_rgW_mRq_mW_br_jal_jalr
      5'b00000: // I (load+) type
        mainDecoder = 14'b00_1_000_01_1_1_0_0_0_0;
      // 5'b00011: // I (fence+) type
      5'b00100: // I (R+i) type
        case (i_funct3[1:0])
          2'b01: // I (shift+i) type
            mainDecoder = 14'b10_1_001_01_1_1_0_0_0_0;
          default: // I (R+i, other) type
            mainDecoder = 14'b10_1_010_01_1_1_0_0_0_0;
        endcase
      5'b01000: // S type
        mainDecoder = 14'b00_1_011_xx_0_1_1_0_0_0;
      5'b01100: // R type
        mainDecoder = 14'b10_0_xxx_00_1_0_0_0_0_0;
      5'b0?101: // U type
        mainDecoder = 14'bxx_x_100_10_1_0_0_0_0_0;
      5'b11000: // B type
        mainDecoder = 14'b01_0_101_xx_0_0_0_1_0_0;
      5'b11001: // I (jalr) type
        mainDecoder = 14'b00_x_110_11_1_0_0_0_0_1;
      5'b11011: // J type
        mainDecoder = 14'bxx_x_111_11_1_0_0_0_1_0;
      // 5'b11100: // I (e~, csr~) type
      default: // I(fence+, e~, csr~) , ??? 
        mainDecoder = 14'bxx_x_xxx_xx_x_x_x_x_x_x;
    endcase;
  endfunction
endmodule