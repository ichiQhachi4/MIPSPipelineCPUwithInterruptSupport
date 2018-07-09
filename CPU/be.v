`include "./instruction_def.v"
`include "./global_def.v"
`include "./ctrl_encode_define.v"

module begenerator(clk, rst, InstrMe, ALURst, be);
input clk,rst;

input [31:0] InstrMe;
input [31:0] ALURst;

output [3:0] be;
reg [3:0] be;

always @(posedge clk or InstrMe) begin
  case (InstrMe `OPFLD)
  `LB_OP: be = {2'b10, {ALURst[1:0]}};
  `LH_OP: be = {3'b110, {ALURst[1]}};
  `LW_OP: be = {1'b1, `WORD_BE};
  `LBU_OP:be = {2'b00, {ALURst[1:0]}};
  `LHU_OP:be = {3'b010, {ALURst[1]}};
  `SB_OP: be = 4'b0001 << ALURst[1:0];
  `SH_OP: be = ALURst[1] ? 4'b1100 : 4'b0011;
  `SW_OP: be = 4'b1111;
  default:be = 4'b1111;
  endcase

end

endmodule // begenerator 产生读/写是能信号