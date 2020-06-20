`timescale 1ns / 1ps
//4.1.�ô�׶�

`include "defines.v"

module mem(
		input rst,
		input wire[4:0] wd_i,
		input wire wreg_i,//�Ƿ�д��
		input wire[31:0] wdata_i,
		input wire[3:0] aluop_i,
		input wire[31:0] reg2_i,//д������
		input wire[9:0] mem_addr_i,//�����ݺͶ������ݹ���һ����ַ
		input wire[31:0] mem_data_i,//��������
		
		//д��
		output reg[4:0] wd_o,
		output reg wreg_o,
		output reg[31:0] wdata_o,
		
		//�洢����д
		output reg[9:0] mem_addr_o,
		output reg mem_we_o,//�Ƿ�д��洢��
		output reg[31:0] mem_data_o
    );
	
	
	//reg mem_we;
	
	//assign mem_we_o=mem_we;
	
	always@(*)begin
		if(rst==`RstEnable)begin
			wd_o<=5'b0;
			wreg_o<=`WriteDisable;
			wdata_o<=32'h0;
			mem_addr_o<=32'h0;
			mem_we_o<=`WriteDisable;
			mem_data_o<=32'h0;
		end//if
		else begin
			case(aluop_i)
			`EXE_LW_OP:begin
					wd_o <= wd_i;
					wreg_o<=wreg_i;
					wdata_o <= mem_data_i;
					mem_addr_o <= mem_addr_i;
					mem_we_o<= 1'b0;
					mem_data_o<=32'h0;
			end
			`EXE_SW_OP:begin
					wd_o <= wd_i;
					wreg_o<=wreg_i;
					wdata_o<=wdata_i;
					mem_addr_o <= mem_addr_i;
					mem_we_o<= 1'b1;
					mem_data_o <= reg2_i;
			end
			default:begin
					wd_o <= wd_i;
					wreg_o<=wreg_i;
					wdata_o<=wdata_i;//д��
					mem_we_o<=`WriteDisable;
					mem_addr_o<=10'h0;
					mem_data_o<=32'h0;
			end
			endcase//case
			
		end//else
	
	end//always
	


endmodule
