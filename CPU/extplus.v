`include "./ctrl_encode_define.v"


module extplus(
  din[31:0],
  be[3:0],
  dout[31:0]
);
input[31:0] din;
input[3:0] be;
output[31:0] dout;
reg[31:0] dout;

always @(din or be) begin
  if (be[3] == 1) begin
    case (be[2:0])
      `BYTE0_BE: dout = {24'hFFFFFF, din[7:0]};
      `BYTE1_BE: dout = {24'hFFFFFF, din[15:8]};
      `BYTE2_BE: dout = {24'hFFFFFF, din[23:16]};
      `BYTE3_BE: dout = {24'hFFFFFF, din[31:24]};
      `HALF0_BE: dout = {16'hFFFF, din[15:0]};
      `HALF1_BE: dout = {16'hFFFF, din[31:16]};
      `WORD_BE:  dout = din;
      default: dout = 32'dx;
    endcase
  end else begin
    case (be[2:0])
      `BYTE0_BE: dout = {24'h0, din[7:0]};
      `BYTE1_BE: dout = {24'h0, din[15:8]};
      `BYTE2_BE: dout = {24'h0, din[23:16]};
      `BYTE3_BE: dout = {24'h0, din[31:24]};
      `HALF0_BE: dout = {16'h0, din[15:0]};
      `HALF1_BE: dout = {16'h0, din[31:16]}; 
      default: dout = 32'dx;
    endcase
  end
end

endmodule // extplus