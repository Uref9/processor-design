module mux3(
  input [31:0] i_1, i_2, i_3,
  input [1:0] i_sel,
  output [31:0] o_1
);

  assign o_1 = i_sel[1] ? i_3
                        : (i_sel[0] ? i_2
                                    : i_1);

endmodule