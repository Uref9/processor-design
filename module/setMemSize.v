module setMemSize (
  input [2:0] i_funct3,

  output [1:0] o_memSize
);

  assign o_memSize = setMemSize(i_funct3);

  function [1:0] setMemSize(
    input [2:0] i_funct3
  );
    
    case (i_funct3)
      3'b000:   setMemSize = 2'b10; // byte (10 or 11) 
      3'b001:   setMemSize = 2'b01; // half-word
      3'b010:   setMemSize = 2'b00; // word
      default:  setMemSize = 2'bxx; // ???
    endcase
  endfunction
  
endmodule