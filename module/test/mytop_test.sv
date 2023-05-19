// `include "module/.v"

module top_test ();
  reg         clk, rst;
  reg         ACKD_n, ACKI_n;
  reg [31:0]  IDT;
  reg [2:0]   OINT_n;
  
  wire [31:0] IAD, DAD;
  wire        MREQ, WRITE;
  wire [1:0]  SIZE;
  wire        IACK_n;

  // inout
  reg [31:0]  DDT;  // in: readData, out: writeData

  reg [31:0] ans;
  reg res;

  top u_top_1(//Inputs
              .clk(clk), .rst(rst),
              .ACKD_n(ACKD_n), .ACKI_n(ACKI_n), 
              .IDT(IDT), .OINT_n(OINT_n),
      
              //Outputs
              .IAD(IAD), .DAD(DAD), 
              .MREQ(MREQ), .WRITE(WRITE), 
              .SIZE(SIZE), .IACK_n(IACK_n), 
      
              //Inout
              .DDT(DDT)
              );

  function check;
    input [3:0] i_ctrl;
    input [31:0] o_1, ans;
    if (o_1 !== ans) begin
      $display("!!!!!!!!!!!!!!!!!!!!!!!!");
      $display("%b failed.", i_ctrl);
      $display("!!!!!!!!!!!!!!!!!!!!!!!!");
      $finish;
    end
  endfunction

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
        #1
        res = check(i_ctrl, o_1, ans);

    #1
    $display("Check passed.");
    $finish;
  end
endmodule