module ALU(i_1, i_2, ctrl, o_1, o_zero, o_minus);
  // ctrl
  // 000 : Add
  // 001 : Sub
  

  input signed [31:0] i_1, i_2;
  input [2:0] ctrl;
  output signed [31:0] o_1;
  output o_zero, o_minus; // if i_1 - i_2 = or < 0, assert each.

  function [31:0] op;
    input [2:0] ctrl;  
    input signed [31:0] i_1, i_2;

    begin
      case(ctrl)
        3'b000  :op = i_1 + i_2;
        3'b001  :op = i_1 - i_2;
        3'b010  :op = i_1 & i_2;
        3'b011  :op = i_1 | i_2;
        3'b100  :op = i_1 ^ i_2;
        3'b101  :op = i_1 >>> i_2;
        3'b110  :op = i_1 >> i_2;
        3'b111  :op = i_1 << i_2;
        default :op = {32{1'bx}}; // 32bit_x
      endcase
    end
  endfunction


  assign o_1 = op(ctrl, i_1, i_2);
  assign o_zero = ((i_1 - i_2) == 0)? 1 : 0;
  assign o_minus = ((i_1 - i_2) < 0)? 1 : 0;

endmodule