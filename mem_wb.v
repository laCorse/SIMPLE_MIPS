`timescale 1ns / 1ps
//4.2.访存阶段->写回阶段

`include "defines.v"

module mem_wb(
	input clk,
	input rst,
	
	//访存阶段传递来的信息
	input wire[4:0] mem_wd,
	input wire mem_wreg,
	input wire[31:0] mem_wdata,
	
	//传给写回阶段的信息
	output reg[4:0] wb_wd,
	output reg wb_wreg,
	output reg[31:0] wb_wdata
    );
	 always@(posedge clk)begin
		if(rst==`RstEnable)begin
			wb_wd<=5'b0;//写回地址
			wb_wreg<=`WriteDisable;//是否写
			wb_wdata<=32'h0;//写回数据
		end
		else begin
			wb_wd<=mem_wd;//写回地址
			wb_wreg<=mem_wreg;//是否写
			wb_wdata<=mem_wdata;//写回数据
		end
	 end
endmodule
