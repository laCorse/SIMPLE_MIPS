`timescale 1ns / 1ps

`include "defines.v"

module PC(
	input clk,
	input rst,
	
	//ת����ת��ָ��,�����봦��ȡ
	input jump_reg,//�ж��Ƿ���ת
	input [31:0]jump_addr,//�ж���ת��PCֵ
	
	output reg[31:0] pc
    );
	
	wire [31:0]pc_new;
	assign pc_new=pc+4;
	
	always@(posedge clk) begin
		if(rst==`RstEnable) begin
			pc<=32'h00000000;
		end
		else if(jump_reg==1'b1)begin//��ת
			pc<=jump_addr;
		end
		else begin
			pc<=pc_new;
		end
	end

endmodule
