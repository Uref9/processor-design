module readDataExtend(
  input i_readDataSrc,
  input [1:0] i_memSize,
  input [31:0] i_readData,

  output [31:0] o_readDataExt
);

  assign o_readDataExt = extend(i_readDataSrc, i_memSize, i_readData);

  function [31:0] extend;
    input i_readDataSrc;
    input [1:0] i_memSize;
    input [31:0] i_readData;

    case (i_readDataSrc)
      1'b0: extend = i_readData;  // loadu
      1'b1:                       // load (signed)
        case (i_memSize)
          2'b00: extend = i_readData;                                 // word
          2'b01: extend = { {16{i_readData[15]}}, i_readData[15:0] }; // halfw
          2'b10: extend = { {24{i_readData[7]}}, i_readData[7:0] };   // byte
          2'b11: extend = { {24{i_readData[7]}}, i_readData[7:0] };   // byte
          default: extend = i_readData;
        endcase
      default: extend = {32{1'bx}};
    endcase
  endfunction

endmodule