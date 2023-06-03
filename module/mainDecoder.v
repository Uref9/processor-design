module mainDecoder (
  input [6:0] i_opcode,
  input [2:0] i_funct3,

  output o_memReq, o_memWrite,
  output o_regWrite,
  output o_ALUSrc,
  output [2:0] o_immSrc,
  output o_immPlusSrc,
  output o_isLoadSigned,
  output [1:0] o_resultMSrc,
  output o_resultWSrc,
  output o_csrWrite, o_csrSrc,
  output [1:0] o_csrLUCtrl,


  output o_branch, o_jal, o_jalr,
  output [1:0] o_ALUOp,
  output [1:0] o_EXCOp
);

  assign o_immPlusSrc = ~i_opcode[5];
  assign o_isLoadSigned = ~i_funct3[2];
  assign o_csrSrc = i_funct3[2];
  assign o_csrLUCtrl = i_funct3[1:0];
  assign o_csrWrite = o_csrr;

  assign {o_ALUOp, o_ALUSrc, o_immSrc, 
          o_resultMSrc, o_resultWSrc,
          o_regWrite, o_memReq, o_memWrite,
          o_branch, o_jal, o_jalr, o_csrr, o_EXCOp}

          = mainDecoder(i_opcode, i_funct3);
  
  function [17:0] mainDecoder(
    input [6:0] i_opcode,
    input [2:0] i_funct3
  );
  
    casex (i_opcode)
  //                    AOp2_ASrc_imSrc3_resMSrc2_resWSrc_rgW_mRq_mW_br_jal_jalr_csrr_EXCOp
  
      8'b0000011:     mainDecoder = 18'b00_1_000_00_1_1_1_0_0_0_0_0_00;  // I (load+) type
      // 8'b0001111:                                                    // I (fence+) type
      8'b0010011:                                                       // I (R+i) type
        case (i_funct3[1:0])
          2'b01:      mainDecoder = 18'b10_1_010_00_0_1_0_0_0_0_0_0_00;    // I (shift+i) type
          default:    mainDecoder = 18'b10_1_001_00_0_1_0_0_0_0_0_0_00;    // I (R+i, other) type
        endcase
      8'b0100011:     mainDecoder = 18'b00_1_011_00_0_0_1_1_0_0_0_0_00;  // S type
      8'b0110011:     mainDecoder = 18'b10_0_000_00_0_1_0_0_0_0_0_0_00;  // R type
      8'b0?10111:     mainDecoder = 18'b00_0_100_01_0_1_0_0_0_0_0_0_00;  // U type
      8'b1100011:     mainDecoder = 18'b01_0_101_00_0_0_0_0_1_0_0_0_00;  // B type
      8'b1100111:     mainDecoder = 18'b00_0_110_10_0_1_0_0_0_0_1_0_00;  // I (jalr) type
      8'b1101111:     mainDecoder = 18'b00_0_111_10_0_1_0_0_0_1_0_0_00;  // J type
      8'b1110011:     
        case (i_funct3)
          3'b000:     mainDecoder = 18'b00_0_000_11_0_0_0_0_0_0_0_0_01;  // I (e~), mret, sret, wfi, sfence.vma, ???
          default:    mainDecoder = 18'b00_0_000_11_0_1_0_0_0_0_0_1_00;  // I (csrr~)
        endcase
      default:        mainDecoder = 18'bxx_x_xxx_xx_x_x_x_x_x_x_x_x_10;  // (Illegal Inst.) 
    endcase
  endfunction
endmodule