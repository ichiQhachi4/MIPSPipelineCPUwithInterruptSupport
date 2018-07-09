module idex(
  clk, rst, WriteSig, ClearSigIn,  PCIn, InstructionIn,
  CtrlSigIn, RD0In, RD1In, ExtRstIn, PCOut, InstructionOut,
  RD0Out, RD1Out, ExtRstOut, DMWr, RFWr, RFRd, WASel, 
  WDSel, ExtOp, PCSrc, ALUSrcA, ALUSrcB,ALUOp,
  CPIn, CPOut
);
  input clk;
  input rst;

  input WriteSig;
  input ClearSigIn;


  input [31:0] PCIn;
  input [31:0] InstructionIn;
  input [31:0] RD0In;
  input [31:0] RD1In;
  input [31:0] ExtRstIn;
  input [31:0] CPIn;


  input[20:0] CtrlSigIn;

  


  output [31:0] RD0Out;
  output [31:0] RD1Out;
  output[31:0] PCOut;
  output[31:0] InstructionOut;
  output [31:0] ExtRstOut;
  output [31:0] CPOut;


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

  reg [31:0] PCOut;
  reg [31:0] InstructionOut;
  reg [31:0] RD0Out;
  reg [31:0] RD1Out;
  reg [31:0] ExtRstOut;
  reg [31:0] CPOut;
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



  initial
  begin
    CtrlSig <= 20'b0;
    PCOut <= 32'b0;
    InstructionOut <= 32'b0;
    RD0Out <= 32'b0;
    RD1Out <= 32'b0;
    ExtRstOut <= 32'b0;
    CPOut <= 32'd0;
  end
  
  reg ClearSig;

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
      RD0Out <= 0;
      RD1Out <= 0;
      ExtRstOut <= 0;
      CPOut <= 0;
    end
    else if (WriteSig == 1) begin
      CtrlSig <= CtrlSigIn;
      PCOut <= PCIn;
      InstructionOut <= InstructionIn;
      RD0Out <= RD0In;
      RD1Out <= RD1In;
      ExtRstOut <= ExtRstIn;
      CPOut <= CPIn;
    end else begin
      CtrlSig <= CtrlSig;
      PCOut <= PCOut;
      InstructionOut <= InstructionOut;
      RD0Out <= RD0Out;
      RD1Out <= RD1Out;
      ExtRstOut <= ExtRstOut;
      CPOut <= CPOut;
    end
  end

endmodule // idex