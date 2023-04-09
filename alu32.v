module alu32(in_1, in_2, ctrl, out_1);
  // ctrl
  // 000 : Add
  // 001 : Sub
  

  input signed [31:0] in_1, in_2;
  input [2:0] ctrl;
  output signed [31:0] out_1;

  function [31:0] op;
    input [2:0] ctrl;  
    input signed [31:0] in_1, in_2;

    begin
      case(ctrl)
        3'b000  :op = in_1 + in_2;
        3'b001  :op = in_1 - in_2;
        3'b010  :op = in_1 & in_2;
        3'b011  :op = in_1 | in_2;
        3'b100  :op = in_1 ^ in_2;
        3'b101  :op = in_1 >>> in_2;
        3'b110  :op = in_1 >> in_2;
        3'b111  :op = in_1 << in_2;
        default :op = 32'bXXXX_XXXX_XXXX_XXXX_XXXX_XXXX_XXXX_XXXX;
      endcase
    end
  endfunction

  assign out_1 = op(ctrl, in_1, in_2);

endmodule