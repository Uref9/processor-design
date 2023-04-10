module ALU32(in_1, in_2, Ctrl, out_1);
  // Ctrl
  // 000 : Add
  // 001 : Sub
  

  input signed [31:0] in_1, in_2;
  input [2:0] Ctrl;
  output signed [31:0] out_1;

  function [31:0] op;
    input [2:0] Ctrl;  
    input signed [31:0] in_1, in_2;

    begin
      case(Ctrl)
        3'b000  :op = in_1 + in_2;
        3'b001  :op = in_1 - in_2;
        3'b010  :op = in_1 & in_2;
        3'b011  :op = in_1 | in_2;
        3'b100  :op = in_1 ^ in_2;
        3'b101  :op = in_1 >>> in_2;
        3'b110  :op = in_1 >> in_2;
        3'b111  :op = in_1 << in_2;
        default :op = {32{1'bx}}; // 32bit_x
      endcase
    end
  endfunction

  assign out_1 = op(Ctrl, in_1, in_2);

endmodule