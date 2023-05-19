module mux4 #(
  parameter WIDTH = 32
)(
  input [WIDTH-1:0] i_1, i_2, i_3, i_4,
  input [1:0] i_sel,
  output [WIDTH-1:0] o_1
);
  // i_sel : o_1
  // ---------
  // 00 : i_1
  // 01 : i_2
  // 10 : i_3
  // 11 : i_4

  assign o_1 = i_sel[1] ? (i_sel[0] ? i_4
                                    : i_3)
                        : (i_sel[0] ? i_2
                                    : i_1);

endmodule