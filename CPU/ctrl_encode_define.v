
`define DISABLE 1'b0
`define ENABLE  1'b1


//PCSrc 沿用
`define PLUS4_SRC   3'h0
`define BRANCH_SRC  3'h1
`define J_SRC       3'h2
`define JR_SRC      3'h3
`define INT_SRC     3'h4
`define EPC_SRC     3'h5

//ALUSrcA
`define PC_SRC      2'b00
`define A_SRC       2'b01
`define SHAMT_SRC   2'b10

//Forward 信号
`define NOFWD  2'b00
`define FWD_EX 2'b01
`define FWD_ME 2'b10

//ALUSrcB
`define B_SRC       2'b00
`define IMM_SRC     2'b01
`define IMMSFT_SRC  2'b10
`define ZERO_SRC    2'b11



//WASel
`define RT_WA 2'b00
`define RD_WA 2'b01
`define RA_WA 2'b10

//WDSel
`define MDR_WD 2'b00
`define PC_WD  2'b01
`define AO_WD  2'b10
`define C0_WD  2'b11

//EXTOp
`define ZERO_EXT 2'b00
`define SIGN_EXT 2'b01
`define LUI_EXT  2'b10

//ALUOp
`define ADD_ALU   4'd0
`define SUB_ALU   4'd1
`define AND_ALU   4'd2
`define OR_ALU    4'd3
`define XOR_ALU   4'd4
`define NOR_ALU   4'd5
`define LUI_ALU   4'd6
`define COMP_ALU  4'd7
`define COMPU_ALU 4'd8
`define SLL_ALU   4'd9
`define SRL_ALU   4'd10
`define SRA_ALU   4'd11

//重复利用be信号定义be的后三位，be的第一位表示扩展方式。
`define BYTE0_BE 3'b000
`define BYTE1_BE 3'b001
`define BYTE2_BE 3'b010
`define BYTE3_BE 3'b011
`define HALF0_BE 3'b100
`define HALF1_BE 3'b101
`define WORD_BE  3'b110
