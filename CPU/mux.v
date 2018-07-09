module mux2to1(
  data0,
  data1,
  select,
  out
);
    parameter bitwidth = 16; 
    input [bitwidth - 1 : 0] data0;
    input [bitwidth - 1 : 0] data1;
    input select;
    output [bitwidth - 1 : 0] out;
    reg [bitwidth - 1 : 0] out;

    always @(select or data0 or data1) begin
      if(select)
        out <= data1;
			else
				out <= data0;	
    end

endmodule // mux2to1

module mux4to1(
	data0,
	data1,
	data2,
	data3,

  select,
	out
);
  parameter bitwidth = 16; 
  input [bitwidth - 1 : 0] data0;
  input [bitwidth - 1 : 0] data1;
	input [bitwidth - 1 : 0] data2;
	input [bitwidth - 1 : 0] data3;
	input[1 : 0] select;
	output [bitwidth - 1 : 0] out;
  reg [bitwidth - 1 : 0] out;

    always @(select or data0 or data1 or data2 or data3) begin
			case (select)
				2'b00: out <= data0;
				2'b01: out <= data1;
				2'b10: out <= data2;
				2'b11: out <= data3;
				default: out <= 0;
			endcase
    end

endmodule // mux4to1

module mux8to1(
  data0,
  data1,
	data2,
	data3,
	data4,
  data5,
	data6,
	data7,

  select,

  out
);
  parameter bitwidth = 16; 
  input [bitwidth - 1 : 0] data0;
  input [bitwidth - 1 : 0] data1;
	input [bitwidth - 1 : 0] data2;
	input [bitwidth - 1 : 0] data3;
  input [bitwidth - 1 : 0] data4;
  input [bitwidth - 1 : 0] data5;
	input [bitwidth - 1 : 0] data6;
	input [bitwidth - 1 : 0] data7;
	input[2 : 0] select;
	output [bitwidth - 1 : 0] out;
  reg [bitwidth - 1 : 0] out;


    always @(select or data0 or data1 or data2 or data3 or data4 or data5 or data6 or data7) begin
			case (select)
				3'b000: out <= data0;
				3'b001: out <= data1;
				3'b010: out <= data2;
				3'b011: out <= data3;
				3'b100: out <= data4;
				3'b101: out <= data5;
				3'b110: out <= data6;
				3'b111: out <= data7;
				default: out <= 0;
			endcase
    end

endmodule // mux8to1

module mux16to1(
  data0,
  data1,
	data2,
	data3,
	data4,
  data5,
	data6,
	data7,
  data8,
  data9,
	data10,
	data11,
	data12,
  data13,
	data14,
	data15,
  select,
  out
);
  parameter bitwidth = 16; //
  input [bitwidth - 1 : 0] data0;
  input [bitwidth - 1 : 0] data1;
	input [bitwidth - 1 : 0] data2;
	input [bitwidth - 1 : 0] data3;
	input [bitwidth - 1 : 0] data4;
  input [bitwidth - 1 : 0] data5;
	input [bitwidth - 1 : 0] data6;
	input [bitwidth - 1 : 0] data7;
  input [bitwidth - 1 : 0] data8;
  input [bitwidth - 1 : 0] data9;
	input [bitwidth - 1 : 0] data10;
	input [bitwidth - 1 : 0] data11;
	input [bitwidth - 1 : 0] data12;
  input [bitwidth - 1 : 0] data13;
	input [bitwidth - 1 : 0] data14;
	input [bitwidth - 1 : 0] data15;
	input [3:0] select;
	output [bitwidth-1 : 0] out;
  reg [bitwidth - 1 : 0] out;

    always @(select or data0 or data1 or data2 or data3 or data4 or data5 or data6 or data7
		 or data8 or data9 or data10 or data11 or data12 or data13 or data14 or data15) begin
			case (select)
				4'h0: out <= data0;
				4'h1: out <= data1;
				4'h2: out <= data2;
				4'h3: out <= data3;
				4'h4: out <= data4;
				4'h5: out <= data5;
				4'h6: out <= data6;
				4'h7: out <= data7;
        4'h8: out <= data8;
				4'h9: out <= data9;
				4'ha: out <= data10;
				4'hb: out <= data11;
				4'hc: out <= data12;
				4'hd: out <= data13;
				4'he: out <= data14;
				4'hf: out <= data15;
				default: out <= 0;
			endcase
    end

endmodule // mux16to1
