`timescale 1ns / 1ps

`define RstEnable 1'b1
`define RstDisable 1'b0
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0
//*******************特殊寄存器************************//
`define reg31 5'b11111;

//*******************ALU运算方式***********************//
`define EXE_ADD_OP 4'b0100
`define EXE_SUB_OP 4'b0101
`define EXE_AND_OP 4'b0000
`define EXE_OR_OP 4'b0001
`define EXE_XOR_OP 4'b0010
`define EXE_NOR_OP 4'b0011
`define EXE_SLTU_OP 4'b0110
`define EXE_SLLV_OP 4'b0111
`define EXE_ADDI_OP 4'b0100
`define EXE_ANDI_OP 4'b0000
`define EXE_XORI_OP 4'b0010
`define EXE_SLTIU_OP 4'b0110
`define EXE_LW_OP 4'b1000
`define EXE_SW_OP 4'b1100
`define EXE_LUI_OP 4'b1001
`define EXE_JR_OP 4'b1010
//用不到
`define EXE_BEQ_OP 4'b1011
`define EXE_BNE_OP 4'b1011
`define EXE_J_OP 4'b1011
`define EXE_JAL_OP 4'b1011

//******************func*********************//
`define EXE_AND  6'b100100
`define EXE_OR   6'b100101
`define EXE_XOR 6'b100110
`define EXE_NOR 6'b100111
`define EXE_SUB 6'b100010
`define EXE_ADD 6'b100000
`define EXE_SLTU 6'b101011
`define EXE_SLLV 6'b000100
`define EXE_JR 6'b001000

//******************op***********************//
`define EXE_ADDI  6'b001000
`define EXE_ANDI 6'b001100
`define EXE_XORI 6'b001110
`define EXE_SLTIU  6'b001011
`define EXE_LW  6'b100011
`define EXE_SW  6'b101011
`define EXE_SPECIAL_INST 6'b000000
`define EXE_LUI 6'b001111
`define EXE_J 6'b000010
`define EXE_JAL 6'b000011
`define EXE_BEQ 6'b000100
`define EXE_BNE 6'b000101


//AluSel
`define EXE_RES_ARITHMETIC 3'b100
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_SHIFT 3'b010
`define EXE_RES_LOAD_STORE 3'b111
`define EXE_RES_JUMP_BRANCH 3'b011