`timescale 1ns / 1ps

//���������ˮ������ͨ·

module pipline(
	input clk,
	input rst,
	
	input [31:0]inst,//��ROM�еõ�ָ��
	
	output [9:0]inst_addr,
	
	input [31:0]ram_data,
	output mem_we,
	output [9:0]mem_addr,
	output [31:0]mem_data
    );

//**********************�м���ʱ����**********************//
	//ȡָ�׶�
	// PC
	wire [31:0]pc_;
	// IF/ID
	wire [31:0]id_pc_i;
	wire [31:0]id_inst_i;
	
	
	// ����׶�
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
	
	
	//ִ�н׶�
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
	
	//д�ؽ׶�
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
	
//**********************�����RAM***********************//
	assign inst_addr=pc_[11:2];
	assign mem_we=mem_mem_we_o;
	assign mem_addr=mem_mem_addr_o;
	assign mem_data=mem_mem_data_o;
//**********************��תָ��***********************//
	wire [31:0]jump_addr;
	wire jump_reg;
	wire [31:0]cur_addr;
	wire [31:0]ex_cur_addr;
	
//**********************ȡָ�׶�**********************//
	PC PC0(
	//in
	.clk(clk),//�½��ش���
	.rst(rst),
	
	.jump_reg(jump_reg),//�ж��Ƿ���ת
	.jump_addr(jump_addr),//�ж���ת��PCֵ
	
	//out
	.pc(pc_)
    );
	 

	if_id if_id0(
	//in
	.clk(clk),//�½��ش���
	.rst(rst),
	
	.if_pc(pc_),
	.if_inst(inst),
	//out
	.id_pc(id_pc_i),
	.id_inst(id_inst_i)
    );

//**********************����׶�**********************//
	
	
	regfiles regfiles0(
	//in
	.clk(clk),
	.rst(rst),
	
	.we(wb_wreg_i),//дʹ��,����д�ؽ׶�
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
	//�������ð�յ���·
	.ex_write(ex_wreg_o),//����ִ�н׶ε���·
	.ex_data(ex_wdata_o),
	.ex_addr(ex_wd_o),
	
	.mem_write(mem_wreg_o),//����ִ�н׶ε���·
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
	 
//***********************ִ�н׶�***********************//
	
	
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
	
	.ex_wd(ex_wd_o),//Ҫд���Ŀ�ļĴ�����ַ
	.ex_wreg(ex_wreg_o),//�Ƿ�Ҫд��Ŀ�ļĴ���
	.ex_wdata(ex_wdata_o),//Ҫд��Ŀ�ļĴ�����ֵ
	.of_i(of_i),
	.zf_i(zf_i),
	//���ش洢�����Ϣ
	.ex_aluop(ex_aluop_o),//ȷ����ȡ
	.ex_mem_addr(ex_mem_addr_o),//��ŵ�ַ
	.ex_reg2(ex_mem_w_data_o),//�������
	
	//out
	.mem_aluop(mem_aluop_i),//ȷ����ȡ
	.mem_mem_addr(mem_mem_addr_i),//��ŵ�ַ
	.mem_reg2(mem_mem_w_data_i),//�������
	//�͵��ô�׶ε���Ϣ
	.mem_wd(mem_wd_i),//�ô�׶�Ҫд���Ŀ�ļĴ�����ַ
	.mem_wreg(mem_wreg_i),//�Ƿ���
	.mem_wdata(mem_wdata_i),//ֵ
	.of_o(mem_of_i),
	.zf_o(mem_zf_i)
    );
	
	
//***********************д�ؽ׶�***********************//
	
	mem mem0(
		.rst(rst),
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),//�Ƿ�д��
		.wdata_i(mem_wdata_i),
		.aluop_i(mem_aluop_i),
		.mem_addr_i(mem_mem_addr_i),
		.reg2_i(mem_mem_w_data_i),
		.mem_data_i(ram_data),
		
		//д��
		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o),
		
		//�洢����д
		.mem_addr_o(mem_mem_addr_o),
		.mem_we_o(mem_mem_we_o),//�Ƿ�д��洢��
		.mem_data_o(mem_mem_data_o)
    );
	
	
	
	
	mem_wb mem_wb0(
		.clk(clk),
		.rst(rst),
		
		//�ô�׶δ���������Ϣ
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
		//out
		//����д�ؽ׶ε���Ϣ
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i)
    );



endmodule
