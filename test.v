`timescale 1ns / 1ps


module test;

	// Inputs
	reg clk;
	reg clkm;
	reg rst;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk(clk), 
		.clkm(clkm), 
		.rst(rst)
	);

	initial begin
		clk = 0;
		clkm = 0;
		rst = 0;
	end
	always #50 clk=~clk;
	always #10 clkm=~clkm;
	initial begin
		#10;
		rst=1;
		#195;
		rst=0;

	end
      
endmodule

