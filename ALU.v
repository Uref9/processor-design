module ALU(i_1, i_2, i_ctrl,
            o_1, o_zero, o_neg, o_negU);
  // i_ctrl
  // 000 : Add
  // 001 : Sub
  // 010 :
  // 011 :
  // 100 :
  // 101 :
  // 110 :
  // 111 :

  input signed [31:0] i_1, i_2;
  input [2:0] i_ctrl;
  output signed [31:0] o_1;
  output o_zero, o_neg, o_negU;
  // if i_1 - i_2 = or < 0, assert each.(signed or Unsigned)

  function [31:0] op;
    input [2:0] i_ctrl;  
    input signed [31:0] i_1, i_2;

    begin
      case(i_ctrl)
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


  assign o_1 = op(i_ctrl, i_1, i_2);
  assign o_zero = ((i_1 - i_2) == 0)? 1 : 0;
  assign o_neg = ((i_1 - i_2) < 0)? 1 : 0;
  assign o_negU = (($signed(i_1) - $signed(i_2)) < 0)? 1 : 0;

endmodule