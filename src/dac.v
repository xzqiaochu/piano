module dac
#(
parameter CLK_FREQ = 120_000_000,
parameter AM_WIDTH = 8,
parameter PWM_FREQ = 500_000
)
(
input wire clk, // input clock
input wire rst, // low level active
input wire [AM_WIDTH-1:0] am, // input amplitude
output reg pwm = 1'b0 // output pwm
);

localparam ARR = CLK_FREQ / PWM_FREQ - 1;

reg [31:0] cnt = 1'b0;
reg [31:0] ccr = 1'b0;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		cnt <= 1'b0;
		ccr <= 1'b0;
	end
	else begin
		if (cnt >= ARR) begin
			cnt <= 1'b0;
			ccr <= (am * ARR) >> AM_WIDTH;
		end
		else
			cnt <= cnt + 1'b1;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst)
		pwm <= 1'b0;
	else
		pwm <= cnt > ccr;

end

endmodule