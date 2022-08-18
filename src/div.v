module div (input wire clk,
            input wire rst,
            input wire [31:0] m,
            input wire [31:0] n,
            output reg [31:0] ans = 0);
    
    reg [31:0] last_m    = 0;
    reg [31:0] last_n    = 0;
    reg [31:0] m_cache   = 0;
    reg [31:0] n_cache   = 0;
    reg [31:0] ans_cache = 0;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            last_m    <= 0;
            last_n    <= 0;
            m_cache   <= 0;
            n_cache   <= 0;
            ans_cache <= 0;
            ans       <= 0;
        end
        else if (m_cache != 0) begin
            if (m_cache > n_cache) begin
                m_cache   <= m_cache - n_cache;
                ans_cache <= ans_cache + 1;
            end
            else begin
                m_cache <= 0;
                ans     <= ans_cache;
            end
        end
        else if (m != last_m || n != last_n) begin
            ans_cache <= 0;
            m_cache   <= m;
            n_cache   <= n;
            last_m    <= m;
            last_n    <= n;
        end
    end
            
endmodule
