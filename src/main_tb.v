`timescale 1ns / 1ns
module tb;

reg pclk; // ����10MHz
reg rst_n; // ��λ��, �ߵ�ƽ��Ч
reg [12:0] key; // ���ټ�����13�������͵�ƽ��Ч
reg [1:0] pitch; // ����/���������͵�ƽ��Ч
reg switch; // ������/������ѡ���
wire buzzer; // ���������
wire speaker; // ���������
wire [8:0] seg1; // �����1���
wire [8:0] seg2; // �����2���

GSR GSR_INST(.GSR(1'b1));
PUR PUR_INST(.PUR(1'b1));

main #(.PCLK_FREQ(10_000_000)) main_u (pclk, rst_n, key, pitch, switch, buzzer, speaker, seg1, seg2);

defparam main_u.keyboard_u.SCAN_FREQ = 10_000;

initial pclk = 1'b0;
always #50 pclk = ~pclk;

initial begin
    //rst = 1'b0;
    //#200;
    rst_n = 1'b1;
end

initial begin
    key = 13'b1_111_111_111_111;
    pitch = 2'b11;
    switch = 1'b1;
    //@(rst == 1'b1);
    #100000; // 0.1ms
    key[0] = 1'b0;
    //#1000000; // 1 ms
    //key[2] = 1'b0;
end

endmodule