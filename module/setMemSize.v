module setMemSize (
  input [2:0] i_funct3,

  output [1:0] o_memSize
);

  assign o_memSize = setMemSize(i_funct3);

  function [1:0] setMemSize(
    input [2:0] i_funct3
  );
    
    case (i_funct3[1:0])
      2'b00:   setMemSize = 2'b10; // byte (10 or 11) 
      2'b01:   setMemSize = 2'b01; // half-word
      2'b10:   setMemSize = 2'b00; // word
      default:  setMemSize = 2'bxx; // ???
    endcase
  endfunction
  
endmodule