module main #(parameter PCLK_FREQ = 12_000_000,
              parameter PLLCLK_FREQ = 120_000_000)
             (input wire pclk,                     // 晶振，12MHz
              input wire rst_n,                    // 复位信号，低电平有效
              input wire [12:0] key,               // 钢琴键（共13个），低电平有效
              input wire [1:0] pitch,              // 升音/降音键，低电平有效
              input wire switch,                   // 蜂鸣器/扬声器选择键
              input wire autoplay_n,               // 开始自动播放按键，低电平有效
              output wire buzzer,                  // 蜂鸣器输出
              output wire speaker,                 // 扬声器输出
              output wire [8:0] seg1,              // 数码管1输出
              output wire [8:0] seg2);             // 数码管2输出
    
    /**************************************** 时钟、复位 ****************************************/
    wire pllclk;
    pll pll_u (.CLKI(pclk), .CLKOP(pllclk));
    wire rst = ~rst_n;
    
    
    /**************************************** 音频信号输出 ****************************************/
    wire wave;
    assign buzzer  = ~switch ? wave : 1'b0;
    assign speaker = switch ? wave : 1'b0;
    
    
    /**************************************** 弹奏/自动播放 ****************************************/
    reg mode = 1'b0;
    
    // 弹奏
    wire clk_msg1;
    wire [7:0] msg1;
    keyboard #(.CLK_FREQ(PLLCLK_FREQ)) keyboard_u (pllclk, rst, key, pitch, clk_msg1, msg1);
    
    // 自动播放
    wire clk_msg2;
    wire [7:0] msg2;
    autoplay #(.CLK_FREQ(PLLCLK_FREQ)) autoplay_u (pllclk, rst, mode, clk_msg2, msg2);
    
    // 模式切换
    wire clk_msg   = mode ? clk_msg2 : clk_msg1;
    wire [7:0] msg = mode ? msg2 : msg1;
    player #(.CLK_FREQ(PLLCLK_FREQ)) player_u (pllclk, rst, clk_msg, msg, wave);
    always @(posedge pllclk or posedge rst) begin
        if (rst)
            mode = 1'b0;
        else if (~autoplay_n)
            mode = 1'b1;
    end
    
    
    /**************************************** 数码管显示音符 ****************************************/
    reg [7:0] noteid;
    segment segment_u (noteid, seg1, seg2);
    
    always @(posedge clk_msg or posedge rst) begin
        if (rst)
            noteid = 1'b0;
        else if (msg[7:7])
            noteid = msg[6:0];
    end
    
    
endmodule
