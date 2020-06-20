`timescale 1ns / 1ps
//2.2.译码阶段->运算阶段

`include "defines.v"


module id_ex(
	input clk,
	input rst,
	
	//译码阶段传递来的信息
	input wire [3:0]id_aluop,//运算子类型
	input wire [2:0]id_alusel,//运算类型
	input wire [31:0]id_reg1,//源操作数1
	input wire [31:0]id_reg2,//源操作数2
	input wire [4:0]id_wd,//写入目的寄存器地址
	input id_wreg,//标志是否要写入
	
	//跳转指令
	input [31:0]id_cur_addr,
	
	//全部指令
	input wire[31:0] id_inst,
	
	//传给执行阶段的信息
	output reg [3:0]ex_aluop,
	output reg [2:0]ex_alusel,
	output reg [31:0]ex_reg1,
	output reg [31:0]ex_reg2,
	output reg [4:0]ex_wd,
	output reg ex_wreg,
	
	output reg [31:0]ex_cur_addr,
	
	output reg [31:0]ex_inst//全部指令
    );

	always @ (posedge clk) begin
		if (rst==`RstEnable) begin
			ex_aluop<=4'b0000;
			ex_alusel<=3'b000;
			ex_reg1<=32'h00000000;
			ex_reg2<=32'h00000000;
			ex_wd<=5'b00000;
			ex_wreg<=`WriteDisable;
			
			ex_cur_addr<=32'h0;
			
			ex_inst<=32'h00000000;
		end
		else begin		
			ex_aluop<=id_aluop;
			ex_alusel<=id_alusel;
			ex_reg1<=id_reg1;
			ex_reg2<=id_reg2;
			ex_wd<=id_wd;
			ex_wreg<=id_wreg;
			
			ex_cur_addr<=id_cur_addr;
			
			ex_inst<=id_inst;
		end
	end

endmodule
