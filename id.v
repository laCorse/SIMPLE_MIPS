`timescale 1ns / 1ps
//2.1.����׶�

`include "defines.v"
//���ڽ�ȡ����ָ��չ����з�
//����߼�
//
module id(
	input rst,
	
	input wire[31:0]pc_i,//����ȡָ�׶εĵ�ַ
	input wire[31:0]inst_i,//����ȡָ�׶ε�ָ��
	
	//����regfile������
	input wire[31:0] reg1_data_i,
	input wire[31:0] reg2_data_i,
	
	//�������ð�յ���·
	input ex_write,//����ִ�н׶ε���·
	input wire [31:0]ex_data,
	input wire [4:0]ex_addr,
	
	input mem_write,//����ִ�н׶ε���·
	input wire [31:0]mem_data,
	input wire [4:0]mem_addr,
	
	//�͵�ALU���������
	output reg reg1_read_o,//�Ĵ����ѵĵ�һ�����Ĵ����˿ڵĶ�ʹ���ź�
	output reg reg2_read_o,//�Ĵ����ѵĵڶ������Ĵ����˿ڵĶ�ʹ���ź�
	output reg[4:0] reg1_addr_o,//�Ĵ������еĵ�һ�����Ĵ����˿ڵĶ���ַ
	output reg[4:0] reg2_addr_o,//�Ĵ������еĵڶ������Ĵ����˿ڵĶ���ַ
	
	//��������õ�������
	output reg[3:0] aluop_o,//����׶ε�ָ��Ҫ���е������������
	output reg[2:0] alusel_o,//����׶ε�ָ��Ҫ���е����������
	output reg[31:0] reg1_o,//����׶ε�ָ��Ҫ���е������Դ������1
	output reg[31:0] reg2_o,//����׶ε�ָ��Ҫ���е������Դ������2
	
	//���ڴ���ȫ����ȡ����ָ��
	output wire[31:0] inst_o,
	
	//ת����ת��ָ��
	output reg jump_reg,//�ж��Ƿ���ת
	output reg [31:0]jump_addr,//�ж���ת��PCֵ
	output reg [31:0]cur_addr,//Ҫ���浽$31��rt�ĵ�ַ
	
	//д�ؼĴ�����
	output reg[4:0] wd_o,//����׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ
	output reg wreg_o//����׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���
	
	
    );
	 
	 wire [5:0]op=inst_i[31:26];
	 wire [4:0]shamt=inst_i[10:6];
	 wire [5:0]func=inst_i[5:0];
	 
	 //wire [15:0]imm_data=inst_i[15:0];
	 wire [31:0]pc_new=pc_i+4;
	 wire [31:0]imm_4times={{14{inst_i[15]}},inst_i[15:0],2'b00};
	 
	 
	 //����ָ����Ҫִ�е�������
	 reg [31:0]imm;
	 
	//����ȫ����ָ��
	assign inst_o=inst_i;
	 
	/**********************��ָ���������********************/
	/*
		���ܣ���ָ���������
		case(op)ͨ����op��ʶ������ж�ָ��
		r:31:26ָʾ��OP��25��21rs��20��16rt��15��11rd��10��6shamt��5��0func
		i:31:26ָ����OP��25��21rs��20��16rt��15��0����������ָ���е�16λ�������޷�����չΪ32λ��Ȼ����rs��ֵ�����߼������㣬���浽rt��
			i�ʹ洢��:31:26OP��25��21rs��20��16rt��15��0offset��
	*/
	always@(*) begin//1
		if(rst==`RstEnable) begin
			aluop_o<=4'b0000;
			alusel_o<=3'b000;
			wd_o<=5'b00000;
			wreg_o<=`WriteDisable;
			reg1_read_o<=1'b0;
			reg2_read_o<=1'b0;
			reg1_addr_o<=5'b00000;
			reg2_addr_o<=5'b00000;
			imm<=32'h0;
			jump_reg<=1'b0;
			jump_addr<=32'h0;
			cur_addr<=32'h0;
		end
		else begin//2
			aluop_o<=4'b0000;
			alusel_o<=3'b000;
			wd_o<=inst_i[15:11];//Ŀ��Ĵ���
			wreg_o<=`WriteDisable;
			reg1_read_o<=1'b0;
			reg2_read_o<=1'b0;
			reg1_addr_o<=inst_i[25:21];//rs
			reg2_addr_o<=inst_i[20:16];//rt
			imm<=32'h0;
			jump_reg<=1'b0;
			jump_addr<=32'h0;
			cur_addr<=32'h0;
			case(op)//3
				`EXE_SPECIAL_INST: begin//R��ָ��
					case(shamt)
						5'b00000:begin
							case(func)
								`EXE_ADD:begin
									wreg_o<=`WriteEnable;
									aluop_o<=`EXE_ADD_OP;
									alusel_o<=`EXE_RES_ARITHMETIC;
									reg1_read_o<=1'b1;
									reg2_read_o<=1'b1;
								end
								`EXE_SUB:begin
									wreg_o<=`WriteEnable;
									aluop_o<=`EXE_SUB_OP;
									alusel_o<=`EXE_RES_ARITHMETIC;
									reg1_read_o<=1'b1;
									reg2_read_o<=1'b1;
								end
								`EXE_SLTU: begin
									wreg_o<=`WriteEnable;
									aluop_o<=`EXE_SLTU_OP;
									alusel_o<=`EXE_RES_ARITHMETIC;
									reg1_read_o<=1'b1;
									reg2_read_o<=1'b1;
								end
								`EXE_OR:begin
                           wreg_o <= `WriteEnable;
                           aluop_o <= `EXE_OR_OP;
                           alusel_o <= `EXE_RES_LOGIC;
                           reg1_read_o <= 1'b1;
                           reg2_read_o <= 1'b1;
                        end
                        `EXE_AND:begin
                           wreg_o <= `WriteEnable;
                           aluop_o <= `EXE_AND_OP;
                           alusel_o <= `EXE_RES_LOGIC;
                           reg1_read_o <= 1'b1;
                           reg2_read_o <= 1'b1;
                        end
                        `EXE_XOR:begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `EXE_XOR_OP;
                            alusel_o <= `EXE_RES_LOGIC;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                        end
                        `EXE_NOR:begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `EXE_NOR_OP;
                            alusel_o <= `EXE_RES_LOGIC;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                        end
                        `EXE_SLLV:begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `EXE_SLLV_OP;
                            alusel_o <= `EXE_RES_SHIFT;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
								end
								`EXE_LUI:begin
									wreg_o<=`WriteEnable;
									aluop_o<=`EXE_LUI_OP;
									alusel_o<=`EXE_RES_LOGIC;
									reg1_read_o<=1'b1;
									reg2_read_o<=1'b0;
									imm<={inst_i[15:0],16'h0};
									wd_o<=inst_i[20:16];
								end
								`EXE_JR:begin
									wreg_o<=`WriteDisable;
									aluop_o<=`EXE_JR_OP;
									alusel_o<=`EXE_RES_JUMP_BRANCH;
									reg1_read_o<=1'b1;
									reg2_read_o<=1'b0;
									cur_addr<=32'h0;
									jump_addr<=reg1_o;
									jump_reg<=1'b1;
								end
							endcase//func
						end
					endcase//shamt
				end
				//I��ָ��
				`EXE_ADDI:begin
					wreg_o<=`WriteEnable;
					aluop_o<=`EXE_ADDI_OP;
					alusel_o<=`EXE_RES_ARITHMETIC;
					reg1_read_o<=1'b1;
					reg2_read_o<=1'b0;
					imm<={{16{inst_i[15]}},inst_i[15:0]};
					wd_o<=inst_i[20:16];
				end
				`EXE_SLTIU:begin
					wreg_o<=`WriteEnable;
					aluop_o<=`EXE_SLTIU_OP;
					alusel_o<=`EXE_RES_ARITHMETIC;
					reg1_read_o<=1'b1;
					reg2_read_o<=1'b0;
					imm<={{16{inst_i[15]}},inst_i[15:0]};
					wd_o<=inst_i[20:16];
				end
				`EXE_ANDI:begin
					wreg_o<=`WriteEnable;
					aluop_o<=`EXE_AND_OP;
					alusel_o<=`EXE_RES_LOGIC;
					reg1_read_o<=1'b1;
					reg2_read_o<=1'b0;
					imm<={16'h0, inst_i[15:0]};
					wd_o<=inst_i[20:16];
				end
				`EXE_XORI:begin
					wreg_o<=`WriteEnable;
					aluop_o<=`EXE_XOR_OP;
					alusel_o<=`EXE_RES_LOGIC;
					reg1_read_o<=1'b1;
					reg2_read_o<=1'b0;	  	
					imm<={16'h0, inst_i[15:0]};
					wd_o<=inst_i[20:16];
				end
				
				
				//`EXE_LW_OP��`EXE_SW_OP����Ϊ1000
				`EXE_LW:begin//������ȡ���ݷŵ��Ĵ����ѣ�����WriteEnable
					wreg_o<=`WriteEnable;//Mem(R[rs]+offset)->rt
					aluop_o<=`EXE_LW_OP;
					alusel_o<=`EXE_RES_LOAD_STORE;
					reg1_read_o<= 1'b1;
					reg2_read_o<= 1'b0;
					wd_o<=inst_i[20:16];
				end
				`EXE_SW:begin//����д�����棬����WriteDisable
					wreg_o<=`WriteDisable;//Reg[rt]->Mem(Reg[rs]+offset)
					aluop_o<=`EXE_SW_OP;
					alusel_o<=`EXE_RES_LOAD_STORE;
					reg1_read_o<=1'b1;
					reg2_read_o<=1'b1;
				end
				
				//I�ͺ�J����תָ��
				`EXE_BEQ:begin
					wreg_o<=`WriteDisable;
					aluop_o<=`EXE_BEQ_OP;
					alusel_o<=`EXE_RES_JUMP_BRANCH;
					reg1_read_o<=1'b1;
					reg2_read_o<=1'b1;
					cur_addr<=32'h0;
					if(reg1_o==reg2_o)begin
						jump_addr<=pc_new+imm_4times;
						jump_reg<=1'b1;
					end
				end
				
				`EXE_BNE:begin
					wreg_o<=`WriteDisable;
					aluop_o<=`EXE_BNE_OP;
					alusel_o<=`EXE_RES_JUMP_BRANCH;
					reg1_read_o<=1'b1;
					reg2_read_o<=1'b1;
					cur_addr<=32'h0;
					if(reg1_o!==reg2_o)begin
						jump_addr<=pc_new+imm_4times;//==pc_i+4+offset*4
						jump_reg<=1'b1;
					end
				end
				
				`EXE_J:begin
					wreg_o<=`WriteDisable;
					aluop_o<=`EXE_J_OP;
					alusel_o<=`EXE_RES_JUMP_BRANCH;
					reg1_read_o<=1'b0;
					reg2_read_o<=1'b0;
					cur_addr<=32'h0;
					jump_addr<={pc_new[31:28],inst_i[25:0],2'b00};
					jump_reg<=1'b1;
				end
				
				`EXE_JAL:begin
					wreg_o<=`WriteEnable;
					aluop_o<=`EXE_JAL_OP;
					alusel_o<=`EXE_RES_JUMP_BRANCH;
					reg1_read_o<=1'b0;
					reg2_read_o<=1'b0;
					cur_addr<=pc_i+4;
					jump_addr<={pc_new[31:28],inst_i[25:0],2'b00};
					jump_reg<=1'b1;
					wd_o<=`reg31;
				end

			endcase//3
		end//2
	end//1


	/**********************ȷ�����������Դ������1********************/
	always@(*) begin
		if(rst==`RstEnable) begin
			reg1_o<=32'h00000000;
		end
		else if(reg1_read_o==1'b1) begin//���ʹ���ź�reg1_read_oΪ1���ͰѶ�����reg1_data_i��ΪԴ������1
			//��������������Ϊ�˽������ð��//
			if((ex_write==`WriteEnable)&&(ex_addr==reg1_addr_o)) begin
				reg1_o<=ex_data;
			end
			else if((mem_write==`WriteEnable)&&(mem_addr==reg1_addr_o)) begin
				reg1_o<=mem_data;
			end
			else reg1_o<=reg1_data_i;
		end
		else if(reg1_read_o==1'b0) begin//ʹ���ź�Ϊ0���Ͱ���������ΪԴ������
			reg1_o<=imm;
		end
		else begin
			reg1_o<=32'h00000000;
		end
	end
	
	/**********************ȷ�����������Դ������2********************/
	always@(*) begin
		if(rst==`RstEnable) begin
			reg2_o<=32'h00000000;
		end
		else if(reg2_read_o==1'b1) begin
			//��������������Ϊ�˽������ð��//
			if((ex_write==`WriteEnable)&&(ex_addr==reg2_addr_o)) begin
				reg2_o<=ex_data;
			end
			else if((mem_write==`WriteEnable)&&(mem_addr==reg2_addr_o)) begin
				reg2_o<=mem_data;
			end
			else reg2_o<=reg2_data_i;
		end
		else if(reg2_read_o==1'b0) begin
			reg2_o<=imm;
		end
		
		else begin
			reg2_o<=32'h00000000;
		end
	end

endmodule