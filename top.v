module top(
  input clk_100mhz,
  input RSTN,
  input [3:0] BTN_y,
  input [15:0] SW,


  output RDY,
  output readn,
  output seg_clk,
  output seg_sout,
  output SEG_PEN,
  output seg_clrn,
  output led_clk,
  output led_sout,
  output LED_PEN,
  output led_clrn,
  output [4:0] BTN_x,
  output CR
);

wire Clk_CPU;
wire rst;
wire [31:0] inst;
wire [31:0] Data_in;
wire mem_w;
//U1 -- U4
wire [31:0] PC;
wire [31:0] Addr_out;
wire [31:0] Data_out;
wire INTERRUPT;

wire [9:0] ram_addr;
//U3 -- U4
wire ram_WE;
//ram write enable
wire [31:0] ram_DIN;
wire [31:0] ram_DOUT;
//U3 -- U4 data in/out

wire [3:0] BTN_OK;
wire [15:0] SW_OK;
wire [15:0] LED_out;
wire [31:0] Counter_out;
wire counter1_out;
wire counter2_out;
wire GPIOF0;
wire GPIOE0;
//U4 -- U5 EN
wire counter_WE;
//counter_we write enable
wire [31:0] CPU2IO;

wire IO_clk;
assign IO_clk = ~Clk_CPU;
wire [31:0] Div;
wire [31:0] Disp_num;
wire [7:0] point_out;
wire [7:0] LE_out;

wire [4:0] Key_out;
wire [31:0] Ai;
wire [31:0] Bi;
wire [7:0] blink;

wire [1:0] counter_ch;
//U7 -- U10 counter_set -- counter_ch
wire[31:0] Status;


wire [3:0] Pulse;
wire [31:0] Userdefine;
wire [31:0] Cause;
wire [31:0] a3;
PLCPU U1(
    .clk        (Clk_CPU),
    .rst      (rst),
    .MIO_ready  (),
			
    .inst_in    (inst),
    .Data_in    (Data_in),	
			
    .mem_w      (mem_w),
    .PC_out     (PC),
    .Addr_out   (Addr_out),
    .Data_out   (Data_out), 
    .CPU_MIO    (),
    .INT        (counter0_out),
	 .StatusOut (Status),
	 .Userdefine (Userdefine),
	 .Cause		(Cause),
	 .a3			(a3)

);

ROM_D U2(
    .a  (PC[11:2]),
    .spo(inst)
);

RAM_B U3(
    .addra  (ram_addr),
    .wea    (ram_WE),
    .dina   (ram_DIN),
    .clka   (~clk_100mhz),
    .douta  (ram_DOUT)
);


MIO_BUS U4(
    .clk            (clk_100mhz),
	.rst            (rst),
	.BTN            (BTN_OK),
	.SW             (SW_OK),
	.mem_w          (mem_w),
	.Cpu_data2bus   (Data_out),				//data from CPU
	.addr_bus       (Addr_out),
	.ram_data_out   (ram_DOUT),
	.led_out        (LED_out),
	.counter_out    (Counter_out),
	.counter0_out   (counter0_out),
	.counter1_out   (counter1_out),
	.counter2_out   (counter2_out),
					
	.Cpu_data4bus   (Data_in),				//write to CPU
	.ram_data_in    (ram_DIN),				//from CPU write to Memory
	.ram_addr       (ram_addr),						//Memory Address signals
	.data_ram_we    (ram_WE),
	.GPIOf0000000_we(GPIOF0),
	.GPIOe0000000_we(GPIOE0),
	.counter_we     (counter_WE),
	.Peripheral_in  (CPU2IO)
);

SEnter_2_32 M4(
    .clk        (clk_100mhz), 
    .BTN        (BTN_OK[2:0]), 
    .Ctrl       ({SW_OK[7:5], SW_OK[15], SW_OK[0]}), 
    .D_ready    (RDY), 
    .Din        (Key_out), 
    .readn      (readn), 
    .Ai         (Ai), 
    .Bi         (Bi), 
    .blink      (blink)
);

Multi_8CH32 U5(
    .clk        (IO_clk),
    .rst        (rst),
    .EN         (GPIOE0),
    .Test       (SW_OK[7:5]),
    .point_in   ({2{Div}}),
    .LES        (64'b0),
    .Data0      (CPU2IO),
	 
    //.data1      ({2'b0, {PC[31:2]}}),
	 .data1      (Status),
    .data2      (Userdefine),
    .data3      (inst),
    .data4      (Addr_out),
    .data5      (Data_out),
    .data6      (a3),
    .data7      (PC),
    .Disp_num   (Disp_num),
    .point_out  (point_out),
    .LE_out     (LE_out)
);

SSeg7_Dev U6(
    .clk        (clk_100mhz), 
    .rst        (rst), 
    .Start      (Div[20]), 
    .SW0        (SW_OK[0]), 
    .flash      (Div[25]),
    .Hexs       (Disp_num), 
    .point      (point_out), 
    .LES        (LE_out), 
    .seg_clk    (seg_clk), 
    .seg_sout   (seg_sout), 
    .SEG_PEN    (SEG_PEN), 
    .seg_clrn   (seg_clrn)
);

SPIO U7(
    .clk        (IO_clk), 
    .rst        (rst), 
    .Start      (Div[20]), 
    .led_clk    (led_clk), 
    .led_sout   (led_sout),
    .led_clrn   (led_clrn), 
    .LED_PEN    (LED_PEN), 
    .EN         (GPIOF0), 
    .P_Data     (CPU2IO), 
    .counter_set(counter_ch), 
    .LED_out    (LED_out), 
    .GPIOf0     ()
);

clk_div U8(
    .clk    (clk_100mhz), 
    .rst    (rst), 
    .SW2    (SW_OK[2]), 
    .clkdiv (Div), 
    .Clk_CPU(Clk_CPU)
);

SAnti_jitter U9(
    .clk(clk_100mhz), 
    .RSTN(RSTN), 
    .readn(readn), 
    .Key_y(BTN_y), 
    .Key_x(BTN_x), 
    .SW(SW), 
    .Key_out(Key_out), 
    .Key_ready(RDY), 
    .pulse_out(Pulse),
    .BTN_OK(BTN_OK), 
    .SW_OK(SW_OK), 
    .CR(CR), 
    .rst(rst)
);

Counter_x U10(
    .clk        (IO_clk),
    .rst        (rst),
    .clk0       (Div[6]),
    .clk1       (Div[9]),
    .clk2       (Div[11]),
    .counter_we (counter_WE),
    .counter_val(CPU2IO),
    .counter_ch (counter_ch),
    .counter0_OUT(counter0_out),
    .counter1_OUT(counter1_out),
    .counter2_OUT(counter2_out),
    .counter_out (Counter_out)

);


endmodule // top
