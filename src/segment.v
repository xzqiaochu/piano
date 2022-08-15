module segment (input wire [7:0] noteid, // MIDI音符编号
                output wire [8:0] seg1,  // 数码管1输出（MSB~LSB = DIG、DP、G、F、E、D、C、B、A），数码管为共阴极接??
                output wire [8:0] seg2); // 数码管2输出
    
    reg [8:0] mask [0:9];
    
    initial begin
        mask[0] = 9'h3f;
        mask[1] = 9'h06;
        mask[2] = 9'h5b;
        mask[3] = 9'h4f;
        mask[4] = 9'h66;
        mask[5] = 9'h6d;
        mask[6] = 9'h7d;
        mask[7] = 9'h07;
        mask[8] = 9'h7f;
        mask[9] = 9'h6f;
    end
    
    assign seg1 = (noteid == 0) ? 9'b0 : mask[(noteid*103)>>10]; // 除以10
    assign seg2 = (noteid == 0) ? 9'b0 : mask[noteid%10];
    
    // 一般的除法，比如a/b，可以转成乘法来做，如a*(1/b)，其中1/b的分子可以放大1024倍后再做计算
    
endmodule
