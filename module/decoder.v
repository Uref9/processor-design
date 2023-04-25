module decoder(
  input [31:0]  i_inst,

  output [4:0]  o_rs1, o_rs2, o_rd,
  output        o_regWrite,
  output [2:0]  o_ALUCtrl,
  output        o_resultSrc,
  output [1:0]  o_PCSrc,
  output        o_ALUSrc,
  output        o_memRead, o_memWrite,
  output [31:0] o_imm
);

  wire [11:0] w_csr;
  wire [6:0] w_opcode;
  wire [6:0] w_funct7;
  wire [4:0] w_zimm;
  wire [3:0] w_pred, w_succ;
  wire [2:0] w_funct3;

  assign w_opcode = i_inst[6:0];
  assign o_rd = i_inst[11:7];
  assign w_funct3 = i_inst[14:12];
  assign o_rs1 = i_inst[19:15];
  assign w_zimm = i_inst[19:15];
  assign o_rs2 = i_inst[24:20];
  assign w_succ = i_inst[23:20];
  assign w_pred = i_inst[27:24];
  assign w_funct7 = i_inst[31:25];
  assign w_csr = i_inst[31:20];


  function [1:0] PCSrc;
    ;
    
  endfunction

  // function [2:0] ALUCtrl;
  //   ;
    
  // endfunction

endmodule