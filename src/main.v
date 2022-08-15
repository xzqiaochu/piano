module main #(parameter PCLK_FREQ = 12_000_000,
              parameter PLLCLK_FREQ = 120_000_000)
             (input wire pclk,                     // ����12MHz
              input wire rst_n,                    // ��λ�źţ��͵�ƽ��Ч
              input wire [12:0] key,               // ���ټ�����13�������͵�ƽ��Ч
              input wire [1:0] pitch,              // ����/���������͵�ƽ��Ч
              input wire switch,                   // ������/������ѡ���
              input wire autoplay_n,               // ��ʼ�Զ����Ű������͵�ƽ��Ч
              output wire buzzer,                  // ���������
              output wire speaker,                 // ���������
              output wire [8:0] seg1,              // �����1���
              output wire [8:0] seg2);             // �����2���
    
    /**************************************** ʱ�ӡ���λ ****************************************/
    wire pllclk;
    pll pll_u (.CLKI(pclk), .CLKOP(pllclk));
    wire rst = ~rst_n;
    
    
    /**************************************** ��Ƶ�ź���� ****************************************/
    wire wave;
    assign buzzer  = ~switch ? wave : 1'b0;
    assign speaker = switch ? wave : 1'b0;
    
    
    /**************************************** ����/�Զ����� ****************************************/
    reg mode = 1'b0;
    
    // ����
    wire clk_msg1;
    wire [7:0] msg1;
    keyboard #(.CLK_FREQ(PLLCLK_FREQ)) keyboard_u (pllclk, rst, key, pitch, clk_msg1, msg1);
    
    // �Զ�����
    wire clk_msg2;
    wire [7:0] msg2;
    autoplay #(.CLK_FREQ(PLLCLK_FREQ)) autoplay_u (pllclk, rst, mode, clk_msg2, msg2);
    
    // ģʽ�л�
    wire clk_msg   = mode ? clk_msg2 : clk_msg1;
    wire [7:0] msg = mode ? msg2 : msg1;
    player #(.CLK_FREQ(PLLCLK_FREQ)) player_u (pllclk, rst, clk_msg, msg, wave);
    always @(posedge pllclk or posedge rst) begin
        if (rst)
            mode = 1'b0;
        else if (~autoplay_n)
            mode = 1'b1;
    end
    
    
    /**************************************** �������ʾ���� ****************************************/
    reg [7:0] noteid;
    segment segment_u (noteid, seg1, seg2);
    
    always @(posedge clk_msg or posedge rst) begin
        if (rst)
            noteid = 1'b0;
        else if (msg[7:7])
            noteid = msg[6:0];
    end
    
    
endmodule
