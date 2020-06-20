`timescale 1ns / 1ps
//3.2.执行阶段->访存阶段


`include "defines.v"
module ex_mem(
	input clk,
	input rst,
	
	//来自执行阶段的信息
	input wire[4:0] ex_wd,//要写入的目的寄存器地址
	input wire ex_wreg,//是否要写入目的寄存器
	input wire[31:0] ex_wdata,//要写入目的寄存器的值
	input of_i,
	input zf_i,
	
	//加载存储相关信息
	input wire[3:0] ex_aluop,//确定存取
	input wire[9:0] ex_mem_addr,//存放地址
	input wire[31:0] ex_reg2,//存放数据
	
	//输出加载存储相关信息
	output reg[3:0] mem_aluop,//确定存取
	output reg[9:0] mem_mem_addr,//存放地址
	output reg[31:0] mem_reg2,//存放数据
	
	//送到访存阶段的信息
	output reg[4:0] mem_wd,//访存阶段要写入的目的寄存器地址
	output reg mem_wreg,//是否有
	output reg[31:0] mem_wdata,//值
	output reg of_o,
	output reg zf_o
    );

	always@(posedge clk)begin
		if(rst==`RstEnable)begin
			mem_wd<=32'h0;
			mem_wreg<=`WriteDisable;
			mem_wdata<=32'h0;
			of_o<=0;
			zf_o<=0;
			mem_aluop<=4'b0000;
			mem_mem_addr<=32'h0;
			mem_reg2<=32'h0;
			
		end
		else begin
			mem_wd<=ex_wd;
			mem_wreg<=ex_wreg;
			mem_wdata<=ex_wdata;
			of_o<=of_i;
			zf_o<=zf_i;
			mem_aluop<=ex_aluop;
			mem_mem_addr<=ex_mem_addr;
			mem_reg2<=ex_reg2;
		end
	 end


endmodule
