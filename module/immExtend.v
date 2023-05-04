module immExtend(
  input [2:0] i_immSrc,
  input [31:0]  i_inst,

  output [31:0] o_immExt
);

  assign o_immExt = setImm(i_inst, i_immSrc);

  function [31:0] setImm(
    input [31:0] i_inst,
    input [2:0] i_immSrc
  );
    case (i_immSrc)
      3'b000: setImm = { {20{i_inst[31]}}, i_inst[31:20] };   // I (load+) type
      3'b001: setImm = { {20{i_inst[31]}}, i_inst[31:20] };   // I (R+i) type
      3'b010: setImm = { {27{1'b0}}, i_inst[24:20] };         // I (sll, shamt) type 
      3'b011: setImm = { {20{i_inst[31]}},                    // S type
                          i_inst[31:25], i_inst[11:7] };  
      3'b100: setImm = { i_inst[31:12], {12{1'b0}} };         // U type (<< 12 and 0 padding)
      3'b101: setImm = { {19{i_inst[31]}}, i_inst[31],        // B type
                          i_inst[7], i_inst[30:25], 
                          i_inst[11:8], 1'b0 };
      3'b110: setImm = { {20{i_inst[31]}}, i_inst[31:20] };   // I (jalr) type
      3'b111: setImm = { {11{i_inst[31]}}, i_inst[31],        // J type
                          i_inst[19:12], i_inst[20], 
                          i_inst[30:21], 1'b0 };
      default: setImm = {32'bx};                              // ???
    endcase
  endfunction


endmodule