module regtemp(clk, rst, regWr, din, dout);
  input clk;
  input rst;
  input regWr;
  input[31:0] din;
  output[31:0] dout;
  reg[31:0] dout;
  
  always@(posedge clk or posedge rst)
  begin
    if(rst)
      dout <= 32'd0;
    else if(regWr)
      dout <= din;
  end
endmodule

