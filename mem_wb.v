`timescale 1ns / 1ps
//4.2.�ô�׶�->д�ؽ׶�

`include "defines.v"

module mem_wb(
	input clk,
	input rst,
	
	//�ô�׶δ���������Ϣ
	input wire[4:0] mem_wd,
	input wire mem_wreg,
	input wire[31:0] mem_wdata,
	
	//����д�ؽ׶ε���Ϣ
	output reg[4:0] wb_wd,
	output reg wb_wreg,
	output reg[31:0] wb_wdata
    );
	 always@(posedge clk)begin
		if(rst==`RstEnable)begin
			wb_wd<=5'b0;//д�ص�ַ
			wb_wreg<=`WriteDisable;//�Ƿ�д
			wb_wdata<=32'h0;//д������
		end
		else begin
			wb_wd<=mem_wd;//д�ص�ַ
			wb_wreg<=mem_wreg;//�Ƿ�д
			wb_wdata<=mem_wdata;//д������
		end
	 end
endmodule
