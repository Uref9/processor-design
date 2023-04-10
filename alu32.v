module ALU32(i_1, i_2, ctrl, o_1);
  // ctrl
  // 000 : Add
  // 001 : Sub
  

  input signed [31:0] i_1, i_2;
  input [2:0] ctrl;
  output signed [31:0] o_1;

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

endmodule