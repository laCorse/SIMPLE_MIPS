`timescale 1ns / 1ps


module top(
	//from outside
	input clk,
	input clkm,
	input rst
    );
	 
	wire [31:0]douta;//ROM中取出的指令
	wire [9:0]addra;
	
	wire [31:0]ram_data;
	wire mem_we;
	wire [9:0]mem_addr;
	wire [31:0]mem_data;
	 
	Inst_Rom ROM0 (
	.clka(clk), // input clka
	.addra(addra), // input [9 : 0] addra
	.douta(douta) // output [31 : 0] douta
	);
	
	
	
	pipline pipline0(
	.clk(clk),
	.rst(rst),
	
	.inst(douta),//从ROM中得到指令
	.inst_addr(addra),//送给ROM
	
	.ram_data(ram_data),
	.mem_we(mem_we),
	.mem_addr(mem_addr),
	.mem_data(mem_data)
    );

	
	Mem_Ram Ram0 (
	.clka(clkm), // input clka
	.wea(mem_we), // input [0 : 0] wea
	.addra(mem_addr), // input [9 : 0] addra
	.dina(mem_data), // input [31 : 0] dina
	.douta(ram_data) // output [31 : 0] douta
	);

endmodule
