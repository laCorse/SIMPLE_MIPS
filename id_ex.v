`timescale 1ns / 1ps
//2.2.����׶�->����׶�

`include "defines.v"


module id_ex(
	input clk,
	input rst,
	
	//����׶δ���������Ϣ
	input wire [3:0]id_aluop,//����������
	input wire [2:0]id_alusel,//��������
	input wire [31:0]id_reg1,//Դ������1
	input wire [31:0]id_reg2,//Դ������2
	input wire [4:0]id_wd,//д��Ŀ�ļĴ�����ַ
	input id_wreg,//��־�Ƿ�Ҫд��
	
	//��תָ��
	input [31:0]id_cur_addr,
	
	//ȫ��ָ��
	input wire[31:0] id_inst,
	
	//����ִ�н׶ε���Ϣ
	output reg [3:0]ex_aluop,
	output reg [2:0]ex_alusel,
	output reg [31:0]ex_reg1,
	output reg [31:0]ex_reg2,
	output reg [4:0]ex_wd,
	output reg ex_wreg,
	
	output reg [31:0]ex_cur_addr,
	
	output reg [31:0]ex_inst//ȫ��ָ��
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
