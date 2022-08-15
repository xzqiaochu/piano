module player #(parameter CLK_FREQ = 120_000_000,
                parameter PLAYER_NUM = 2,
                parameter PWM_FREQ = 500_000,
                parameter THETA_WIDTH = 8,
                parameter AM_WIDTH = 8)
               (input wire clk,                   // ����ʱ��
                input wire rst,                   // ��λ�źţ��ߵ�ƽ��Ч
                input wire clk_msg,               // msg����ʱ�ӣ���������Ч
                input wire [7:0] msg,             // ���λ��ʾ���ͣ�1��������0�ر�������������λΪ����MIDI����
                output wire wave);                // ��Ƶ�����ʹ��PWM���ƣ�
    
    integer i;
    
    /**************************************** wire���� ****************************************/
    wire signed [AM_WIDTH-1:0] ams [PLAYER_NUM-1:0];
    reg signed [31:0] am_sum; // [notice] am������ams��ʱ�򣬲�ȡ�ȼӺ��ٳ����߼���Ŀ���ǽ�ʡ�߼��ţ��������AM_WIDTH���󣬿��ܻ�����ķ���
    wire [7:0] am;
    
    
    /**************************************** reg���� ****************************************/
    reg clk_msg_last      = 1'b0;
    reg [1:0] sta         = 2'b00;
    reg [7:0] handle_note = 1'b0;
    reg [PLAYER_NUM-1:0] handle_i; // ʵ����log2(PLAYER_NUM)��λ����㹻�ˣ���FPGA�ﲻ����дlog���㣬����PLAYER_NUM�϶�??
    reg [7:0] noteids [PLAYER_NUM-1:0];
    initial begin
        for (i = 0; i<PLAYER_NUM; i = i+1)
            noteids[i] <= 8'b0;
    end
    
    
    /**************************************** ��ģ��ʵ���� ****************************************/
    genvar g;
    generate
    for(g = 0; g<PLAYER_NUM; g = g+1) begin
        note #(.CLK_FREQ(CLK_FREQ)) note_u (clk, rst, noteids[g], ams[g]);
    end
    endgenerate
    div div_u (clk, rst, am_sum, PLAYER_NUM, am);
    dac #(.CLK_FREQ(CLK_FREQ)) dac_u (clk, rst, am, wave);
    
    
    /**************************************** ����߼� ****************************************/
    always @(*) begin
        am_sum = ams[0];
        for(i = 1; i<PLAYER_NUM; i = i+1) begin
            am_sum = am_sum + ams[i];
        end
        am_sum = am_sum + (1<<(AM_WIDTH-1)) * PLAYER_NUM;
    end
    
    
    /**************************************** ʱ���߼� ****************************************/
    // ��������
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
                2'b01: begin // ��һ������
                    if (noteids[handle_i] == 8'b0) begin
                        noteids[handle_i] = handle_note;
                        sta               = 2'b00;
                    end
                    else if (handle_i == PLAYER_NUM-1)
                    sta = 2'b00;
                    else
                    handle_i = handle_i + 1'b1;
                end
                2'b10: begin // �ر�һ������
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
