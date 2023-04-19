module instDecoder(
  input [31:0] i_inst,
  output [31:0] o_imm,
  output [4:0] o_rs1, o_rs2, o_rd,
  output [2:0] o_ALUCtrl,
  output o_regWrite, o_ALUSrc, o_branch,
          o_mem2Reg, o_memUse, o_memWrite);

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

  assign o_imm = setImm();

  function setControlBit;
    ;
    
  endfunction

  // Sort and SignedExtend immediate.
  function [31:0] setImm;
    input [6:0] w_opcode;
    input [2:0] w_funct3;
    casex (w_opcode[6:2])
      // U type
      5'b0x101: setImm = { {12{i_inst[31]}}, i_inst[31:12] };
      // J type
      5'b11011: setImm = { {11{i_inst[31]}},
                          i_inst[31], i_inst[19:12],
                          i_inst[20], i_inst[30:12], 1'b0 };
      // I (R+i) type
      5'b00100: 
        if (w_funct3[1:0] == 2'b01)
          setImm = {  {20{i_inst[31]}}, i_inst[31:20] };
        else
          // imm = ext(shamt)
          setImm = {  {27{1'b0}}, i_inst[24:20] };
      // I (jalr) type
      5'b11001: setImm = {  {20{i_inst[31]}}, i_inst[31:20] };
      // I (load+) type
      5'b00000: setImm = {  {20{i_inst[31]}}, i_inst[31:20] };
      // B type
      5'b11000: setImm = { {19{i_inst[31]}}, 
                          i_inst[31], i_inst[7], i_inst[30:25],
                          i_inst[11:8], 1'b0 };
      // S type
      5'b01000: setImm = { {20{i_inst[31]}},
                          i_inst[31:25], i_inst[11:7] };
      default: setImm = {32'b0};
    endcase;
  endfunction

  always @(*) begin
    // Classify instruction type.
    case (w_opcode[6:2])
      5'b000xx: ;//w_opcode[6:4] I(load, fence)
      5'b001xx: ;// I(R+i)
      5'b010xx: ;// S
      5'b011xx: ;// R
      // 5'b100xx: not exist
      5'bxx101: ;// U
      5'b110xx: ;// B, J
      5'b111xx: ;// I(e~, csr~)
      default: ;
    endcase
    
  end

endmodule