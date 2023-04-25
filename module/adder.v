module adder(
  input [31:0] i_1, i_2,
  output [31:0] o_1
);

  assign o_1 = i_1 + i_2;

endmodule