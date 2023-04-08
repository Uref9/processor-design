module alu32(A, B, S, R);
  input signed [31:0] A, B;
  input [2:0] S;
  output signed [31:0] R;

  function [31:0] op;
    input [2:0] s;  
    input signed [31:0] a, b;

    begin
      case(s)
        3'b000  :op = a + b;
        3'b001  :op = a - b;
        3'b010  :op = a & b;
        3'b011  :op = a | b;
        3'b100  :op = a ^ b;
        3'b101  :op = a >>> b;
        3'b110  :op = a >> b;
        3'b111  :op = a << b;
        default :op = 32'bXXXX_XXXX_XXXX_XXXX_XXXX_XXXX_XXXX_XXXX;
      endcase
    end
  endfunction

  assign R = op(S, A, B);

endmodule