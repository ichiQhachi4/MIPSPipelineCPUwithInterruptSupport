`include "./global_def.v"
`include "./instruction_def.v"
`include "./ctrl_encode_define.v"
`include "./alu.v"
`include "./ext.v"
`include "./pc.v"
`include "./regtemp.v"
`include "./ctrl.v"
`include "./mux.v"
`include "./IFID.v"
`include "./IDEx.v"
`include "./ExMe.v"
`include "./MeWB.v"
`include "./forwarding.v"
`include "./branch.v"
`include "./npc.v"
`include "./CP0.v"


module PLCPU(	    input clk,
					input rst,
					input MIO_ready,
									
					input [31:0]inst_in,
					input [31:0]Data_in,	
									
					output mem_w,
					output[31:0]PC_out,
					output[31:0]Addr_out,
					output[31:0]Data_out, 
					output CPU_MIO,
					input INT,
					output [31:0] StatusOut,
					output [31:0] Userdefine,
					output [31:0] Cause,
					output [31:0] a3
				);
				

  wire INTOut;  
  wire PCWr;
  wire[31:0] InstructionNext;
  wire[31:0] InstructionCurrent;
  wire[31:0] WriteData;
  wire[31:0] MemReadNext;

  wire[4:0] WriteAddr;
  wire[31:0] ALUSourceA;
  wire[31:0] ALUSourceB;
  wire[3:0] be;

  wire [31:0] PCNext;
  wire[31:0] PCIF, PCID, PCEx, PCMe, PCWB;
  wire[31:0] InstrIF, InstrID, InstrEx, InstrMe, InstrWB;

  wire [31:0] EPCCurrent;
  wire [31:0] EPCNext;

  wire [31:0] Status;
  assign StatusOut = Status;
  wire [31:0] CPRead;

  wire [3:0] CPSig;

  wire CPWr;

  wire WSIFID, WSIDEx, WSExMe, WSMeWB;
  //Write Signal for all Pipeline Reg

  wire CSIFID, CSIDEx, CSExMe, CSMeWB;
  //Clear Signal for all Pipeline Reg
  

  wire [31:0] ExtRstEx, ExtRstID;
  wire [31:0] RDMe, RDWB;
  //Data read from Memory
  wire SysCtrl, UnimplCtrl;

  wire Overflow;
  wire Sign;
  

  wire DMWrIF, RFWrIF, DMWrID, RFWrID, DMWrEx, RFWrEx, DMWrMe, RFWrMe, DMWrWB, RFWrWB;
  wire [1:0] RFRdIF, WASelIF, WDSelIF, ExtOpIF, ALUSrcAIF, ALUSrcBIF,
    RFRdID, WASelID, WDSelID, ExtOpID, ALUSrcAID, ALUSrcBID, 
    RFRdEx, WASelEx, WDSelEx, ExtOpEx, ALUSrcAEx, ALUSrcBEx,
    RFRdMe, WASelMe, WDSelMe, MetOpMe, ALUSrcAMe, ALUSrcBMe,
    RFRdWB, WASelWB, WDSelWB, WBtOpWB, ALUSrcAWB, ALUSrcBWB;
  wire [2:0] PCSrcIF, PCSrcID, PCSrcEx, PCSrcMe, PCSrcWB;

  wire [3:0]ALUOpIF, ALUOpID, ALUOpEx, ALUOpMe, ALUOpWB;

  wire [31:0] ALURstEx, ALURstMe, ALURstWB;

  wire [1:0] FWDSigA, FWDSigB;
  wire [31:0] RD0AfterFWD, RD1AfterFWD;

  wire [31:0] RD0ID, RD0Ex, RD1ID, RD1Ex;

  wire [4:0] WAWB, WAMe;

  wire [31:0] WDMem;

  wire [31:0] JalSrc;

  wire [31:0] CPEx, CPMe, CPWB;

  wire eretSig;

  pc ProgramCounter(clk, rst, PCNext, PCWr, PCIF);

  npc NewPC(
  .clk(clk), 
  .rst(rst), 
  .PCIF(PCIF),
  //read from PC unit
  .PCID(PCID),
  //from IFID
  .PCEx(PCEx),
  //from IDEx
  .EPCIn(EPCCurrent),
  //from coprocessor
  .Offset(InstrIF [15:0]),
  //from IF/ID
  .JumpTarget(InstrIF [25:0]),
  //jump target for JAL instruction, from instruction of IF
  .JumpRegister(RD0AfterFWD),
  //from ID regread 
  .PCSrc(PCSrcIF),
  //get EPC_SRC when eret, get INT_SRC when unimplement or syscall
  .BranchEx(BranchEx), 
  //作为Ex阶段的其他Branch命令的判断信号，此信号为Ex过程中产生的，未到达EX/ME
  .PCWrIn(NPCWr), 
  .INTIn(INT),
  .SysIn(SysCtrl),
  .UnimplIn(UnimplCtrl),
  .OvfIn(Overflow),
  .Status(Status[3:0]),
  .PCWrOut(PCWr), 
  .PCNextOut(PCNext),
  .EPCOut(EPCNext),
  .IFIDRstOut(CSIFIDnpc), 
  .IDExRstOut(CSIDExnpc),
  .ExMeRstOut(CSExMenpc),
  .CPSigOut(CPSig),
  .INTOut(INTOut),
  .EPCWrOut(EPCWr),
  .eretSig(eretSig)
  );

  branch Branch(ALURstEx, ZeroEx, InstrEx, BranchEx);

  assign InstrIF = inst_in;
  assign PC_out = PCIF;
  
//  im_4k InstructionMemory(InstrIF, PCIF[11:2]);

  ctrl Control(
  .clk(clk), 
  .rst(rst), 
  .PCCurrent(PCIF), 
  .InstrIF(InstrIF), 
  .InstrID(InstrID), 
  .InstrEx(InstrEx),
  .InstrMe(InstrMe), 
  .InstrWB(InstrWB), 
  .RFRd_ID(RFRdID), //读取寄存器的种类 ID阶段
  .WASel_Ex(WASelEx), 
  .DMWr_Ex(DMWrEx), 
  .PCWr(NPCWr), 
  .IFIDWr(WSIFID), 
  .IDExWr(WSIDEx), 
  .ExMeWr(WSExMe), 
  .MeWBWr(WSMeWB),
  .IFIDRst(CSIFIDctrl), 
  .IDExRst(CSIDExctrl), 
  .ExMeRst(CSExMectrl), 
  .MeWBRst(CSMeWB),
  //CtrlSig 开始
  .DMWr(DMWrIF), 
  .RFWr(RFWrIF), 
  .RFRd(RFRdIF), //读取的寄存器种类
  .WASel(WASelIF), 
  .WDSel(WDSelIF), 
  .ExtOp(ExtOpIF), 
  .PCSrc(PCSrcIF), 
  .ALUSrcA(ALUSrcAIF), 
  .ALUSrcB(ALUSrcBIF),
  .ALUOp(ALUOpIF),
  //CtrlSig 结束
  //Exception Signal
  .Unimpl(UnimplCtrl),
  .Sys(SysCtrl),
  //Control Signal of CP0
  .CPWr(CPWr),
  .Sign(Sign)
);

//NEW Need to be deleted

/*
assign Sign = 0;
//wire UnimplCtrl;
assign UnimplCtrl = 0;
wire CSExMectrl;
assign CSExMectrl = 0;
//wire SysCtrl;
assign SysCtrl = 0;
//wire CPWr;
assign CPWr = 0;
*/



CP0 Coprocessor0(
  .clk(clk), 
  .rst(rst), 
  .Signal(CPSig),
  //Signal[0] = INT, Signal[1] = Sys, Signal[2] = Unimpl, Signal[3] = Ovf
  .CPRA(InstrID[15:11]),
  .CPWr(CPWr),
  .PCSrc(PCSrcIF),
  .CPWD(WriteData),
  .EPCIn(EPCNext),
  //generate from NPC
  .CPWA(WriteAddr),
  .CPRD(CPRead),
  .EPCOut(EPCCurrent),
  .StatusOut(Status),
  .CauseOut(Cause),
  //send to NPC
  .PCWr(PCWr),
  .EPCWr(EPCWr),
  .eret(eretSig)
);


  assign CSIFID = CSIFIDctrl | CSIFIDnpc;
  assign CSIDEx = CSIDExctrl | CSIDExnpc;
  assign CSExMe = CSExMectrl | CSExMenpc;

  ifid IFID(clk, rst, WSIFID, CSIFID, PCIF,  InstrIF, {DMWrIF, RFWrIF, RFRdIF, WASelIF, WDSelIF, ExtOpIF, PCSrcIF, ALUSrcAIF, ALUSrcBIF,ALUOpIF}, PCID, InstrID, DMWrID, RFWrID, RFRdID, WASelID, WDSelID, ExtOpID, PCSrcID, ALUSrcAID, ALUSrcBID,ALUOpID);

  idex IDEX(clk, rst, WSIDEx, CSIDEx, PCID, InstrID, 
    {DMWrID, RFWrID, RFRdID, WASelID, WDSelID, ExtOpID, PCSrcID, ALUSrcAID, ALUSrcBID,ALUOpID}, 
    RD0ID, RD1ID, ExtRstID, 
    PCEx, InstrEx, RD0Ex, RD1Ex, ExtRstEx, 
    DMWrEx, RFWrEx, RFRdEx, WASelEx, WDSelEx, ExtOpEx, PCSrcEx, ALUSrcAEx, ALUSrcBEx,ALUOpEx,
    CPRead, CPEx);

  rf RegFile(clk, rst, RFWrWB, WriteAddr, WriteData, InstrID `RSFLD, InstrID `RTFLD, RD0ID, RD1ID, a3);
   
  exme EXME(clk, rst, WSExMe, CSExMe, PCEx, InstrEx, 
    {DMWrEx, RFWrEx, RFRdEx, WASelEx, WDSelEx, ExtOpEx, PCSrcEx, ALUSrcAEx, ALUSrcBEx,ALUOpEx}, 
    ALURstEx, ZeroEx, PCMe, InstrMe, ALURstMe, ZeroMe, DMWrMe, RFWrMe, RFRdMe, WASelMe, WDSelMe, MetOpMe, PCSrcMe, ALUSrcAMe, ALUSrcBMe,ALUOpMe,
    CPEx, CPMe);


  mewb MEWB(clk, rst, WSMeWB, CSMeWB, PCMe, InstrMe, 
    {DMWrMe, RFWrMe, RFRdMe, WASelMe, WDSelMe, MetOpMe, PCSrcMe, ALUSrcAMe, ALUSrcBMe,ALUOpMe}, 
    ALURstMe, RDMe, PCWB, InstrWB, ALURstWB, RDWB, 
    DMWrWB, RFWrWB, RFRdWB, WASelWB, WDSelWB, WBtOpWB, PCSrcWB, ALUSrcAWB, ALUSrcBWB,ALUOpWB,
    CPMe, CPWB);

  assign RDMe = Data_in;
  assign Addr_out = ALURstMe;
  assign Data_out = WDMem;
  assign mem_w = DMWrMe;
  
  
   //begenerator BEGen(clk, rst, InstrMe, ALURstMe, be);


  //dm_4k DataMemory(ALURstMe[11:2], be, WDMem, DMWrMe, clk, MemReadNext);

  //extplus ExtensionPLUS(MemReadNext, be, RDMe); 

  //把这个修改为输入DM的数据暂存寄存器
  regtemp MemoryDataRegister(clk, rst, 1'b1, RD1AfterFWD, WDMem);

  mux4to1 #5 WAMuxEx(InstrMe `RTFLD, InstrMe `RDFLD, 5'd31, 5'd0, WASelMe, WAMe);
  mux4to1 #5 WAMuxMe(InstrWB `RTFLD, InstrWB `RDFLD, 5'd31, 5'd0, WASelWB, WAWB);
  
  FU ForwardingUnit(clk, rst, InstrEx, RFRdEx, WAMe, RFWrMe, WAWB, RFWrWB, FWDSigA, FWDSigB, InstrMe);

  mux4to1 #32 RD0ForwardMux(RD0Ex, ALURstMe, WriteData, CPMe, FWDSigA, RD0AfterFWD);
  mux4to1 #32 RD1ForwardMux(RD1Ex, ALURstMe, WriteData, CPMe, FWDSigB, RD1AfterFWD);
 
  assign JalSrc = PCWB + 4;

  mux4to1 #32 WriteDataMux(RDWB, JalSrc, ALURstWB, CPWB, WDSelWB, WriteData);

  mux4to1 #5 WriteAddressMux(InstrWB `RTFLD, InstrWB `RDFLD, 5'd31, 5'd0, WASelWB, WriteAddr);


  Ext Extension(InstrID [15:0], ExtOpID, ExtRstID);
  
  mux4to1 #32 ALUSourceAMux(PCEx, RD0AfterFWD, {27'd0, {InstrEx `SHAMT}}, 32'd0,ALUSrcAEx, ALUSourceA);
  mux4to1 #32 ALUSourceBMux(RD1AfterFWD, ExtRstEx, {{ExtRstEx[29:0]}, 2'b00}, 32'd0, ALUSrcBEx, ALUSourceB);
  
  alu ALU (ALURstEx, ZeroEx, ALUSourceA, ALUSourceB, ALUOpEx, Sign, Overflow);
  
//debug
  assign Userdefine = {EPCCurrent[15:0],8'b0, CPSig, INTOut, Sign, UnimplCtrl, SysCtrl};
  

endmodule