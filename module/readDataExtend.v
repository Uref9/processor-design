module readDataExtend(
  input [31:0] i_readData,
  input [2:0] i_readDataSrc,
  output [31:0] o_readDataExt
);

  assign o_readDataExt = extend(i_readData, i_readDataSrc);

  function [31:0] extend;
    input [31:0] i_readData;
    input [2:0] i_readDataSrc;

    case (i_readDataSrc)
      3'b000: // lb
        extend = { {24{i_readData[7]}}, i_readData[7:0] }; 
      3'b001: // lh
        extend = { {16{i_readData[15]}}, i_readData[15:0] }; 
      3'b010: // lw
        extend = i_readData;
      3'b100: // lbu
        extend = { {24{1'b0}}, i_readData[7:0] }; 
      3'b101: // lhu
        extend = { {16{1'b0}}, i_readData[15:0] }; 
      default: 
        extend = {32{1'bx}};
    endcase
  endfunction

endmodule