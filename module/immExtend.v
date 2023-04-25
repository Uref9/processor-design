module immExtend(
  input [31:0]  i_inst,
  input [2:0] i_immSrc,

  output [31:0] o_imm
);

  assign o_imm = setImm(i_inst, i_immSrc);

  function [31:0] setImm;
    input [31:0] i_inst;
    input [2:0] i_immSrc;

    case (i_immSrc)
      3'b000: // I (load+) type
        setImm = {  {20{i_inst[31]}}, i_inst[31:20] };
      3'b001: // I (R+i) type
        setImm = {  {20{i_inst[31]}}, i_inst[31:20] };
      3'b010: // I (sll, shamt) type 
        setImm = {  {27{1'b0}}, i_inst[24:20] };
      3'b011: // S type
        setImm = { {20{i_inst[31]}},
                    i_inst[31:25], i_inst[11:7] };
      3'b100: // U type (<< 12 and 0 padding)
        setImm = { i_inst[31:12], {12{1'b0}} };
      3'b101: // B type
        setImm = { {19{i_inst[31]}}, i_inst[31], i_inst[7],
                    i_inst[30:25], i_inst[11:8], 1'b0 };
      3'b110: // I (jalr) type
        setImm = { {20{i_inst[31]}}, i_inst[31:20] };
      3'b111: // J type
        setImm = { {11{i_inst[31]}}, i_inst[31], i_inst[19:12],
                    i_inst[20], i_inst[30:12], 1'b0 };
      default: // ???
        setImm = {32'bx};
    endcase

  endfunction


endmodule