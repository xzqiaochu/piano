module autoplay #(parameter CLK_FREQ = 120_000_000,
                  parameter MUSIC_LEN = 1394,
                  parameter MS_PER_BEATX64 = 9)
                 (input wire clk,
                  input wire rst,
                  input wire en,
                  output reg clk_msg = 1'b0,
                  output reg [7:0] msg = 1'b0);
    
    wire clk_1khz;
    wire clk_play = en ? clk_1khz : 1'b0;
    
    reg [15:0] music [0:MUSIC_LEN-1];
    initial $readmemh("music.mem", music);
    reg [1:0] sta = 2'b00;
    reg [15:0] ms = 1'b0;
    reg [15:0] i  = 1'b0;
    
    clkdiv clkdiv_u (clk, rst, CLK_FREQ / 1000, clk_1khz); // 1kHz
    
    always @(posedge clk_play or posedge rst) begin
        if (rst) begin
            clk_msg = 1'b0;
            msg     = 1'b0;
            sta     = 2'b00;
            ms      = 1'b0;
            i       = 1'b0;
        end
        else begin
            ms = ms + 1'b1;
            case (sta)
                2'b00: begin
                    if (ms > music[i][15:8] * MS_PER_BEATX64) begin
                        msg = music[i][7:0];
                        i   = (i == MUSIC_LEN-1) ? 1'b0 : i + 1'b1;
                        ms  = 1'b0;
                        sta = 1'b01;
                    end
                end
                
                2'b01: begin
                    clk_msg = 1'b1;
                    sta     = 2'b11;
                end
                
                2'b11: begin
                    clk_msg = 1'b0;
                    sta     = 2'b00;
                end
                
            endcase
        end
    end
    
endmodule
