/*-----MIPS-C2 instruction set-----*/

/*OP*/

`define SPECIAL 6'b000000
`define REGIMM  6'b000001
//this op code is for 2 instructions in the instruction set
//BLTZ BGEZ which is defined by rt field.
`define J_OP     6'b000010
`define JAL_OP   6'b000011
`define BEQ_OP   6'b000100
`define BNE_OP   6'b000101
`define BLEZ_OP  6'b000110
`define BGTZ_OP  6'b000111
`define ADDI_OP  6'b001000
`define ADDIU_OP 6'b001001
`define SLTI_OP  6'b001010
`define SLTIU_OP 6'b001011
`define ANDI_OP  6'b001100
`define ORI_OP   6'b001101
`define XORI_OP  6'b001110
`define LUI_OP   6'b001111
`define COP0_OP  6'b010000   
`define LB_OP    6'b100000
`define LH_OP    6'b100001
`define LW_OP    6'b100011
`define LBU_OP   6'b100100
`define LHU_OP   6'b100101
`define SB_OP    6'b101000
`define SH_OP    6'b101001
`define SW_OP    6'b101011


/*Funct*/

`define SLL_FUNCT  6'b000000
`define SRL_FUNCT  6'b000010
`define SRA_FUNCT  6'b000011
`define SLLV_FUNCT 6'b000100
`define SRLV_FUNCT 6'b000110
`define SRAV_FUNCT 6'b000111
`define JR_FUNCT   6'b001000
`define JALR_FUNCT 6'b001001
`define SYSCALL_FUNCT 6'b001100
`define ADD_FUNCT  6'b100000
`define ADDU_FUNCT 6'b100001
`define SUB_FUNCT  6'b100010
`define SUBU_FUNCT 6'b100011
`define AND_FUNCT  6'b100100
`define OR_FUNCT   6'b100101
`define XOR_FUNCT  6'b100110
`define NOR_FUNCT  6'b100111
`define SLT_FUNCT  6'b101010
`define SLTU_FUNCT 6'b101011


/*RTFIELD*/
`define BLTZ  5'b00000
`define BGTZ  5'b00001

/*RSFIELD*/
`define MFC0    5'b00000
`define MTC0    5'b00100
`define ERET    5'b10000


/*System call*/
`define SYSCALL_INSTR 32'd12
