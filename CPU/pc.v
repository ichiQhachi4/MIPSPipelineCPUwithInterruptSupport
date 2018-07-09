
module pc(clk, rst, PCin, PCWr, PCout);
  input clk;
  input rst;
  input[31:0] PCin;
  input PCWr;
  output[31:0] PCout;
  reg [31:0] PCout;
  
  reg[31:0] temp;
  


  always@(posedge clk or posedge rst)
  begin
      if(rst == 1)
		begin
			PCout <= 32'h0000_0000;
		end
		else begin
			PCout <= temp;
		end
  end
  
  
  always@(negedge clk or posedge rst)
  begin
    if(rst == 1) begin
		temp <= 32'd0;
	 end
	 else begin
		 if(PCWr)
			temp <= PCin;
		 else
			temp <= temp;
	 end
  end
  
endmodule