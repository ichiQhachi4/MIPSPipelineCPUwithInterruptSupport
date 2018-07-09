`include "./rf.v"
`include "./ctrl_encode_define.v"
module CP0(
  input clk,
  input rst,
  input [3:0] Signal,
  //Signal[0] = INT, Signal[1] = Sys, Signal[2] = Unimpl, Signal[3] = Ovf
  input CPWr,
  input [4:0] CPRA,
  input [2:0]PCSrc,
  input [31:0] CPWD,
  input [31:0] EPCIn,
  //generate from NPC
  input [4:0] CPWA,
  output [31:0] CPRD,
  output [31:0] EPCOut,
  output [31:0] StatusOut,
  output [31:0] CauseOut,
  //send to NPC
  input PCWr,
  input EPCWr,
  input eret
);

//#12
reg [31:0] Cause;
//#13
reg [31:0] Status;
//#14
reg [31:0] EPC;
reg [31:0] StatusUpdate;
reg [31:0] CauseUpdate;
reg [31:0] ReadData;

assign EPCOut = EPC;
assign StatusOut = Status;
assign CPRD = ReadData;
assign CauseOut = Cause;
initial
begin
  Status <= 32'd0;
  EPC <= 32'd0;
  Cause <= 32'd0;
  StatusUpdate <= 32'd0;
  CauseUpdate <= 32'b0;
  ReadData <= 32'd0;
end

always @(negedge clk or posedge rst) begin
	if(rst == 1) begin
		Status <= 32'd0;
		Cause <= 32'd0;
		EPC <= 32'd0;
	end
	else begin
	  if (CPWr) begin
		 case (CPWA)
			5'd12: begin
			  Status <= CPWD;
			  Cause <= CauseUpdate;
			  EPC <= EPC;
			end
			5'd13: begin
			  Cause <= CPWD;
			  Status <= StatusUpdate;
			  EPC <= EPC;
			end
			5'd14: begin
			  EPC <= CPWD;
			  Cause <= CauseUpdate;
			  Status <= StatusUpdate;
			end
		 endcase
	  end else if(EPCWr) begin
		 Cause <= CauseUpdate;
		 Status <= StatusUpdate;
		 EPC <= EPCIn;
	  end 
	  else begin
		 Cause <= CauseUpdate;
		 Status <= StatusUpdate;
		 EPC <= EPC;
	  end
	end
end

always @(*) begin
  case (CPRA)
    5'd12: ReadData = Status;
    5'd13: ReadData = Cause;
    5'd14: ReadData = EPC; 
    default: ReadData = 32'd0;
  endcase
end

always @(*) begin
  if(Signal == 4'd1) begin
    StatusUpdate = Status << 4;
    CauseUpdate = {Cause[31:4], 2'd0, Cause[1:0]};
  end
  else if (Signal == 4'd2) begin
    StatusUpdate = Status << 4;
    CauseUpdate = {Cause[31:4], 2'd1, Cause[1:0]};
  end
  else if (Signal == 4'd4) begin
    StatusUpdate = Status << 4;
    CauseUpdate = {Cause[31:4], 2'd2, Cause[1:0]};
  end
  else if (Signal == 4'd8) begin
    StatusUpdate = Status << 4;
    CauseUpdate = {Cause[31:4], 2'd3, Cause[1:0]};
  end
  else if (eret) begin
    StatusUpdate = Status >> 4;
    CauseUpdate = {Cause[31:4], 2'd0, Cause[1:0]};
  end
  else begin
    StatusUpdate = Status;
    CauseUpdate = Cause;
  end

end

endmodule // CP0
