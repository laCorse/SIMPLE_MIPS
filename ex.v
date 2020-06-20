`timescale 1ns / 1ps
//3.1.ִ�н׶�

`include "defines.v"

module ex(
	input rst,
	
	//����׶��͵�ִ�н׶���Ϣ
	input wire[3:0] aluop_i,//����������
	input wire[2:0] alusel_i,//��������
	input wire[31:0] reg1_i,//Դ������1
	input wire[31:0] reg2_i,//Դ������2
	input wire[4:0] wd_i,//ָ��ִ��Ҫд���Ŀ�ļĴ���
	input wire wreg_i,//�Ƿ���Ҫд���Ŀ��Ĵ���
	
	input [31:0]cur_addr,
	
	input wire[31:0] inst_i,//�����ָ��
	
	
	//ִ�н��
	output reg[4:0] wd_o,//����д���Ŀ�ļĴ�����ַ
	output reg wreg_o,//�Ƿ�������д���Ŀ�ļĴ���
	output reg[31:0] wdata_o,//Ҫд��ļĴ�����ֵ
	output reg of,
	output reg zf,
	
	//Ϊ�洢׼��
	output [3:0] aluop_o,
	output [9:0] mem_addr_o,
	output [31:0] reg2_o//��Ҫ�������
    );
	 
	 
	reg[31:0] logicout;//�����߼�����Ľ��
	reg[31:0] shiftres;//����λ��������
	reg[31:0] arithmeticres;//��������������

	wire of_t;//�ж����
	wire zf_t;//ȫ0��1
	wire[31:0] reg2_i_mux;//reg2_i�Ĳ���
	wire[31:0] reg1_i_not;//reg1_i��ȡ��
	wire[31:0] result_sum;//�ӷ����
	wire reg1_lt_reg2;//���������������ȽϺ���
	 
	 
	 //****************һЩwireֵ�ļ���******************//
	 
	//����Ǽ������ͼ�¼���롣�ӷ�����ԭ���ġ�
	assign reg2_i_mux=(aluop_i==`EXE_SUB_OP)?(~reg2_i)+1 : reg2_i;
	
	//�Ӽ���ͨ��
	assign result_sum=reg1_i+reg2_i_mux;
	
	//������㣺�ӷ�ָ�����ָ����Ҫ�ж������reg1_iΪ����reg2_i_muxΪ����������֮��Ϊ������reg1_iΪ����reg2_i_muxΪ����������֮��Ϊ������
	assign of_t=((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31])||((reg1_i[31] && reg2_i_mux[31])&&(!result_sum[31]));
	
	//�з��Ű汾:assign reg1_lt_reg2=((aluop_i==`EXE_SLT_OP))?((reg1_i[31]&&!reg2_i[31])||(!reg1_i[31]&&!reg2_i[31]&&result_sum[31])||(reg1_i[31]&&reg2_i[31]&&result_sum[31])):(reg1_i<reg2_i);
	assign reg1_lt_reg2=(reg1_i<reg2_i);
	
	//�Բ�����1��λȡ��
	//assign reg1_i_not=~reg1_i;
	
	//ȫ0��־
	assign zf_t=~(wdata_o[0]|wdata_o[1]|wdata_o[3]|wdata_o[4]|wdata_o[5]|wdata_o[6]|wdata_o[7]|wdata_o[8]|wdata_o[9]|wdata_o[10]|wdata_o[11]|wdata_o[12]|wdata_o[13]|wdata_o[14]|wdata_o[15]|wdata_o[16]|wdata_o[17]|wdata_o[18]|wdata_o[19]|wdata_o[20]|wdata_o[21]|wdata_o[22]|wdata_o[23]|wdata_o[24]|wdata_o[25]|wdata_o[26]|wdata_o[27]|wdata_o[28]|wdata_o[29]|wdata_o[30]|wdata_o[31]);
	
	//����aluop
	assign aluop_o=aluop_i;
	
	//�ô��ַ��� reg1+offset
	assign mem_addr_o=reg1_i+{{16{inst_i[15]}},inst_i[15:0]};
	
	//���ݴ��洢����
	assign reg2_o=reg2_i;
	
	/****************����aluop_i����ALU����***************/
	/*�߼�����*/
	always@(*) begin
		if(rst==`RstEnable) begin
			logicout<=32'h0;
		end
		else begin
			case(aluop_i)
				`EXE_OR_OP:begin
					logicout<=reg1_i|reg2_i;
				end
				`EXE_AND_OP,`EXE_ANDI_OP:begin
					logicout<=reg1_i&reg2_i;
				end
				`EXE_XOR_OP,`EXE_XORI_OP:begin
					logicout<=reg1_i^reg2_i;
				end
				`EXE_NOR_OP:begin
					logicout<=~(reg1_i|reg2_i);
				end
				`EXE_LUI_OP:begin
					logicout<=reg2_i;
				end
				default: begin
					logicout<=32'h0;
				end
			endcase
		end
	end
	
	
	/*�Ӽ����ͱȽ�����*/
	always@(*) begin
		if(rst==`RstEnable)begin
			arithmeticres<=32'h0;
		end
		else begin
			case(aluop_i)
				`EXE_SLTU_OP,`EXE_SLTIU_OP:begin
					arithmeticres<=reg1_lt_reg2;
				end
				`EXE_ADD_OP,`EXE_ADDI_OP:begin
					arithmeticres<=result_sum;
				end
				`EXE_SUB_OP:begin
					arithmeticres<=result_sum;
				end
				default:begin
					arithmeticres<=32'h0;
				end
			endcase
		end
	end
	
	/*��λ����*/
	always@(*) begin
		if(rst==`RstEnable)begin
			shiftres<=32'h0;
		end
		else begin
			case(aluop_i)
				`EXE_SLLV_OP:begin
					shiftres<=(reg2_i<<reg1_i);
				end
				default:begin
					shiftres<=32'h0;
				end
			endcase
		end
	end
	
	
	/****************����alusel_i�����Ͳ�ͬѡ��д����***********************/
	/*
		�Ƿ�ҪдĿ�ļĴ���wreg_o��Ҫд��Ŀ�ļĴ���wd_o��Ҫд�������wdata_o
	*/
	always@(*) begin
		wd_o<=wd_i;//д���ַ����
		if(((aluop_i==`EXE_ADD_OP)||(aluop_i==`EXE_ADDI_OP)||(aluop_i==`EXE_SUB_OP))&&(of==1'b1)) begin//�����ֹд��
			wreg_o<=`WriteDisable;
		end
		else begin
			wreg_o<=wreg_i;
		end
		case(alusel_i)
			`EXE_RES_LOGIC: begin
				wdata_o<=logicout;
			end
			`EXE_RES_ARITHMETIC: begin
				wdata_o<=arithmeticres;
			end
			`EXE_RES_SHIFT: begin
				wdata_o<=shiftres;
			end
			`EXE_RES_JUMP_BRANCH:begin
				wdata_o<=cur_addr;
			end
			default: begin
				wdata_o<=32'h0;
			end
		endcase
	end
	
	
	/****************zf��of�����******************/
	always@(*) begin
		if(rst==`RstEnable)begin
			zf<=0;
			of<=0;
		end
		else begin
			zf<=zf_t;
			of<=of_t;
		end
	end

endmodule
