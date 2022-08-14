module keyboard
#(
parameter CLK_FREQ = 120_000_000, 
parameter MIN_SHIFT = 3,
parameter MAX_SHIFT = 6,
parameter SCAN_FREQ = 100
)
(
input wire clk, // ����ʱ��
input wire rst, // ��λ�źţ��͵�ƽ��Ч
input wire [12:0] key, // ���ټ�����13�������͵�ƽ��Ч
input wire [1:0] pitch, // ����/���������͵�ƽ��Ч
output reg clk_msg = 1'b0, // ����źŵ�ʱ�ӣ���������Ч
output reg [7:0] msg = 1'b0 // ���λ��ʾ���ͣ�1��������0�ر�������������λΪ����MIDI����
);


/**************************************** wire���� ****************************************/
wire clk_scan; // ����ɨ���źţ���������
wire clk_scan_13x;


/**************************************** reg���� ****************************************/
reg [1:0] sta = 2'b00;
reg [7:0] scan_i = 1'b0; // ɨ��ڼ���������״̬����
reg [12:0] key_last_sta = 13'b1_111_111_111_111; // ������һ�ΰ���״̬���͵�ƽ��Ч

reg [7:0] shift = 4; // �ڼ����˶�
reg [1:0] pitch_last_sta = 2'b11;


/**************************************** ��ģ��ʵ���� ****************************************/
clkdiv clkdiv_u1 (clk, rst, CLK_FREQ / SCAN_FREQ, clk_scan); // ����ɨ���ź�
clkdiv clkdiv_u2 (clk, rst, CLK_FREQ / (SCAN_FREQ*13), clk_scan_13x);


/**************************************** ʱ���߼� ****************************************/
// �ټ�ɨ��
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
					msg[7] = ~key[scan_i]; // �͵�ƽ��Ч����⵽����/�ͷ�һ������
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

// ��������ɨ��
always @(posedge clk_scan or posedge rst) begin
	if (rst) begin
		shift = 4;
		pitch_last_sta = 2'b11;
	end	
	else begin
		// ������
		if (pitch_last_sta[0] & ~pitch[0]) begin // �͵�ƽ��Ч
			if (shift > MIN_SHIFT)
				shift = shift - 1'b1;
		end
		// ������
		if (pitch_last_sta[1] & ~pitch[1]) begin
			if (shift < MAX_SHIFT)
				shift = shift + 1'b1;
		end
		// ����״̬
		pitch_last_sta = pitch;
	end
end

endmodule