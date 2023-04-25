module ALU(
  input [3:0]    i_ctrl,
  input [31:0]   i_1, i_2,

  output [31:0]  o_1,
  output         o_zero, o_neg, o_negU
);
  // if i_1 - i_2 = or < 0, assert each.(signed or Unsigned)

  // i_ctrl
  // 000 : Add
  // 001 : Sub
  // 010 :
  // 011 :
  // 100 :
  // 101 :
  // 110 :
  // 111 :


  function [31:0] operation;
    input [3:0] i_ctrl;  
    input [31:0] i_1, i_2;

    begin
      case(i_ctrl)
        4'b0000: operation = $signed(i_1) + $signed(i_2);
        4'b0001: operation = $signed(i_1) - $signed(i_2);
        4'b0010: operation = i_1 & i_2;
        4'b0011: operation = i_1 | i_2;
        4'b0100: // slt
          if ($singed(i_1) < $signed(i_2))
                operation = {32'd1};
          else  operation = {32'd0};
        4'b0101: operation = $signed(i_1) >>> $signed(i_2);
        4'b0110: operation = i_1 >> i_2;
        4'b0111: operation = i_1 << i_2;
        4'b1001: operation = i_1 - i_2;
        4'b1010: operation = i_1 ^ i_2;
        4'b1100: // sltu
          if (i_1 < i_2)
                operation = {32'd1};
          else  operation = {32'd0};
        default: operation = {32{1'bx}}; // 32bit_x
      endcase
    end
  endfunction


  assign o_1 = operation(i_ctrl, i_1, i_2);
  assign o_zero = (i_1 == i_2)? 1 : 0;
  assign o_neg = ($signed(i_1) < $signed(i_2))? 1 : 0;
  assign o_negU = (i_1 < i_2)? 1 : 0;

endmodule