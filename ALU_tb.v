module ALU_tb();
  reg [31:0] i_1, i_2;
  reg [2:0] i_ctrl;
  wire [31:0] o_1;
  wire o_zero, o_neg, o_negU;

  ALU ALU(i_1, i_2, i_ctrl,
          o_1, o_zero, o_neg, o_negU);

  initial begin
    $monitor("%b : %b %b => %b [z:%b][ng:%b][nU:%b]",
              i_ctrl, i_1, i_2, o_1, o_zero, o_neg, o_negU);
  end

  initial begin
    #1
      i_ctrl <= 3'b000; // Add signed
      i_1 <= 2;
      i_2 <= 2;
    #1
      i_ctrl <= 3'b001; // Sub signed
      i_1 <= 128;
      i_2 <= 2;
    #1
      i_ctrl <= 3'b010; // And
      i_1 <= 127;
      i_2 <= 2;
    #1
      i_ctrl <= 3'b011; // Or
      i_1 <= 128;
      i_2 <= 2;
    #1
      i_ctrl <= 3'b100; // Xor
      i_1 <= 32'b0000_0000_0000_0000_0000_0000_0000_0110;
      i_2 <= 32'b0000_0000_0000_0000_0000_0000_0000_1010;
    #1
      i_ctrl <= 3'b101; // Sift right arith.
      i_1 <= 32'b1000_0000_0000_0000_0000_0000_0000_1111;
      i_2 <= 32'b0000_0000_0000_0000_0000_0000_0000_0010;
    #1
      i_ctrl <= 3'b110; // Sift right logic
      i_1 <= 32'b1000_0000_0000_0000_0000_0000_0000_1111;
      i_2 <= 32'b0000_0000_0000_0000_0000_0000_0000_0010;
    #1
      i_ctrl <= 3'b111; // Sift left logic
      i_1 <= 32'b1000_0000_0000_0000_0000_0000_0000_1111;
      i_2 <= 32'b0000_0000_0000_0000_0000_0000_0000_0010;
  end

endmodule