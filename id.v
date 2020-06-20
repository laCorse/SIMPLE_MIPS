`timescale 1ns / 1ps
//2.1.译码阶段

`include "defines.v"
//用于将取来的指令按照功能切分
//组合逻辑
//
module id(
	input rst,
	
	input wire[31:0]pc_i,//来自取指阶段的地址
	input wire[31:0]inst_i,//来自取指阶段的指令
	
	//来自regfile的数据
	input wire[31:0] reg1_data_i,
	input wire[31:0] reg2_data_i,
	
	//解决数据冒险的旁路
	input ex_write,//来自执行阶段的旁路
	input wire [31:0]ex_data,
	input wire [4:0]ex_addr,
	
	input mem_write,//来自执行阶段的旁路
	input wire [31:0]mem_data,
	input wire [4:0]mem_addr,
	
	//送到ALU运算的数据
	output reg reg1_read_o,//寄存器堆的第一个读寄存器端口的读使能信号
	output reg reg2_read_o,//寄存器堆的第二个读寄存器端口的读使能信号
	output reg[4:0] reg1_addr_o,//寄存器堆中的第一个读寄存器端口的读地址
	output reg[4:0] reg2_addr_o,//寄存器堆中的第二个读寄存器端口的读地址
	
	//译码分析得到的类型
	output reg[3:0] aluop_o,//译码阶段的指令要进行的运算的子类型
	output reg[2:0] alusel_o,//译码阶段的指令要进行的运算的类型
	output reg[31:0] reg1_o,//译码阶段的指令要进行的运算的源操作数1
	output reg[31:0] reg2_o,//译码阶段的指令要进行的运算的源操作数2
	
	//便于传递全部的取来的指令
	output wire[31:0] inst_o,
	
	//转移跳转类指令
	output reg jump_reg,//判断是否跳转
	output reg [31:0]jump_addr,//判断跳转的PC值
	output reg [31:0]cur_addr,//要保存到$31或rt的地址
	
	//写回寄存器堆
	output reg[4:0] wd_o,//译码阶段的指令要写入的目的寄存器地址
	output reg wreg_o//译码阶段的指令是否有要写入的目的寄存器
	
	
    );
	 
	 wire [5:0]op=inst_i[31:26];
	 wire [4:0]shamt=inst_i[10:6];
	 wire [5:0]func=inst_i[5:0];
	 
	 //wire [15:0]imm_data=inst_i[15:0];
	 wire [31:0]pc_new=pc_i+4;
	 wire [31:0]imm_4times={{14{inst_i[15]}},inst_i[15:0],2'b00};
	 
	 
	 //保存指令需要执行的立即数
	 reg [31:0]imm;
	 
	//传递全部的指令
	assign inst_o=inst_i;
	 
	/**********************对指令进行译码********************/
	/*
		功能：对指令进行译码
		case(op)通过对op的识别初步判断指令
		r:31:26指示码OP，25：21rs，20：16rt，15：11rd，10：6shamt，5：0func
		i:31:26指令码OP，25：21rs，20：16rt，15：0立即数。将指令中的16位立即数无符号拓展为32位，然后与rs的值进行逻辑或运算，保存到rt中
			i型存储类:31:26OP，25：21rs，20：16rt，15：0offset。
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
			wd_o<=inst_i[15:11];//目标寄存器
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
				`EXE_SPECIAL_INST: begin//R型指令
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
				//I型指令
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
				
				
				//`EXE_LW_OP和`EXE_SW_OP都令为1000
				`EXE_LW:begin//从主存取数据放到寄存器堆，所以WriteEnable
					wreg_o<=`WriteEnable;//Mem(R[rs]+offset)->rt
					aluop_o<=`EXE_LW_OP;
					alusel_o<=`EXE_RES_LOAD_STORE;
					reg1_read_o<= 1'b1;
					reg2_read_o<= 1'b0;
					wd_o<=inst_i[20:16];
				end
				`EXE_SW:begin//数据写入主存，所以WriteDisable
					wreg_o<=`WriteDisable;//Reg[rt]->Mem(Reg[rs]+offset)
					aluop_o<=`EXE_SW_OP;
					alusel_o<=`EXE_RES_LOAD_STORE;
					reg1_read_o<=1'b1;
					reg2_read_o<=1'b1;
				end
				
				//I型和J型跳转指令
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


	/**********************确定进行运算的源操作数1********************/
	always@(*) begin
		if(rst==`RstEnable) begin
			reg1_o<=32'h00000000;
		end
		else if(reg1_read_o==1'b1) begin//如果使能信号reg1_read_o为1，就把读到的reg1_data_i作为源操作数1
			//！！！！这里是为了解决数据冒险//
			if((ex_write==`WriteEnable)&&(ex_addr==reg1_addr_o)) begin
				reg1_o<=ex_data;
			end
			else if((mem_write==`WriteEnable)&&(mem_addr==reg1_addr_o)) begin
				reg1_o<=mem_data;
			end
			else reg1_o<=reg1_data_i;
		end
		else if(reg1_read_o==1'b0) begin//使能信号为0，就把立即数作为源操作数
			reg1_o<=imm;
		end
		else begin
			reg1_o<=32'h00000000;
		end
	end
	
	/**********************确定进行运算的源操作数2********************/
	always@(*) begin
		if(rst==`RstEnable) begin
			reg2_o<=32'h00000000;
		end
		else if(reg2_read_o==1'b1) begin
			//！！！！这里是为了解决数据冒险//
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