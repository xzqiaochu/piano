`timescale 1ns / 1ns
module tb;

reg pclk; // 晶振，10MHz
reg rst_n; // 复位键, 高电平有效
reg [12:0] key; // 钢琴键（共13个），低电平有效
reg [1:0] pitch; // 升音/降音键，低电平有效
reg switch; // 蜂鸣器/扬声器选择键
wire buzzer; // 蜂鸣器输出
wire speaker; // 扬声器输出
wire [8:0] seg1; // 数码管1输出
wire [8:0] seg2; // 数码管2输出

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