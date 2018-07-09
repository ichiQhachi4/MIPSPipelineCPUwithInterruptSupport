`include "./ctrl_encode_define.v"
`include "./instruction_def.v"
`include "./global_def.v"


module ctrl(
  input clk, 
  input rst, 
  input [31:0]PCCurrent, 
  input [31:0]InstrIF, 
  input [31:0]InstrID, 
  input [31:0]InstrEx,
  input [31:0]InstrMe, 
  input [31:0]InstrWB, 
  input [1:0]RFRd_ID, //读取寄存器的种类 ID阶段
  input [1:0]WASel_Ex, 
  input DMWr_Ex, 
  output reg PCWr, 
  output reg IFIDWr, 
  output reg IDExWr, 
  output reg ExMeWr, 
  output reg MeWBWr,
  output reg IFIDRst, 
  output reg IDExRst, 
  output reg ExMeRst, 
  output reg MeWBRst,
  //CtrlSig 开始
  output DMWr, 
  output RFWr, 
  output [1:0]RFRd, //读取的寄存器种类
  output [1:0]WASel, 
  output [1:0]WDSel, 
  output [1:0]ExtOp, 
  output [2:0]PCSrc, 
  output [1:0]ALUSrcA, 
  output [1:0]ALUSrcB,
  output [3:0]ALUOp,
  //CtrlSig 结束
  //Exception Signal
  output reg Unimpl,
  output Sys,
  //Control Signal of CP0
  output reg CPWr,
  output reg Sign
);




//重要信号，这个信号每个周期产生





reg [21:0] CtrlSig;
//定义CtrlSignal方便后续传递信号

  assign Sys = CtrlSig[21];
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
  PCWr = 1'b1;
  IFIDWr = 1'b1;
  IDExWr = 1'b1;
  ExMeWr = 1'b1;
  MeWBWr = 1'b1;
  IFIDRst = 1'b0;
  IDExRst = 1'b0;
  ExMeRst = 1'b0;
  MeWBRst = 1'b0;
end


//此部分将产生控制信号
always @(*) begin
  case (InstrIF[31:26])
    `SPECIAL: case (InstrIF[5:0])
      `SLL_FUNCT:   CtrlSig = 22'b0011001100100010001001;
      `SRL_FUNCT:   CtrlSig = 22'b0011001100100010001010;
      `SRA_FUNCT:   CtrlSig = 22'b0011001100100010001011;
      `SLLV_FUNCT:  CtrlSig = 22'b0011101100100001001001;
      `SRLV_FUNCT:  CtrlSig = 22'b0011101100100001001010;
      `SRAV_FUNCT:  CtrlSig = 22'b0011101100100001001011;
      `JR_FUNCT:    CtrlSig = 22'b0000111110101111111111;
      `JALR_FUNCT:  CtrlSig = 22'b0010101010101100111111;
      `SYSCALL_FUNCT: CtrlSig = 22'b1000011110110011111111;
      `ADD_FUNCT:   CtrlSig = 22'b0011101100100001000000;
      `ADDU_FUNCT:  CtrlSig = 22'b0011101100100001000000;
      `SUB_FUNCT:   CtrlSig = 22'b0011101100100001000001;
      `SUBU_FUNCT:  CtrlSig = 22'b0011101100100001000001;
      `AND_FUNCT:   CtrlSig = 22'b0011101100100001000010;
      `OR_FUNCT:    CtrlSig = 22'b0011101100100001000011;
      `XOR_FUNCT:   CtrlSig = 22'b0011101100100001000100;
      `NOR_FUNCT:   CtrlSig = 22'b0011101100100001000101;
      `SLT_FUNCT:   CtrlSig = 22'b0011101100100001000111;
      `SLTU_FUNCT:  CtrlSig = 22'b0011101100100001001000;
      default:      CtrlSig = 22'd0;//出錯
    endcase
    `REGIMM: case (InstrIF `RTFLD)
      `BLTZ:    CtrlSig = 22'b0000111110100101110111;
      `BGTZ:    CtrlSig = 22'b0000111110100101110111;
      default:  CtrlSig = 22'd0;
    endcase
    `J_OP:      CtrlSig = 22'b0000011110101011111111;
    `JAL_OP:    CtrlSig = 22'b0010010010101000111111;
    `BEQ_OP:    CtrlSig = 22'b0001111110100101001111;
    `BNE_OP:    CtrlSig = 22'b0001111110100101001111;
    `BLEZ_OP:   CtrlSig = 22'b0000111110100101110111;
    `BGTZ_OP:   CtrlSig = 22'b0000111110100101110111;
    `ADDI_OP:   CtrlSig = 22'b0010100100100001010000;
    `ADDIU_OP:  CtrlSig = 22'b0010100100100001010000;
    `SLTI_OP:   CtrlSig = 22'b0010100100000001010111;
    `SLTIU_OP:  CtrlSig = 22'b0010100100000001011000;
    `ANDI_OP:   CtrlSig = 22'b0010100100000001010010;
    `ORI_OP:    CtrlSig = 22'b0010100100000001010011;
    `XORI_OP:   CtrlSig = 22'b0010100100000001010100;
    `LUI_OP:    CtrlSig = 22'b0010100101000001010110;
    `COP0_OP: case (InstrIF[25:21])
      `MFC0:    CtrlSig = 22'b0010000110100011111111;
      `MTC0:    CtrlSig = 22'b0001001100100011000000;
      `ERET:    CtrlSig = 22'b0000011110110111111111; 
      default:  CtrlSig = 22'd0;
    endcase
    `LB_OP:     CtrlSig = 22'b0010100000100001010000;
    `LH_OP:     CtrlSig = 22'b0010100000100001010000;
    `LW_OP:     CtrlSig = 22'b0010100000100001010000;
    `LBU_OP:    CtrlSig = 22'b0010100000100001010000;
    `LHU_OP:    CtrlSig = 22'b0010100000100001010000;
    `SB_OP:     CtrlSig = 22'b0101111110100001010000;
    `SH_OP:     CtrlSig = 22'b0101111110100001010000;
    `SW_OP:     CtrlSig = 22'b0101111110100001010000;
    default:    CtrlSig = 22'd0;

  endcase
end

//为恢复正常信号的指令
task DefaultSig;
begin
  PCWr = 1'b1;
  IFIDWr = 1'b1;
  IDExWr = 1'b1;
  ExMeWr = 1'b1;
  MeWBWr = 1'b1;
  IFIDRst = 1'b0;
  IDExRst = 1'b0;
  ExMeRst = 1'b0;
  MeWBRst = 1'b0;
end
endtask

//为lw数据相关产生延迟指令
task delayL;
  begin
  PCWr = 1'b0;
  IFIDWr = 1'b0;
  IDExWr = 1'b0;
  ExMeWr = 1'b1;
  MeWBWr = 1'b1;

  IFIDRst = 1'b0;
  IDExRst = 1'b1;
  ExMeRst = 1'b0;
  MeWBRst = 1'b0;
  end
endtask

//判断lw数据相关是有时候需要延迟一周期
//需要的信号Ex里的WASel和ID里的RFRd
always @(*) begin
  if(InstrEx [31:29] == 3'b100) begin
  //把OP中的前三位当作load指令的唯一标识
    case (RFRd_ID)
      2'b01: if (InstrID `RSFLD == InstrEx `RTFLD) begin
        delayL;
      end
      2'b10: if (InstrID `RTFLD == InstrEx `RTFLD) begin
        delayL;
      end
      2'b11: if (InstrID `RSFLD == InstrEx `RTFLD || InstrID `RTFLD == InstrEx `RTFLD) begin
        delayL;
      end
      default: DefaultSig;
    endcase
  end
  /*
  else if (InstrIF[31:21] == 11'b01000010000 && InstrID[31:21] == 11'b01000000100) begin
      PCWr = 1'b0;
      IFIDWr = 1'b0;
      IDExWr = 1'b1;
      ExMeWr = 1'b1;
      MeWBWr = 1'b1;

      IFIDRst = 1'b1;
      IDExRst = 1'b0;
      ExMeRst = 1'b0;
      MeWBRst = 1'b0;      
    end
  else if (InstrIF[31:21] == 11'b01000010000 && InstrEx[31:21] == 11'b01000000100) begin
      PCWr = 1'b0;
      IFIDWr = 1'b0;
      IDExWr = 1'b1;
      ExMeWr = 1'b1;
      MeWBWr = 1'b1;

      IFIDRst = 1'b1;
      IDExRst = 1'b0;
      ExMeRst = 1'b0;
      MeWBRst = 1'b0;      
    end
  else if (InstrIF[31:21] == 11'b01000010000 && InstrMe[31:21] == 11'b01000000100) begin
      PCWr = 1'b0;
      IFIDWr = 1'b0;
      IDExWr = 1'b1;
      ExMeWr = 1'b1;
      MeWBWr = 1'b1;

      IFIDRst = 1'b1;
      IDExRst = 1'b0;
      ExMeRst = 1'b0;
      MeWBRst = 1'b0;      
    end
  else if (InstrIF[31:21] == 11'b01000010000 && InstrWB[31:21] == 11'b01000000100) begin
      PCWr = 1'b0;
      IFIDWr = 1'b0;
      IDExWr = 1'b1;
      ExMeWr = 1'b1;
      MeWBWr = 1'b1;

      IFIDRst = 1'b1;
      IDExRst = 1'b0;
      ExMeRst = 1'b0;
      MeWBRst = 1'b0;      
    end
	 
  else if (InstrIF[31:21] == 11'b01000000000 && InstrID[31:21] == 11'b01000000100)begin
      PCWr = 1'b0;
      IFIDWr = 1'b0;
      IDExWr = 1'b1;
      ExMeWr = 1'b1;
      MeWBWr = 1'b1;

      IFIDRst = 1'b1;
      IDExRst = 1'b0;
      ExMeRst = 1'b0;
      MeWBRst = 1'b0; 
  end
*/
  else begin
    DefaultSig;
  end
end

//always block, to generate control signal of CP0
  always @(*) begin
    if (InstrWB [31:26] == `COP0_OP && InstrWB [25:21] == `MTC0) begin
      CPWr = 1'b1;
    end else begin
      CPWr = 1'b0;
    end
  end

//always block, to generate eret Sig

// always block, to generate exception signal of Undefined instruction and Systemcall
  always @(*) begin
    if (CtrlSig == 0) begin
      Unimpl = 1'b1;
    end
    else begin
      Unimpl = 1'b0;
    end
  end

  always @(*) begin
    case (InstrEx[31:26])
      `SPECIAL: Sign = ~InstrEx[0];
      `ADDI_OP: Sign = 1;
      `ADDIU_OP: Sign = 0;
      default: Sign = 0;
    endcase
  end



endmodule // ctrl
