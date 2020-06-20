`timescale 1ns / 1ps

`include "defines.v"

module PC(
	input clk,
	input rst,
	
	//转移跳转类指令,从译码处获取
	input jump_reg,//判断是否跳转
	input [31:0]jump_addr,//判断跳转的PC值
	
	output reg[31:0] pc
    );
	
	wire [31:0]pc_new;
	assign pc_new=pc+4;
	
	always@(posedge clk) begin
		if(rst==`RstEnable) begin
			pc<=32'h00000000;
		end
		else if(jump_reg==1'b1)begin//跳转
			pc<=jump_addr;
		end
		else begin
			pc<=pc_new;
		end
	end

endmodule
