module controller(
  input [31:0] i_inst,
  input i_zero, i_neg, i_negU,

  output o_memReq, o_memWrite,
  output o_regWrite,
  output [1:0] o_PCSrc,
  output o_ALUSrc,
  output [2:0] o_immSrc,
  output o_immPlusSrc,
  output [2:0] o_readDataSrc,
  output [1:0] o_resultSrc,
  output [3:0] o_ALUCtrl
);

  wire [6:0] w_opcode;
  wire [2:0] w_funct3;
  wire [6:0] w_funct7;

  wire w_branch;
  wire w_jal, w_jalr;

  wire [1:0] w_ALUOp;

  assign w_opcode = i_inst[6:0];
  assign w_funct3 = i_inst[14:12];
  assign w_funct7 = i_inst[31:25];

  assign o_readDataSrc = w_funct3;
  assign o_immPlusSrc = ~i_inst[5];


// jump or branch (setPCSrc)

  assign o_PCSrc[1] = w_jalr;
  assign o_PCSrc[0] = w_jal | branchJudge(
                              w_branch, i_zero, i_neg, i_negU,
                              w_funct3);

  function branchJudge;
    input w_branch;
    input i_zero, i_neg, i_negU;
    input w_funct3;
    if (w_branch) begin
      case (w_funct3)
        3'b000: // beq 
          branchJudge = i_zero;
        3'b001: // bne
          branchJudge = ~i_zero;
        3'b100: // blt
          branchJudge = i_neg;
        3'b101: // bge
          branchJudge = ~i_neg;
        3'b110: // bltu
          branchJudge = i_negU;
        3'b111: // bgeu
          branchJudge = ~i_negU;
        default: // ???
          branchJudge = 1'bx;
      endcase
    end 
    else begin
      branchJudge = 1'b0;
    end
  endfunction

// main decoder 
  assign {w_ALUOp, o_ALUSrc, o_immSrc, o_resultSrc,
          o_regWrite, o_memReq, o_memWrite,
          w_branch, w_jal, w_jalr}
          = mainDecoder(w_opcode, w_funct3);
  
  function [13:0] mainDecoder;
    input [6:0] w_opcode;
    input [2:0] w_funct3;
    casex (w_opcode[6:2])
    // AOp_ASrc_imSrc_resSrc_rgW_mRq_mW_br_jal_jalr
      5'b00000: // I (load+) type
        mainDecoder = 14'b00_1_000_01_1_1_0_0_0_0;
      // 5'b00011: // I (fence+) type
      5'b00100: // I (R+i) type
        case (w_funct3[1:0])
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
// ALU decoder

  assign o_ALUCtrl = ALUDecoder(w_ALUOp, w_funct3,
                                w_opcode[5], w_funct7[5]);

  function [3:0] ALUDecoder;
    input [1:0] w_ALUOp;
    input [2:0] w_funct3;
    input w_opecodeb5, w_funct7b5;

    // reg r_subR;
    // assign r_subR = w_opecodeb5 & w_funct7b5;

    case (w_ALUOp)
      2'b00:        ALUDecoder = 4'b0000; // load, store, jalr
      2'b01:        ALUDecoder = 4'b0001; // B type
      2'b10: 
        case (w_funct3)
          3'b000: if (w_opecodeb5 & w_funct7b5) begin
                    ALUDecoder = 4'b0001; //  sub+i
          end else begin
                    ALUDecoder = 4'b0000; //  add+i  
          end
          3'b001:   ALUDecoder = 4'b0111; //  sll+i
          3'b010:   ALUDecoder = 4'b0100; //  slt+i
          3'b011:   ALUDecoder = 4'b1100; //  sltu+i
          3'b100:   ALUDecoder = 4'b1010; //  xor+i
          3'b101: 
            if (w_funct7b5) begin
                    ALUDecoder = 4'b0101; //  sra+i
            end else begin
                    ALUDecoder = 4'b0110; //  srl+i
            end
          3'b110:   ALUDecoder = 4'b0010; //  or+i
          3'b111:   ALUDecoder = 4'b0011; //  and+i
          default:  ALUDecoder = 4'bxxxx; //  ???
        endcase 
      default:      ALUDecoder = 4'bxxxx; //  ???
    endcase
  endfunction

endmodule