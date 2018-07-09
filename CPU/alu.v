`include "./ctrl_encode_define.v"
`include "./instruction_def.v"


module alu(alurst,Zero,din0,din1,ALUOp, Sign, Overflow);

	input  [31:0] 		din0;	
	input  [31:0]		din1;
	input  [3:0]		ALUOp;	
	input Sign;
	output Overflow;
	output[31:0] alurst;	
	output Zero;	
	reg[31:0] mask;
	reg[31:0] alurst;		
	reg Zero;
	reg Overflow;
	
	wire[32:0] diftemp = {{din0[31]}, din0} - {{din1[31]}, din1};
	
	initial
	begin
		Zero <= 0;
		alurst <= 32'b0;
	end	
	
	

	always@(din0 or din1 or ALUOp)
	begin
	  mask = {32{din1[31]}} << (6'd32 - {1'd0, {din0[4:0]}});
	  case(ALUOp)
	    `ADD_ALU: alurst = din0 + din1;
	    `SUB_ALU: alurst = din0 - din1;
	    `OR_ALU : alurst = din0 | din1;
	    `AND_ALU: alurst = din0 & din1;
	    `XOR_ALU: alurst = din0 ^ din1;
	    `NOR_ALU: alurst = ~(din0 | din1);
		`LUI_ALU: alurst = din1;
	    `COMP_ALU: alurst = {{31{1'd0}}, {diftemp[32]}};
	    `COMPU_ALU: alurst = (din0 < din1 ? 32'd1: 32'd0);
	    `SLL_ALU: alurst = din1 << din0[4:0];
	    `SRL_ALU: alurst = din1 >> din0[4:0];
	    `SRA_ALU: alurst = mask | (din1 >> din0[4:0]);
		default: alurst = 32'd0;
	    endcase
	end
	
	always@(din0 or din1 or ALUOp)
	begin
		Zero = (din0 == din1);
  	end

  always@(*) begin
	if (Sign == 1) begin
	  case (ALUOp)
		`ADD_ALU: Overflow = (din0[31] & din1[31] & ~alurst[31]) | (~din0[31] & ~din1[31] & alurst[31]);
		`SUB_ALU: Overflow = (~din0[31] & din1[31] & alurst[31]) | (din0[31] & ~din1[31] & ~alurst[31]);
		default: Overflow = 0;
	  endcase
	end else begin
	  case (ALUOp)
		`ADD_ALU: Overflow = (din0 > alurst) || (din1 > alurst)? 1:0 ;
		`SUB_ALU: Overflow =  (din0 < alurst) ? 1:0;
		default: Overflow = 0;
	  endcase
	end
  end
  


endmodule

