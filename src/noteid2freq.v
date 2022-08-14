// 计算公式参考：https://www.jianshu.com/p/8f40844a6ff3
module noteid2freq(input wire clk,
                   input wire rst,
                   input wire [7:0] noteid,
                   output reg [15:0] freq = 1'b0);
    
    localparam C0X1024    = 8372;
    localparam RATIOX1024 = 1085;
    
    reg [7:0] last_noteid  = 1'b0;
    reg [7:0] noteid_cache = 1'b0;
    reg [31:0] freq_cache  = 1'b0;
    reg [15:0] i           = 1'b0;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            freq         = 1'b0;
            last_noteid  = 1'b0;
            noteid_cache = 1'b0;
            freq_cache   = 1'b0;
            i            = 1'b0;
        end
        else begin
            if (i == 1'b0) begin
                if (noteid != last_noteid) begin
                    if (noteid == 0)
                        freq = 1'b0;
                    else begin
                        noteid_cache = noteid;
                        freq_cache   = C0X1024;
                        i            = 1'b1;
                    end
                    last_noteid = noteid;
                end
            end
            else
            begin
                if (i <= noteid_cache) begin
                    freq_cache = (freq_cache * RATIOX1024) >> 10;
                    i          = i + 1'b1;
                end
                else begin
                    freq = freq_cache >> 10;
                    i    = 1'b0;
                end
            end
        end
    end
    
endmodule
