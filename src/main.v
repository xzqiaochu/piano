module main
#(
parameter PCLK_FREQ = 12_000_000,
parameter PLLX = 10
)
(
input wire pclk, // ����12MHz
input wire rst_n, // ��λ�źţ��͵�ƽ��Ч
input wire [12:0] key, // ���ټ�����13�������͵�ƽ��Ч
input wire [1:0] pitch, // ����/���������͵�ƽ��Ч
input wire switch, // ������/������ѡ���
output wire buzzer, // ���������
output wire speaker, // ���������
output wire [8:0] seg1, // �����1���
output wire [8:0] seg2 // �����2���
);

localparam PLLCLK_FREQ = PCLK_FREQ * PLLX;
wire pllclk;
pll pll_u (.CLKI(pclk), .CLKOP(pllclk));

wire rst = ~rst_n;

wire wave;
assign buzzer = ~switch ? wave : 1'b0;
assign speaker = switch ? wave : 1'b0;

wire clk_msg;
wire [7:0] msg;
reg [7:0] noteid;
keyboard #(.CLK_FREQ(PCLK_FREQ)) keyboard_u (pclk, rst, key, pitch, clk_msg, msg);
player #(.CLK_FREQ(PLLCLK_FREQ)) player_u (pllclk, rst, clk_msg, msg, wave);
segment segment_u (noteid, seg1, seg2);

always @(posedge clk_msg or posedge rst) begin
    if (rst)
        noteid = 1'b0;
    else begin
        if (msg[7:7])
            noteid = msg[6:0];
    end
end

endmodule