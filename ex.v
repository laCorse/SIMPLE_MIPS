`timescale 1ns / 1ps
//3.1.执行阶段

`include "defines.v"

module ex(
	input rst,
	
	//译码阶段送到执行阶段信息
	input wire[3:0] aluop_i,//运算子类型
	input wire[2:0] alusel_i,//运算类型
	input wire[31:0] reg1_i,//源操作数1
	input wire[31:0] reg2_i,//源操作数2
	input wire[4:0] wd_i,//指令执行要写入的目的寄存器
	input wire wreg_i,//是否有要写入的目标寄存器
	
	input [31:0]cur_addr,
	
	input wire[31:0] inst_i,//传入的指令
	
	
	//执行结果
	output reg[4:0] wd_o,//最终写入的目的寄存器地址
	output reg wreg_o,//是否有最终写入的目的寄存器
	output reg[31:0] wdata_o,//要写入的寄存器的值
	output reg of,
	output reg zf,
	
	//为存储准备
	output [3:0] aluop_o,
	output [9:0] mem_addr_o,
	output [31:0] reg2_o//需要存的数据
    );
	 
	 
	reg[31:0] logicout;//保存逻辑运算的结果
	reg[31:0] shiftres;//保存位移运算结果
	reg[31:0] arithmeticres;//保存算数运算结果

	wire of_t;//判断溢出
	wire zf_t;//全0置1
	wire[31:0] reg2_i_mux;//reg2_i的补码
	wire[31:0] reg1_i_not;//reg1_i的取反
	wire[31:0] result_sum;//加法结果
	wire reg1_lt_reg2;//保存两个操作数比较后结果
	 
	 
	 //****************一些wire值的计算******************//
	 
	//如果是减法，就记录补码。加法就是原来的。
	assign reg2_i_mux=(aluop_i==`EXE_SUB_OP)?(~reg2_i)+1 : reg2_i;
	
	//加减法通用
	assign result_sum=reg1_i+reg2_i_mux;
	
	//溢出计算：加法指令、减法指令需要判定溢出：reg1_i为正，reg2_i_mux为正，但两者之和为负数。reg1_i为负，reg2_i_mux为负，但两者之和为正数。
	assign of_t=((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31])||((reg1_i[31] && reg2_i_mux[31])&&(!result_sum[31]));
	
	//有符号版本:assign reg1_lt_reg2=((aluop_i==`EXE_SLT_OP))?((reg1_i[31]&&!reg2_i[31])||(!reg1_i[31]&&!reg2_i[31]&&result_sum[31])||(reg1_i[31]&&reg2_i[31]&&result_sum[31])):(reg1_i<reg2_i);
	assign reg1_lt_reg2=(reg1_i<reg2_i);
	
	//对操作数1逐位取反
	//assign reg1_i_not=~reg1_i;
	
	//全0标志
	assign zf_t=~(wdata_o[0]|wdata_o[1]|wdata_o[3]|wdata_o[4]|wdata_o[5]|wdata_o[6]|wdata_o[7]|wdata_o[8]|wdata_o[9]|wdata_o[10]|wdata_o[11]|wdata_o[12]|wdata_o[13]|wdata_o[14]|wdata_o[15]|wdata_o[16]|wdata_o[17]|wdata_o[18]|wdata_o[19]|wdata_o[20]|wdata_o[21]|wdata_o[22]|wdata_o[23]|wdata_o[24]|wdata_o[25]|wdata_o[26]|wdata_o[27]|wdata_o[28]|wdata_o[29]|wdata_o[30]|wdata_o[31]);
	
	//传递aluop
	assign aluop_o=aluop_i;
	
	//访存地址设计 reg1+offset
	assign mem_addr_o=reg1_i+{{16{inst_i[15]}},inst_i[15:0]};
	
	//传递待存储数据
	assign reg2_o=reg2_i;
	
	/****************依据aluop_i进行ALU运算***************/
	/*逻辑运算*/
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
	
	
	/*加减法和比较运算*/
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
	
	/*移位运算*/
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
	
	
	/****************依据alusel_i的类型不同选择写入结果***********************/
	/*
		是否要写目的寄存器wreg_o、要写的目的寄存器wd_o、要写入的数据wdata_o
	*/
	always@(*) begin
		wd_o<=wd_i;//写入地址传递
		if(((aluop_i==`EXE_ADD_OP)||(aluop_i==`EXE_ADDI_OP)||(aluop_i==`EXE_SUB_OP))&&(of==1'b1)) begin//溢出中止写入
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
	
	
	/****************zf、of的输出******************/
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
