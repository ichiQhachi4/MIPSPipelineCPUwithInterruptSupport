module dm_4k(addr, be, din, DMWr, clk, dout);
  input[11:2] addr;
  input[3:0] be;
  input[31:0] din;
  input DMWr;
  input clk;
  output[31:0] dout;
  reg [31:0] DataMem [1023:0];
  assign dout[31:0] = DataMem[addr];
	integer fd, eof, cnt;

	initial
	begin
	  cnt = 0;
	  eof = 0;
	  fd = $fopen("scd_intr.dat","r");
	  while(eof != -1)
	  begin
	    eof = $fscanf(fd, "%x", DataMem[cnt]);
	    cnt = cnt + 1;
	  end

	  for(cnt = cnt - 1;cnt < 1024; cnt = cnt + 1)
	  begin
	   DataMem[cnt] = 32'd0;
	  end	          
	end

    always @(posedge clk) begin
      if (DMWr & be == 4'b1111) 
        DataMem[addr] <= din;
      else if(DMWr & be == 4'b0011)
        DataMem[addr] [15:0] <= din[15:0];
      else if(DMWr & be == 4'b1100)
        DataMem[addr] [31:16] <= din[15:0];
      else if(DMWr & be == 4'b0001)
        DataMem[addr] [7:0] <= din[7:0];
      else if(DMWr & be == 4'b0010)
        DataMem[addr] [15:8] <= din[7:0];
      else if(DMWr & be == 4'b0100)
        DataMem[addr] [23:16] <= din[7:0];
      else if(DMWr & be == 4'b1000)
        DataMem[addr] [31:24] <= din[7:0];
    end

endmodule
