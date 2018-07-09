module im_4k(dout,addr);
 
	input [11:2] addr;
	output [31:0]  dout;
	reg[31:0] dout;
	reg [31:0]  IMem[1023:0];
	integer fd, eof, cnt;
	
	initial
	begin
	  cnt = 0;
	  eof = 0;
	  fd = $fopen("sci_intr.dat","r");
	  while(eof != -1)
	  begin
	    eof = $fscanf(fd, "%x", IMem[cnt]);
	    cnt = cnt + 1;
	  end

	  for(cnt = cnt - 1;cnt < 1024; cnt = cnt + 1)
	  begin
	   IMem[cnt] = 32'd0;
	  end	       
	  
	  
	end

	always@(addr)
	begin
		dout <= IMem[addr];
	end
	
endmodule
