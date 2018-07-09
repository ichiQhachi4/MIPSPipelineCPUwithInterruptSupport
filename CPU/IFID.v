
module ifid(
  clk, rst, WriteSig, ClearSigIn,  PCIn, InstructionIn,
  CtrlSigIn, PCOut, InstructionOut, DMWr, RFWr, RFRd, WASel, 
  WDSel, ExtOp, PCSrc, ALUSrcA, ALUSrcB, ALUOp 
);


  input clk;
  input rst;

  input WriteSig;
  input ClearSigIn;
  reg ClearSig;

  input[31:0] PCIn;
  input[31:0] InstructionIn;
  input[20:0] CtrlSigIn;

  reg [31:0] PC;
  reg [31:0] Instruction;

  output[31:0] PCOut;
  output[31:0] InstructionOut;


  reg [20:0] CtrlSig;
  
  output DMWr;
  output RFWr;
  output[1:0] RFRd;
    //读取的寄存器种类
  output [1:0] WASel;
  output [1:0] WDSel;
  output [1:0] ExtOp;
  output [2:0] PCSrc;
  output [1:0] ALUSrcA;
  output [1:0] ALUSrcB;
  output [3:0] ALUOp;

  assign DMWr = CtrlSig[20];
  assign RFWr = CtrlSig[19];
  assign RFRd [1:0] = CtrlSig[18:17];
  assign WASel[1:0] = CtrlSig[16:15];
  assign WDSel [1:0] = CtrlSig[14:13];
  assign ExtOp [1:0] = CtrlSig[12:11];
  assign PCSrc [2:0] = CtrlSig[10:8];
  assign ALUSrcA[1:0] = CtrlSig[7:6];
  assign ALUSrcB[1:0] = CtrlSig[5:4];
  assign ALUOp [3:0] = CtrlSig[3:0];



  assign InstructionOut = Instruction;
  
  assign PCOut = PC;
  



  always @(negedge clk or posedge rst) begin
    if (rst == 1) begin
      ClearSig <= 0;
    end else begin
      ClearSig <= ClearSigIn;
    end
  end

  always @(posedge clk or posedge rst) begin
    if(rst == 1 || ClearSig == 1) begin
      CtrlSig <= 0;
      PC <= 0;
      Instruction <= 0;
    end
    else if (WriteSig == 1) begin
      CtrlSig <= CtrlSigIn;
      PC <= PCIn;
      Instruction <= InstructionIn;
    end else begin
      CtrlSig <= CtrlSig;
      PC <= PC;
      Instruction <= Instruction;
    end
  end

endmodule // ifid