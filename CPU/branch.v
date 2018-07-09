`include "./global_def.v"
`include "./instruction_def.v"

module branch(
  ALURstEx, ZeroEx, InstrEx,

  BranchEx
);

input [31:0] ALURstEx;
input ZeroEx;
input [31:0] InstrEx;



output BranchEx;
reg BranchEx;



always @(*) begin
  case (InstrEx [31:26])
    `REGIMM: begin
      if (InstrEx [20:16] == `BLTZ) begin
        BranchEx = ALURstEx[0];
      end else begin
        BranchEx = !ALURstEx[0];
      end
    end
    `BEQ_OP: BranchEx = ZeroEx;
    `BNE_OP: BranchEx = !ZeroEx;
    `BLEZ_OP: BranchEx = ALURstEx[0] | ZeroEx;
    `BGTZ_OP: BranchEx = !(ALURstEx[0] |ZeroEx);
    default: BranchEx = 1'b0;
  endcase
end



endmodule // branch