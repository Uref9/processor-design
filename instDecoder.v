module InstDecoder(i_inst, o_rs1, o_rs2, o_rd, o_ALUCtrl, o_imm, 
                    o_regWrite, o_ALUSrc, o_branch, 
                    o_mem2Reg, o_memRead, o_memWrite);
  input [31:0] i_inst;
  output [4:0] o_rs1, o_rs2, o_rd;
  output [2:0] o_ALUCtrl;
  output [31:0] o_imm;
  output o_regWrite, o_ALUSrc, o_branch, 
          o_mem2Reg, o_memRead, o_memWrite;
  wire [6:0] w_op;

  assign op = i_inst[6:0];


endmodule