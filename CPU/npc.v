`include "./global_def.v"
`include "./ctrl_encode_define.v"

module npc(
  input clk, 
  input rst, 
  input [31:0]PCIF,
  //read from PC unit
  input [31:0]PCID,
  //from IFID
  input [31:0]PCEx,
  //from IDEx
  input [31:0]EPCIn,
  //from coprocessor
  input [15:0]Offset,
  //from IF/ID
  input [25:0]JumpTarget,
  //jump target for JAL instruction, from instruction of IF
  input [31:0]JumpRegister,
  //from ID regread 
  input [2:0]PCSrc,
  //get EPC_SRC when eret, get INT_SRC when unimplement or syscall
  input BranchEx, 
  //作为Ex阶段的其他Branch命令的判断信号，此信号为Ex过程中产生的，未到达EX/ME
  input PCWrIn, 
  input INTIn,
  input SysIn,
  input UnimplIn,
  input OvfIn,
  input [3:0] Status,
  output PCWrOut, 
  output [31:0]PCNextOut,
  output [31:0]EPCOut,
  output IFIDRstOut, 
  output IDExRstOut,
  output ExMeRstOut,
  output [3:0] CPSigOut,
  output INTOut,
  output EPCWrOut,
  output eretSig
  );



reg PCWr;
reg EPCWr;

reg [31:0] PCNext;

reg IFIDRst;

reg IDExRst;

reg ExMeRst;

reg [2:0] state;
//要初值为0
reg [31:0] EPC;
reg eret;
assign eretSig = eret;
assign EPCOut = EPC;
reg [3:0] CPSig;
assign CPSigOut = CPSig;

assign INTOut = INTIn;
reg [31:0] PCTemp;
//作为分支预测错误是回退用

assign PCNextOut = PCNext;

assign PCWrOut = PCWr;

assign EPCWrOut = EPCWr;


assign IFIDRstOut = IFIDRst;
assign IDExRstOut = IDExRst;
assign ExMeRstOut = ExMeRst;

initial 
begin
	IFIDRst <= 0;
	IDExRst <= 0;
	ExMeRst <= 0;
	PCWr <= 1;
  EPCWr <= 0;
	PCTemp <= 0;
	EPC <= 0;
	PCNext <= 0;
	state <= 0;
  eret <= 0;
end



always @(*) begin
	if(PCWrIn == 0) begin
    //In this case, ovf can't happen
    if(INTIn == 1 && Status[0] == 1) begin
      PCNext = 32'h8;
      EPC = PCID;
      PCWr = 1'b1;
      EPCWr = 1'b1;
      eret = 1'b0;
      IFIDRst = 1'b1;
      IDExRst = 1'b1;
      ExMeRst = 1'b0;
      CPSig = 4'd1; //INTIn
    end
    else if (SysIn == 1 && Status[1] == 1 && state == 0) begin
      PCNext = 32'h8;
      EPC = PCIF;
      PCWr = 1'b1;
      EPCWr = 1'b1;
      eret = 1'b0;
      IFIDRst = 1'b0;
      IDExRst = 1'b0;
      ExMeRst = 1'b0;
      CPSig = 4'd2; //Sys
    end
    else if (SysIn == 1 && Status[1] == 1 && state != 0) begin
      //at this stage, an exception won't happen because of mighty branch or jump
      PCNext = PCIF;
      EPC = PCID;
      EPCWr = 1'b0;
      PCWr = 1'b0;
      eret = 1'b0;
      IFIDRst = 1'b0;
      IDExRst = 1'b0;
      ExMeRst = 1'b0;
      CPSig = 4'd0;
    end
    else if (UnimplIn == 1 && Status[2] == 1 && state == 0) begin
      PCNext = 32'h8;
      EPC = PCIF;
      PCWr = 1'b1;
      EPCWr = 1'b1;
      eret = 1'b0;
      IFIDRst = 1'b0;
      IDExRst = 1'b0;
      ExMeRst = 1'b0;
      CPSig = 4'd4; //Unimpl
    end
    else if (UnimplIn == 1 && Status[2] == 1 && state != 0) begin
      PCNext = PCIF;
      EPC = PCID;
      PCWr = 1'b0;
      EPCWr = 1'b0;
      eret = 1'b0;
      IFIDRst = 1'b0;
      IDExRst = 1'b0;
      ExMeRst = 1'b0;
      CPSig = 4'd0;
    end
    else if (OvfIn == 1 && Status[3] == 1) begin
      PCNext = 32'h8;
      EPC = PCEx;
      PCWr = 1'b1;
      EPCWr = 1'b1;
      eret = 1'b0;
      IFIDRst = 1'b1;
      IDExRst = 1'b1;
      ExMeRst = 1'b1;
      CPSig = 4'd8; //Ovf
    end
    else begin
      PCNext = PCIF;
      EPC = EPCIn;
      PCWr = 1'b0;
      EPCWr = 1'b0;
      eret = 1'b0;
      IFIDRst = 1'b0;
      IDExRst = 1'b0;
      ExMeRst = 1'b0;
      CPSig = 4'd0;
    end
  end
  else begin
    case (state)
      0: begin
        if(INTIn == 1 && Status[0] == 1) begin
          PCNext = 32'h8;
          EPC = PCIF;
          PCWr = 1'b1;
          EPCWr = 1'b1;
          eret = 1'b0;
          IFIDRst = 1'b1;
          IDExRst = 1'b0;
          ExMeRst = 1'b0;
          CPSig = 4'd1; //INTIn
        end
        else if (OvfIn == 1 && Status[3] == 1) begin
          PCNext = 32'h8;
          EPC = PCEx;
          PCWr = 1'b1;
          EPCWr = 1'b1;
          eret = 1'b0;
          IFIDRst = 1'b1;
          IDExRst = 1'b1;
          ExMeRst = 1'b1;
          CPSig = 4'd8; //Ovf
        end
        else if (UnimplIn == 1 && Status[2] == 1) begin
          PCNext = 32'h8;
          EPC = PCIF;
          PCWr = 1'b1;
          EPCWr = 1'b1;
          eret = 1'b0;
          IFIDRst = 1'b0;
          IDExRst = 1'b0;
          ExMeRst = 1'b0;
          CPSig = 4'd4; //Unimpl
        end
        else if (SysIn == 1 && Status[1] == 1) begin
          PCNext = 32'h8;
          EPC = PCIF;
          PCWr = 1'b1;
          EPCWr = 1'b1;
          eret = 1'b0;
          IFIDRst = 1'b0;
          IDExRst = 1'b0;
          ExMeRst = 1'b0;
          CPSig = 4'd2; //Sys
        end
        else begin
          case (PCSrc)
          `PLUS4_SRC: begin
            PCNext = PCIF + 4;
            EPC = EPCIn;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          `BRANCH_SRC: begin
            PCNext = PCIF + 4;
            EPC = EPCIn;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'b0;
            // state <= 2;
          end
          `J_SRC: begin
            PCNext = {{PCIF[31:28]},JumpTarget, {2'b0}};
            EPC = EPCIn;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          `JR_SRC: begin
            PCNext = PCIF + 4;
            EPC = EPCIn;
            PCWr = 1'b0;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'b0;
            // state <= 1;
          end
          `INT_SRC: begin
            PCNext = PCIF + 4;
            EPC = EPCIn;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          `EPC_SRC: begin
            PCNext = EPCIn;
            EPC = EPCIn;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b1;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          default: begin
            PCNext = PCIF + 4;
            EPC = EPCIn;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          endcase
        end

      end
      1: begin
        if(INTIn == 1 && Status[0] == 1) begin
          PCNext = 32'h8;
          EPC = PCID;
          PCWr = 1'b1;
          EPCWr = 1'b1;
          eret = 1'b0;
          IFIDRst = 1'b1;
          IDExRst = 1'b1;
          ExMeRst = 1'b0;
          CPSig = 4'd1; //INTIn
        end
        else if (OvfIn == 1 && Status[3] == 1) begin
          PCNext = 32'h8;
          EPC = PCEx;
          PCWr = 1'b1;
          EPCWr = 1'b1;
          eret = 1'b0;
          IFIDRst = 1'b1;
          IDExRst = 1'b1;
          ExMeRst = 1'b1;
          CPSig = 4'd8; //Ovf
        end
        else if (UnimplIn == 1 && Status[2] == 1) begin
          //this can't  happen 
          PCNext = PCIF + 4;
          EPC = PCID;
          PCWr = 1'b0;
          EPCWr = 1'b1;
          eret = 1'b0;
          IFIDRst = 1'b1;
          IDExRst = 1'b0;
          ExMeRst = 1'b0;
          CPSig = 4'd0;
        end
        else if (SysIn == 1 && Status[1] == 1) begin
          //this can't  happen 
          PCNext = PCIF;
          EPC = PCID;
          PCWr = 1'b0;
          EPCWr = 1'b1;
          eret = 1'b0;
          IFIDRst = 1'b1;
          IDExRst = 1'b0;
          ExMeRst = 1'b0;
          CPSig = 4'd0;
        end
        else begin
          PCNext = PCIF + 4;
          EPC = EPCIn;
          PCWr = 1'b0;
          EPCWr = 1'b0;
          eret = 1'b0;
          IFIDRst = 1'b1;
          IDExRst = 1'b0;
          ExMeRst = 1'b0;
          CPSig = 4'd0;
        end
      end
      2: begin
        if(INTIn == 1 && Status[0] == 1) begin
          PCNext = 32'h8;
          EPC = PCID;
          PCWr = 1'b1;
          EPCWr = 1'b1;
          eret = 1'b0;
          IFIDRst = 1'b1;
          IDExRst = 1'b1;
          ExMeRst = 1'b0;
          CPSig = 4'd1; //INTIn
        end
        else if (OvfIn == 1 && Status[3] == 1) begin
          PCNext = 32'h8;
          EPC = PCEx;
          PCWr = 1'b1;
          EPCWr = 1'b1;
          eret = 1'b0;
          IFIDRst = 1'b1;
          IDExRst = 1'b1;
          ExMeRst = 1'b1;
          CPSig = 4'd8; //Ovf
        end
        else if (UnimplIn == 1 && Status[2] == 1) begin
          PCNext = PCIF + 4;
          EPC = PCID;
          PCWr = 1'b0;
          EPCWr = 1'b0;
          eret = 1'b0;
          IFIDRst = 1'b1;
          IDExRst = 1'b0;
          ExMeRst = 1'b0;
          CPSig = 4'd0;
        end
        else if (SysIn == 1 && Status[1] == 1) begin
          PCNext = PCIF;
          EPC = PCID;
          PCWr = 1'b0;
          EPCWr = 1'b0;
          eret = 1'b0;
          IFIDRst = 1'b1;
          IDExRst = 1'b0;
          ExMeRst = 1'b0;
          CPSig = 4'd0;
        end
        else begin
          case (PCSrc)
          `PLUS4_SRC: begin
            PCNext = PCIF + 4;
            EPC = EPCIn;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          `BRANCH_SRC: begin
            PCNext = PCIF + 4;
            EPC = EPCIn;
            PCWr = 1'b0;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b1;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'b0;
          end
          `J_SRC: begin
            PCNext = {{PCIF[31:28]},JumpTarget, {2'b0}};
            EPC = EPCIn;
            PCWr = 1'b0;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b1;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          `JR_SRC: begin
            PCNext = PCIF + 4;
            EPC = EPCIn;
            PCWr = 1'b0;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b1;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'b0;
          end
          `INT_SRC: begin
            PCNext = PCIF + 4;
            EPC = EPCIn;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          `EPC_SRC: begin
            PCNext = EPCIn;
            EPC = EPCIn;
            PCWr = 1'b0;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b1;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          default: begin
            PCNext = PCIF + 4;
            EPC = EPCIn;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          endcase
        end
      end
      3: begin
        if (BranchEx == 1) begin
          if(INTIn == 1 && Status[0] == 1) begin
            PCNext = 32'h8;
            EPC = PCTemp;
            PCWr = 1'b1;
            EPCWr = 1'b1;
            eret = 1'b0;
            IFIDRst = 1'b1;
            IDExRst = 1'b1;
            ExMeRst = 1'b0;
            CPSig = 4'd1; //INTIn
          end
          else if (OvfIn == 1 && Status[3] == 1) begin
            //can't happen
            PCNext = 32'h8;
            EPC = PCEx;
            PCWr = 1'b1;
            EPCWr = 1'b1;
            eret = 1'b0;
            IFIDRst = 1'b1;
            IDExRst = 1'b1;
            ExMeRst = 1'b1;
            CPSig = 4'd8; //Ovf
          end
          else if (UnimplIn == 1 && Status[2] == 1) begin
            PCNext = PCTemp;
            EPC = PCEx;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b1;
            IDExRst = 1'b1;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          else if (SysIn == 1 && Status[1] == 1) begin
            PCNext = PCTemp;
            EPC = PCEx;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b1;
            IDExRst = 1'b1;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          else begin
            PCNext = PCTemp;
            EPC = EPCIn;
            PCWr =1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b1;
            IDExRst = 1'b1;
            ExMeRst = 1'b0;
            CPSig = 4'd0;

          end
        end else begin
          case (PCSrc)
          `PLUS4_SRC: begin
            PCNext = PCIF + 4;
            EPC = EPCIn;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          `BRANCH_SRC: begin
            PCNext = PCIF + 4;
            EPC = EPCIn;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'b0;
            // state <= 2;
          end
          `J_SRC: begin
            PCNext = {{PCIF[31:28]},JumpTarget, {2'b0}};
            EPC = EPCIn;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          `JR_SRC: begin
            PCNext = PCIF + 4;
            EPC = EPCIn;
            PCWr = 1'b0;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'b0;
            // state <= 1;
          end
          `INT_SRC: begin
            PCNext = PCIF + 4;
            EPC = EPCIn;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          `EPC_SRC: begin
            PCNext = EPCIn;
            EPC = EPCIn;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b1;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          default: begin
            PCNext = PCIF + 4;
            EPC = EPCIn;
            PCWr = 1'b1;
            EPCWr = 1'b0;
            eret = 1'b0;
            IFIDRst = 1'b0;
            IDExRst = 1'b0;
            ExMeRst = 1'b0;
            CPSig = 4'd0;
          end
          endcase
        end
      end
      4: begin
        if(INTIn == 1 && Status[0] == 1) begin
          PCNext = 32'h8;
          EPC = JumpRegister;
          PCWr = 1'b1;
          EPCWr = 1'b1;
          eret = 1'b0;
          IFIDRst = 1'b1;
          IDExRst = 1'b0;
          ExMeRst = 1'b0;
          CPSig = 4'd1; //INTIn
        end
        else begin
          PCNext = JumpRegister;
          EPC = JumpRegister;
          PCWr = 1'b1;
          EPCWr = 1'b0;
          eret = 1'b0;
          IFIDRst = 1'b1;
          IDExRst = 1'b0;
          ExMeRst = 1'b0;
          CPSig = 4'd0; //INTIn
        end
      end

      default: begin
        PCNext = PCIF + 4;
        EPC = EPCIn;
        PCWr = 1'b1;
        EPCWr = 1'b0;
        eret = 1'b0;
        IFIDRst = 1'b0;
        IDExRst = 1'b0;
        ExMeRst = 1'b0;
        CPSig = 4'd0;
      end
    endcase
  end
end

always @(posedge clk or posedge rst) begin
	if(rst == 1) begin
		PCTemp <= 32'd0;
		state <= 0;
	end
	else begin
	  if(PCWrIn == 0) begin
		 //In this case, ovf can't happen
		 if(INTIn == 1 && Status[0] == 1) begin
			PCTemp <= PCTemp;
			state <= 0;
		 end
		 else if (SysIn == 1 && Status[1] == 1 && state == 0) begin
			PCTemp <= 32'h8;
			state <= 0;
		 end
		 else if (SysIn == 1 && Status[1] == 1 && state != 0) begin
			//at this stage, an exception won't happen because of mighty branch or jump
			PCTemp <= PCTemp;
			state <= state;
		 end
		 else if (UnimplIn == 1 && Status[2] == 1 && state == 0) begin
			PCTemp <= PCTemp;
			state <= 0;
		 end
		 else if (UnimplIn == 1 && Status[2] == 1 && state != 0) begin
			PCTemp <= PCTemp;
			state <= state;
		 end
		 else if (OvfIn == 1 && Status[3] == 1) begin
			PCTemp <= PCTemp;
			state <= 0;
		 end
		 else begin
			PCTemp <= PCTemp;
			state <= state;
		 end
	  end
	  else begin
		 case (state)
			0: begin
			  if(INTIn == 1 && Status[0] == 1) begin
				 PCTemp <= PCTemp;
				 state <= 0;
			  end
			  else if (OvfIn == 1 && Status[3] == 1) begin
				 PCTemp <= PCTemp;
				 state <= 0;
			  end
			  else if (UnimplIn == 1 && Status[2] == 1) begin
				 PCTemp <= PCTemp;
				 state <= 0;
			  end
			  else if (SysIn == 1 && Status[1] == 1) begin
				 PCTemp <= PCTemp;
				 state <= 0;
			  end
			  else begin
				 case (PCSrc)
				 `PLUS4_SRC: begin
					PCTemp <= PCIF + 4;
					state <= 0;
				 end
				 `BRANCH_SRC: begin
					PCTemp <= PCIF + {{14{Offset[15]}},Offset, {2'b0}} + 4;
					state <= 2;
				 end
				 `J_SRC: begin
					PCTemp <= {{PCIF[31:28]},JumpTarget, {2'b0}};
					state <= 0;
				 end
				 `JR_SRC: begin
					PCTemp <= PCIF + 4;
					state <= 1;
				 end
				 `INT_SRC: begin
					PCTemp <= PCIF + 4;
					state <= 0;
				 end
				 `EPC_SRC: begin
					PCTemp <= EPC;
					state <= 0;
				 end
				 default: begin
					PCTemp <= PCIF + 4;
					state <= 0;
				 end
				 endcase
			  end
			end
			1: begin
			  if(INTIn == 1 && Status[0] == 1) begin
				 PCTemp <= PCTemp;
				 state <= 0;
			  end
			  else if (OvfIn == 1 && Status[3] == 1) begin
				 PCTemp <= PCTemp;
				 state <= 0;
			  end
			  else if (UnimplIn == 1 && Status[2] == 1) begin
				 //this can't  happen 
				 PCTemp <= PCTemp;
				 state <= 0;
			  end
			  else if (SysIn == 1 && Status[1] == 1) begin
				 //this can't  happen 
				 PCTemp <= PCTemp;
				 state <= 0;
			  end
			  else begin
				 PCTemp <= PCTemp;
				 state <= 4;
			  end
			end
			2: begin
			  if(INTIn == 1 && Status[0] == 1) begin
				 PCTemp <= PCTemp;
				 state <= 0;
			  end
			  else if (OvfIn == 1 && Status[3] == 1) begin
				 PCTemp <= PCTemp;
				 state <= 0;
			  end
			  else if (UnimplIn == 1 && Status[2] == 1) begin
				 PCTemp <= PCTemp;
				 state <= 3;
			  end
			  else if (SysIn == 1 && Status[1] == 1) begin
				 PCTemp <= PCTemp;
				 state <= 3;
			  end
			  else begin
				 PCTemp <= PCTemp;
				 state <= 3;
			  end
			end
			3: begin
			  if (BranchEx == 1) begin
				 PCTemp <= PCTemp;
					state <= 0;
			  end else begin
				 case (PCSrc)
				 `PLUS4_SRC: begin
					PCTemp <= PCTemp;
					state <= 0;
				 end
				 `BRANCH_SRC: begin
					PCTemp <= PCIF + {{14{Offset[15]}},Offset, {2'b0}} + 4;
					state <= 2;
				 end
				 `J_SRC: begin
					PCTemp <= PCTemp;
					state <= 0;
				 end
				 `JR_SRC: begin
					PCTemp <= PCTemp;
					state <= 1;
				 end
				 `INT_SRC: begin
					PCTemp <= PCTemp;
					state <= 0;
				 end
				 `EPC_SRC: begin
					PCTemp <= EPC;
					state <= 0;
				 end
				 default: begin
					PCTemp <= PCTemp;
					state <= 0;
				 end
				 endcase
			  end
			end
			4: begin
			  PCTemp <= PCTemp;
			  state <= 0;
			end

			default: begin
			  PCTemp <= PCTemp;
			  state <= 0;
			end
		 endcase
	  end
	end
end



endmodule // 