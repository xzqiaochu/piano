module note
#(
parameter CLK_FREQ = 120_000_000,
parameter THETA_WIDTH = 8,
parameter AM_WIDTH = 8
)
(
input wire clk,
input wire rst,
input wire [7:0] noteid,
output reg signed [AM_WIDTH-1:0] am = 1'b0
);

`include "noteid2freq.v"

wire [31:0] div_n = (noteid == 0) ? (CLK_FREQ + 1) : (NOTEID2FREQ[(noteid-NOTEID_OFFSET)*16+:16] << THETA_WIDTH);
wire [31:0] clk_theta_divx;
wire clk_theta;
wire ClkEn = (clk_theta_divx == 0) ? 1'b0 : 1'b1;
wire signed [AM_WIDTH-1:0] am_raw;

reg [7:0] last_noteid = 1'b0;
reg [THETA_WIDTH-1:0] theta = 1'b0;
reg [15:0] a = 65535;

div div_u (clk, rst, CLK_FREQ, div_n, clk_theta_divx);
clkdiv clkdiv_u (clk, rst, clk_theta_divx, clk_theta);
sin sin_u (.Clock(clk), .ClkEn(ClkEn), .Reset(rst), .Theta(theta), .Sine(am_raw));

// refresh theta
always @(posedge clk_theta or posedge rst) begin
	if (rst)
		theta <= 1'b0;
	else if (theta == (1<<AM_WIDTH)-1)
		theta <= 1'b0;
	else
		theta <= theta + 1'b1;
end

reg [31:0] fixbug1;
reg [31:0] fixbug2;
reg [AM_WIDTH-2:0] am_u;

always @(posedge clk_theta or posedge rst) begin
	if (rst) begin
		am = 1'b0;
		a = 65535;
	end
	else if (noteid != last_noteid) begin
		a = 65535;
		last_noteid = noteid;
	end
	else if (clk_theta_divx != 0) begin
		if (am_raw[AM_WIDTH-1]) begin
			am_u = ~(am_raw[AM_WIDTH-2:0] - 1'b1);
			fixbug2 = (am_u * a) >> 16;
			am = {1'b1, ~fixbug2[AM_WIDTH-2:0]} + 1'b1; // 同fixbug1
		end
		else begin
			fixbug1 = (am_raw[AM_WIDTH-2:0] * a) >> 16;
			am = {1'b0, fixbug1[AM_WIDTH-2:0]}; // 如果直接赋值会有问题，在乘法那一步编译器认为左边被赋值的变量宽度太小，会把结果截断
		end
		
		if (theta == 0) // 满一周期，更新振幅
			a = (a * 1020) >> 10; // (1022/1024)^400 = 0.46 即400个周期后衰减为46%
	end
	else
		am = 1'b0;
end


endmodule