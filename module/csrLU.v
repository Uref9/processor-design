module csrLU (
  input [1:0] i_ctrl,
  input [31:0] i_1, i_2,

  output [31:0] o_1
);
// ictrl
// 01 : i_2
// 10 : i_1 or i_2 
// 11 : i_1 and (not i_2)

  assign o_1 = operation(i_ctrl, i_1, i_2);

  function [31:0] operation (
    input [1:0] i_ctrl,
    input [31:0] i_1, i_2
  );
    case (i_ctrl)
      2'b01:    operation =       i_2;
      2'b10:    operation = i_1 | i_2;
      2'b11:    operation = i_1 & ~i_2;
      default:  operation = 32'bx;
    endcase
  endfunction
endmodule