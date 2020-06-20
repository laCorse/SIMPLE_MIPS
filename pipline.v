`timescale 1ns / 1ps

//用来组成流水线数据通路

module pipline(
	input clk,
	input rst,
	
	input [31:0]inst,//从ROM中得到指令
	
	output [9:0]inst_addr,
	
	input [31:0]ram_data,
	output mem_we,
	output [9:0]mem_addr,
	output [31:0]mem_data
    );

//**********************中间临时变量**********************//
	//取指阶段
	// PC
	wire [31:0]pc_;
	// IF/ID
	wire [31:0]id_pc_i;
	wire [31:0]id_inst_i;
	
	
	// 译码阶段
	// regfiles,id
	wire reA;
	wire reB;
	wire [4:0]R_Addr_A;
	wire [4:0]R_Addr_B;
	wire [31:0]R_Data_A;
	wire [31:0]R_Data_B;
	wire [3:0]id_aluop_o;
	wire [2:0]id_alusel_o;
	wire [31:0]id_regA_o;
	wire [31:0]id_regB_o;
	wire [31:0]id_inst_o;
	
	
	wire [4:0]id_wd_o;
	wire id_wreg_o;
	
	wire [3:0]ex_aluop_i;
	wire [2:0]ex_alusel_i;
	wire [31:0]ex_regA_i;
	wire [31:0]ex_regB_i;
	wire [31:0]ex_inst_i;
	wire [4:0]ex_wd_i;
	wire ex_wreg_i;
	
	
	//执行阶段
	wire ex_wreg_o;
	wire[4:0] ex_wd_o;
	wire[31:0] ex_wdata_o;
	wire of_i;
	wire zf_i;
	wire [3:0]ex_aluop_o;
	wire [9:0]ex_mem_addr_o;
	wire [31:0]ex_mem_w_data_o;
	
	wire mem_wreg_i;
	wire [4:0]mem_wd_i;
	wire [31:0]mem_wdata_i;
	wire [3:0]mem_aluop_i;
	wire [9:0]mem_mem_addr_i;
	wire [31:0]mem_mem_w_data_i;
	wire mem_of_i;
	wire mem_zf_i;
	
	//写回阶段
	// mem
	wire [4:0]mem_wd_o;
	wire mem_wreg_o;
	wire [31:0]mem_wdata_o;
	
	wire [9:0]mem_mem_addr_o;
	wire mem_mem_we_o;
	wire [31:0]mem_mem_data_o;
	//wire mem_ce_o;
	 
	// mem_wb
	wire [4:0]wb_wd_i;
	wire wb_wreg_i;
	wire [31:0]wb_wdata_i;
	
//**********************输出到RAM***********************//
	assign inst_addr=pc_[11:2];
	assign mem_we=mem_mem_we_o;
	assign mem_addr=mem_mem_addr_o;
	assign mem_data=mem_mem_data_o;
//**********************跳转指令***********************//
	wire [31:0]jump_addr;
	wire jump_reg;
	wire [31:0]cur_addr;
	wire [31:0]ex_cur_addr;
	
//**********************取指阶段**********************//
	PC PC0(
	//in
	.clk(clk),//下降沿触发
	.rst(rst),
	
	.jump_reg(jump_reg),//判断是否跳转
	.jump_addr(jump_addr),//判断跳转的PC值
	
	//out
	.pc(pc_)
    );
	 

	if_id if_id0(
	//in
	.clk(clk),//下降沿触发
	.rst(rst),
	
	.if_pc(pc_),
	.if_inst(inst),
	//out
	.id_pc(id_pc_i),
	.id_inst(id_inst_i)
    );

//**********************译码阶段**********************//
	
	
	regfiles regfiles0(
	//in
	.clk(clk),
	.rst(rst),
	
	.we(wb_wreg_i),//写使能,来自写回阶段
	.W_Addr(wb_wd_i),
	.W_Data(wb_wdata_i),
	
	.reA(reA),//readen
	.R_Addr_A(R_Addr_A),
	.reB(reB),
	.R_Addr_B(R_Addr_B),
	
	//out
	.R_Data_A(R_Data_A),
	.R_Data_B(R_Data_B)
    );
	 
	 
	id id0(
	//in
	.rst(rst),
	.pc_i(id_pc_i),
	.inst_i(id_inst_i),
	.reg1_data_i(R_Data_A),
	.reg2_data_i(R_Data_B),
	//解决数据冒险的旁路
	.ex_write(ex_wreg_o),//来自执行阶段的旁路
	.ex_data(ex_wdata_o),
	.ex_addr(ex_wd_o),
	
	.mem_write(mem_wreg_o),//来自执行阶段的旁路
	.mem_data(mem_wdata_o),
	.mem_addr(mem_wd_o),
	//out
	.reg1_read_o(reA),
	.reg2_read_o(reB),
	.reg1_addr_o(R_Addr_A),
	.reg2_addr_o(R_Addr_B),
	.aluop_o(id_aluop_o),
	.alusel_o(id_alusel_o),
	.reg1_o(id_regA_o),
	.reg2_o(id_regB_o),
	.inst_o(id_inst_o),
	.jump_reg(jump_reg),
	.jump_addr(jump_addr),
	.cur_addr(cur_addr),
	.wd_o(id_wd_o),
	.wreg_o(id_wreg_o)
    );
	 
	 id_ex id_ex0(
	.clk(clk),
	.rst(rst),
	.id_aluop(id_aluop_o),
	.id_alusel(id_alusel_o),
	.id_reg1(id_regA_o),
	.id_reg2(id_regB_o),
	.id_wd(id_wd_o),
	.id_wreg(id_wreg_o),
	.id_cur_addr(cur_addr),
	.id_inst(id_inst_o),
	//out
	.ex_aluop(ex_aluop_i),
	.ex_alusel(ex_alusel_i),
	.ex_reg1(ex_regA_i),
	.ex_reg2(ex_regB_i),
	.ex_wd(ex_wd_i),
	.ex_wreg(ex_wreg_i),
	.ex_cur_addr(ex_cur_addr),
	.ex_inst(ex_inst_i)
	
	);
	 
//***********************执行阶段***********************//
	
	
	ex ex0(
	.rst(rst),
	//in
	.aluop_i(ex_aluop_i),
	.alusel_i(ex_alusel_i),
	.reg1_i(ex_regA_i),
	.reg2_i(ex_regB_i),
	.wd_i(ex_wd_i),
	.wreg_i(ex_wreg_i),
	.cur_addr(ex_cur_addr),
	.inst_i(ex_inst_i),
	//out
	.wd_o(ex_wd_o),
	.wreg_o(ex_wreg_o),
	.wdata_o(ex_wdata_o),
	.of(of_i),
	.zf(zf_i),
	.aluop_o(ex_aluop_o),
	.mem_addr_o(ex_mem_addr_o),
	.reg2_o(ex_mem_w_data_o)
	);
	
	ex_mem ex_mem0(
	.clk(clk),
	.rst(rst),
	
	.ex_wd(ex_wd_o),//要写入的目的寄存器地址
	.ex_wreg(ex_wreg_o),//是否要写入目的寄存器
	.ex_wdata(ex_wdata_o),//要写入目的寄存器的值
	.of_i(of_i),
	.zf_i(zf_i),
	//加载存储相关信息
	.ex_aluop(ex_aluop_o),//确定存取
	.ex_mem_addr(ex_mem_addr_o),//存放地址
	.ex_reg2(ex_mem_w_data_o),//存放数据
	
	//out
	.mem_aluop(mem_aluop_i),//确定存取
	.mem_mem_addr(mem_mem_addr_i),//存放地址
	.mem_reg2(mem_mem_w_data_i),//存放数据
	//送到访存阶段的信息
	.mem_wd(mem_wd_i),//访存阶段要写入的目的寄存器地址
	.mem_wreg(mem_wreg_i),//是否有
	.mem_wdata(mem_wdata_i),//值
	.of_o(mem_of_i),
	.zf_o(mem_zf_i)
    );
	
	
//***********************写回阶段***********************//
	
	mem mem0(
		.rst(rst),
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),//是否写回
		.wdata_i(mem_wdata_i),
		.aluop_i(mem_aluop_i),
		.mem_addr_i(mem_mem_addr_i),
		.reg2_i(mem_mem_w_data_i),
		.mem_data_i(ram_data),
		
		//写回
		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o),
		
		//存储器存写
		.mem_addr_o(mem_mem_addr_o),
		.mem_we_o(mem_mem_we_o),//是否写入存储器
		.mem_data_o(mem_mem_data_o)
    );
	
	
	
	
	mem_wb mem_wb0(
		.clk(clk),
		.rst(rst),
		
		//访存阶段传递来的信息
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
		//out
		//传给写回阶段的信息
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i)
    );



endmodule
