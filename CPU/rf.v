module rf(clk, rst, RFWr, wa, din, ra0, ra1, dout0, dout1, a3);
    input clk;
    input rst;
    input RFWr;
    input[4:0] wa;
    input[31:0] din;
    input[4:0] ra0;
    input[4:0] ra1;
    output[31:0] dout0;
    output[31:0] dout1;
    reg [31:0] rf [31:0];
    assign dout0 = rf[ra0];
    assign dout1 = rf[ra1];
  integer i;
  
	input [31:0] a3;
	assign a3 = rf[7];

  always @(negedge clk ,posedge rst) begin
    if (rst) begin
      rf[28] = 32'h0000_1800;
    end
    else
    if(RFWr) begin
      rf[wa] = (wa == 0 ? 32'd0 : din);       

    end
  end


endmodule