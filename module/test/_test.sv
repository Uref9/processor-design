// `include "module/.v"

module ();
  reg ;
  wire ;

  reg [31:0] ans;

  instantations

  task assert_task;
    #1
    if (out !== ans) begin
      $display("!!!!!!!!!!!!!!!!!!!!!!!!");
      $display("%b failed.", sel);
      $display("!!!!!!!!!!!!!!!!!!!!!!!!");
      $finish;
    end
  endtask

  initial begin
    $display("++++++++++++++++++++++++");
    $display("++++++++++++++++++++++++");
    $monitor ();
  end

  initial begin
    #1
      i_ctrl = 4'b0000; // Add signed
        i_1 = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
        i_2 = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
        ans = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
        assert_task;

    #1
    $display("Unit test passed.");
    $finish;
  end
endmodule