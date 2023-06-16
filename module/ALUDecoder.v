module ALUDecoder (
  input [1:0] i_ALUOp,
  input [2:0] i_funct3,
  input       i_opecodeb5, i_funct7b5,

  output [3:0] o_ALUCtrl
);

  assign o_ALUCtrl = ALUDecoder(i_ALUOp, i_funct3,
                                i_opecodeb5, i_funct7b5);

  function [3:0] ALUDecoder(
    input [1:0] i_ALUOp,
    input [2:0] i_funct3,
    input       i_opecodeb5, i_funct7b5
  );

    case (i_ALUOp)
      2'b00:        ALUDecoder = 4'b0000; // load, store, jalr, etc.
      2'b01:        ALUDecoder = 4'b0001; // B type
      2'b10: 
        case (i_funct3)
          3'b000: if (i_opecodeb5 & i_funct7b5)
                    ALUDecoder = 4'b0001; //  sub
          else
                    ALUDecoder = 4'b0000; //  add+i  
          3'b001:   ALUDecoder = 4'b0111; //  sll+i
          3'b010:   ALUDecoder = 4'b1101; //  slt+i
          3'b011:   ALUDecoder = 4'b1110; //  sltu+i
          3'b100:   ALUDecoder = 4'b0100; //  xor+i
          3'b101: 
            if (i_funct7b5)
                    ALUDecoder = 4'b0101; //  sra+i
            else
                    ALUDecoder = 4'b0110; //  srl+i
          3'b110:   ALUDecoder = 4'b0010; //  or+i
          3'b111:   ALUDecoder = 4'b0011; //  and+i
          default:  ALUDecoder = 4'b0000; //  ???
        endcase 
      default:      ALUDecoder = 4'b0000; //  ???
    endcase
  endfunction
endmodule