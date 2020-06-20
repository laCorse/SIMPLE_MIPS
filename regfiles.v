`timescale 1ns / 1ps

`include "defines.v"

module regfiles(
input clk,
input rst,

input we,//写使能
input [4:0]W_Addr,
input [31:0]W_Data,

input reA,
input [4:0]R_Addr_A,
input reB,
input [4:0]R_Addr_B,

output reg[31:0] R_Data_A,
output reg[31:0] R_Data_B
    );

	 //读为组合逻辑电路的原因：便于传递给译码阶段

	reg [31:0] REG_Files[0:31];


	/****************write******************/
	integer i;//无法直接对二维的REG_Files进行赋初值操作,因此常采用for循环迭代
	always@(posedge clk)begin
		if(rst==`RstEnable)begin
			for(i=0;i<=31;i=i+1)
				REG_Files[i]<=32'b0;
		end
		else begin
			if((we==`WriteEnable)&&(W_Addr!=5'h0))begin
				REG_Files[W_Addr]<=W_Data;
			end
		end
	end
	
	
	/****************read 1******************/
	
	always@(*)begin
		if(rst==`RstEnable) begin
			R_Data_A<=32'h0;
		end
		else if(R_Addr_A==5'h0) begin
			R_Data_A<=32'h0;
		end
		else if((R_Addr_A==W_Addr)&&(we==`WriteEnable)&&(reA==`ReadEnable)) begin
			R_Data_A<=W_Data;
		end
		else if(reA==`ReadEnable) begin
			R_Data_A<=REG_Files[R_Addr_A];
		end
		else begin
			R_Data_A<=32'h0;
		end
	end
	
	
	/****************read 2******************/
	always@(*)begin
		if(rst==`RstEnable) begin
			R_Data_B<=32'h0;
		end
		else if(R_Addr_B==5'h0) begin
			R_Data_B<=32'h0;
		end
		else if((R_Addr_B==W_Addr)&&(we==`WriteEnable)&&(reB==`ReadEnable)) begin
			R_Data_B<=W_Data;
		end
		else if(reB==`ReadEnable) begin
			R_Data_B<=REG_Files[R_Addr_B];
		end
		else begin
			R_Data_B<=32'h0;
		end
	end
endmodule