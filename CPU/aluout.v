module aluout(clk, rst, din, dout);
  input clk;
  input rst;
  input[31:0] din;
  output[31:0] dout;
  
  reg[31:0] dout;
  
  always@(posedge clk or negedge rst)
  begin
    if(!rst)
      dout <= 32'd0;
    else
      dout <= din;
  end
   
    
endmodule
