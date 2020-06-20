`timescale 1ns / 1ps
//3.2.ִ�н׶�->�ô�׶�


`include "defines.v"
module ex_mem(
	input clk,
	input rst,
	
	//����ִ�н׶ε���Ϣ
	input wire[4:0] ex_wd,//Ҫд���Ŀ�ļĴ�����ַ
	input wire ex_wreg,//�Ƿ�Ҫд��Ŀ�ļĴ���
	input wire[31:0] ex_wdata,//Ҫд��Ŀ�ļĴ�����ֵ
	input of_i,
	input zf_i,
	
	//���ش洢�����Ϣ
	input wire[3:0] ex_aluop,//ȷ����ȡ
	input wire[9:0] ex_mem_addr,//��ŵ�ַ
	input wire[31:0] ex_reg2,//�������
	
	//������ش洢�����Ϣ
	output reg[3:0] mem_aluop,//ȷ����ȡ
	output reg[9:0] mem_mem_addr,//��ŵ�ַ
	output reg[31:0] mem_reg2,//�������
	
	//�͵��ô�׶ε���Ϣ
	output reg[4:0] mem_wd,//�ô�׶�Ҫд���Ŀ�ļĴ�����ַ
	output reg mem_wreg,//�Ƿ���
	output reg[31:0] mem_wdata,//ֵ
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
