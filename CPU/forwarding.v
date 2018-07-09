`include "./ctrl_encode_define.v"
`include "./global_def.v"
`include "./instruction_def.v"
module FU(
  clk, rst, InstrIDEx, RFRd_ID, WA_Ex, RFWr_Ex, WA_Me, RFWr_Me, FWDSigA, FWDSigB, InstrExMe
);

input clk;
input rst;
input [31:0] InstrIDEx;
input [1:0] RFRd_ID;
//读取寄存器的种类 ID阶段
input [4:0] WA_Ex;
//这是经过MUX以后的，这里要单独设一个mux
//Ex阶段写入寄存器
input RFWr_Ex;
//是否需要写入寄存器
//input DMWr_Ex;
//是否是lw类信号
input [4:0] WA_Me;
//Me阶段写入寄存器的种类
input RFWr_Me;
//是否需要写入寄存器
//input DMWr_Me;
//是否是lw类信号
input [31:0] InstrExMe;
output[1:0] FWDSigA;
output[1:0] FWDSigB;
reg [1:0] FWDSigA;
reg [1:0] FWDSigB;

//Ex Hazard 具有优先权
always @(*) begin
  if(RFWr_Ex == 1'b1 && InstrIDEx `RSFLD == WA_Ex && InstrExMe [31:21] != 11'b01000000000) begin
    FWDSigA = `FWD_EX;
  end
  else if (RFWr_Ex == 1'b1 && InstrIDEx `RSFLD == WA_Ex && InstrExMe [31:21] == 11'b01000000000) begin
    FWDSigA = 2'd3;
  end
  else if(RFWr_Me == 1'b1 && InstrIDEx `RSFLD == WA_Me) begin
    FWDSigA = `FWD_ME;
  end
  else begin
    FWDSigA = `NOFWD;
  end
end

always @(*) begin
  if(RFWr_Ex == 1'b1 && InstrIDEx `RTFLD == WA_Ex && InstrExMe [31:21] != 11'b01000000000) begin
    FWDSigB = `FWD_EX;
  end
  else if (RFWr_Ex == 1'b1 && InstrIDEx `RTFLD == WA_Ex && InstrExMe [31:21] == 11'b01000000000) begin
    FWDSigB = 2'd3;
  end
  else if(RFWr_Me == 1'b1 && InstrIDEx `RTFLD == WA_Me) begin
    FWDSigB = `FWD_ME;
  end
  else begin
    FWDSigB = `NOFWD;
  end
end

endmodule // Forwarding Unit
