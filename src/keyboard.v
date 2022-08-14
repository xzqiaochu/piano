module keyboard
#(
parameter CLK_FREQ = 120_000_000, 
parameter MIN_SHIFT = 3,
parameter MAX_SHIFT = 6,
parameter SCAN_FREQ = 100
)
(
input wire clk, // 输入时钟
input wire rst, // 复位信号，低电平有效
input wire [12:0] key, // 钢琴键（共13个），低电平有效
input wire [1:0] pitch, // 升音/降音键，低电平有效
output reg clk_msg = 1'b0, // 输出信号的时钟，上升沿有效
output reg [7:0] msg = 1'b0 // 最高位表示类型（1打开音符，0关闭音符），其他位为音符MIDI编码
);


/**************************************** wire变量 ****************************************/
wire clk_scan; // 按键扫描信号，用于消抖
wire clk_scan_13x;


/**************************************** reg变量 ****************************************/
reg [1:0] sta = 2'b00;
reg [7:0] scan_i = 1'b0; // 扫描第几个按键（状态机）
reg [12:0] key_last_sta = 13'b1_111_111_111_111; // 保存上一次按键状态，低电平有效

reg [7:0] shift = 4; // 第几个八度
reg [1:0] pitch_last_sta = 2'b11;


/**************************************** 子模块实例化 ****************************************/
clkdiv clkdiv_u1 (clk, rst, CLK_FREQ / SCAN_FREQ, clk_scan); // 按键扫描信号
clkdiv clkdiv_u2 (clk, rst, CLK_FREQ / (SCAN_FREQ*13), clk_scan_13x);


/**************************************** 时序逻辑 ****************************************/
// 琴键扫描
always @(posedge clk_scan_13x or posedge rst) begin
	if (rst) begin
		clk_msg = 1'b0;
		msg = 1'b0;
		sta = 0;
		scan_i = 1'b0;
		key_last_sta = 13'b1_111_111_111_111;
	end
	else begin
		case (sta)
			2'b00: begin
				if (key_last_sta[scan_i] != key[scan_i]) begin
					msg = (shift+1)*12+scan_i;
					msg[7] = ~key[scan_i]; // 低电平有效，检测到按下/释放一个音符
					key_last_sta[scan_i] = key[scan_i];
					sta = 2'b01;
				end
				if (scan_i == 12)
					scan_i = 1'b0;
				else
					scan_i = scan_i + 1'b1;
			end
			2'b01: begin
				clk_msg = 1'b1;
				sta = 2'b10;
			end
			2'b10: begin
				clk_msg = 1'b0;
				sta = 2'b00;
			end
		endcase
	end
end

// 升降音键扫描
always @(posedge clk_scan or posedge rst) begin
	if (rst) begin
		shift = 4;
		pitch_last_sta = 2'b11;
	end	
	else begin
		// 降音键
		if (pitch_last_sta[0] & ~pitch[0]) begin // 低电平有效
			if (shift > MIN_SHIFT)
				shift = shift - 1'b1;
		end
		// 升音键
		if (pitch_last_sta[1] & ~pitch[1]) begin
			if (shift < MAX_SHIFT)
				shift = shift + 1'b1;
		end
		// 保存状态
		pitch_last_sta = pitch;
	end
end

endmodule