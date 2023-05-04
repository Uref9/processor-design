
`define  ZERO           1'b0           // Rename to Zero
`define  LOW            1'b0           // Rename to Zero
`define  HIGH           1'b1           // Rename to High
`include "module/DW_ram_2r_w_s_dff.v"

module rf32x32(
							// clock and reset
							clk,reset,
							// Inputs
							wr_n,
							rd1_addr, rd2_addr, wr_addr,
							data_in,

							// Outputs
							data1_out, data2_out
							);

	parameter data_width      = 32;
	parameter depth           = 32;
	parameter bit_width_depth = 5;  // ceil(log2(depth))
	parameter rst_mode        = 0;  // 0: asynchronously initializes the RAM
																		// 1: synchronously

	//*** I/O declarations ***//
	input                          clk;       // clock
	input 			  reset;
	input                          wr_n;      // Write enable, active low
	input  [bit_width_depth-1 : 0] rd1_addr;  // Read0 address bus  
	input  [bit_width_depth-1 : 0] rd2_addr;  // Read1 address bus
	input  [bit_width_depth-1 : 0] wr_addr;   // Write address bus
	input       [data_width-1 : 0] data_in;   // Input data bus

	output      [data_width-1 : 0] data1_out; // Output data bus for read0
	output      [data_width-1 : 0] data2_out; // Output data bus for read1


	//*** wire declarations ***//
	wire 			  clk_inv;
	wire        [data_width-1 : 0] ram_data1_out;
	wire        [data_width-1 : 0] ram_data2_out;


	assign    clk_inv = ~clk;
	assign  data1_out = (|rd1_addr) ? ram_data1_out : {data_width{`ZERO}};
	assign  data2_out = (|rd2_addr) ? ram_data2_out : {data_width{`ZERO}};

	// Instance of DW_ram_2r_w_s_lat
	DW_ram_2r_w_s_dff #(data_width, depth, rst_mode)
	u_DW_ram_2r_w_s_dff(
				// .clk(clk_inv), // for multi cycle
				.clk(clk),	// for single cycle 
				.rst_n(reset),
				.cs_n(`LOW), .wr_n(wr_n),
				.rd1_addr(rd1_addr), .rd2_addr(rd2_addr),
				.wr_addr(wr_addr),
				.data_in(data_in),
				.data_rd1_out(ram_data1_out),
				.data_rd2_out(ram_data2_out)
	);

endmodule // rf32x32


