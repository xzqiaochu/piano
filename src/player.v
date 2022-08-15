module player #(parameter CLK_FREQ = 120_000_000,
                parameter PLAYER_NUM = 2,
                parameter PWM_FREQ = 500_000,
                parameter THETA_WIDTH = 8,
                parameter AM_WIDTH = 8)
               (input wire clk,                   // 输入时钟
                input wire rst,                   // 复位信号，高电平有效
                input wire clk_msg,               // msg传输时钟，上升沿有效
                input wire [7:0] msg,             // 最高位表示类型（1打开音符，0关闭音符），其他位为音符MIDI编码
                output wire wave);                // 音频输出（使用PWM调制）
    
    integer i;
    
    /**************************************** wire变量 ****************************************/
    wire signed [AM_WIDTH-1:0] ams [PLAYER_NUM-1:0];
    reg signed [31:0] am_sum; // [notice] am在整合ams的时候，采取先加和再除的逻辑（目的是节省逻辑门），但如果AM_WIDTH过大，可能会溢出的风险
    wire [7:0] am;
    
    
    /**************************************** reg变量 ****************************************/
    reg clk_msg_last      = 1'b0;
    reg [1:0] sta         = 2'b00;
    reg [7:0] handle_note = 1'b0;
    reg [PLAYER_NUM-1:0] handle_i; // 实际上log2(PLAYER_NUM)的位宽就足够了，但FPGA里不方便写log运算，就用PLAYER_NUM肯定??
    reg [7:0] noteids [PLAYER_NUM-1:0];
    initial begin
        for (i = 0; i<PLAYER_NUM; i = i+1)
            noteids[i] <= 8'b0;
    end
    
    
    /**************************************** 子模块实例化 ****************************************/
    genvar g;
    generate
    for(g = 0; g<PLAYER_NUM; g = g+1) begin
        note #(.CLK_FREQ(CLK_FREQ)) note_u (clk, rst, noteids[g], ams[g]);
    end
    endgenerate
    div div_u (clk, rst, am_sum, PLAYER_NUM, am);
    dac #(.CLK_FREQ(CLK_FREQ)) dac_u (clk, rst, am, wave);
    
    
    /**************************************** 组合逻辑 ****************************************/
    always @(*) begin
        am_sum = ams[0];
        for(i = 1; i<PLAYER_NUM; i = i+1) begin
            am_sum = am_sum + ams[i];
        end
        am_sum = am_sum + (1<<(AM_WIDTH-1)) * PLAYER_NUM;
    end
    
    
    /**************************************** 时序逻辑 ****************************************/
    // 处理音符
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_msg_last = 1'b0;
            sta          = 2'b00;
            handle_note  = 1'b0;
            handle_i     = 1'b0;
            for (i = 0; i<PLAYER_NUM; i = i+1)
                noteids[i] = 8'b0;
        end
        else begin
            case (sta)
                2'b00: begin
                    if (~clk_msg_last & clk_msg) begin
                        handle_note = msg[6:0];
                        handle_i    = 1'b0;
                        if (msg[7:7])
                            sta = 2'b01;
                        else
                            sta = 2'b10;
                    end
                    clk_msg_last = clk_msg;
                end
                2'b01: begin // 打开一个音符
                    if (noteids[handle_i] == 8'b0) begin
                        noteids[handle_i] = handle_note;
                        sta               = 2'b00;
                    end
                    else if (handle_i == PLAYER_NUM-1)
                    sta = 2'b00;
                    else
                    handle_i = handle_i + 1'b1;
                end
                2'b10: begin // 关闭一个音符
                    if (noteids[handle_i] == handle_note) begin
                        noteids[handle_i] = 8'b0;
                        sta               = 2'b00;
                    end
                    else if (handle_i == PLAYER_NUM-1)
                    sta = 2'b00;
                    else
                    handle_i = handle_i + 1'b1;
                end
            endcase
        end
    end
    
endmodule
