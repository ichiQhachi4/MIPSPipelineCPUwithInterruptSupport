module mewb (
  clk, rst, WriteSig, ClearSigIn,  PCIn, InstructionIn,
  CtrlSigIn, ALURstIn, RDIn, PCOut, InstructionOut, ALURstOut,
  RDOut, 
  DMWr, RFWr, RFRd, WASel, 
  WDSel, ExtOp, PCSrc, ALUSrcA, ALUSrcB,ALUOp,
  CPIn, CPOut
);


  input clk;
  input rst;
  input WriteSig;
  input[31:0] PCIn;
  input[31:0] InstructionIn;
  input[20:0] CtrlSigIn;
  input[31:0] RDIn;
  //读取内存中的数据
  input[31:0] ALURstIn;
  input [31:0] CPIn;
  output [31:0] CPOut;
  reg [31:0] CPOut;  
  output[31:0] PCOut;
  output[31:0] InstructionOut;
  output[31:0] RDOut;
  output[31:0] ALURstOut;
  reg [31:0] PCOut;
  reg [31:0] InstructionOut;
  reg [31:0] RDOut;
  reg [31:0] ALURstOut;
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
  reg [20:0] CtrlSig;
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
  input ClearSigIn;
  reg ClearSig;
  
  initial
  begin
    CtrlSig <= 21'b0;
    PCOut <= 32'b0;
    InstructionOut <= 32'b0;
  end

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
      PCOut <= 0;
      InstructionOut <= 0;
      ALURstOut <= 0;
      RDOut <= 0;
      CPOut <= 0;
    end
    else if (WriteSig == 1) begin
      CtrlSig <= CtrlSigIn;
      PCOut <= PCIn;
      InstructionOut <= InstructionIn;
      ALURstOut <= ALURstIn;
      RDOut <= RDIn;
      CPOut <= CPIn;
    end else begin
      CtrlSig <= CtrlSig;
      PCOut <= PCOut;
      InstructionOut <= InstructionOut;
      ALURstOut <= ALURstOut;
      RDOut <= RDOut;
      CPOut <= CPOut;
    end
  end

endmodule // MeWB
