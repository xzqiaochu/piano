module clkdiv (input wire clk,             // input clock
               input wire rst,             // active low
               input wire [31:0] divx,
               output reg clk_out = 1'b0); // clock output
    
    reg [31:0] cnt = 0;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt     <= 1'b0;
            clk_out <= 1'b0;
        end
        else if (cnt >= (divx >> 1)) begin
            cnt <= 1'b0;
            clk_out = ~clk_out;
        end
        else begin
            cnt <= cnt + 1'b1;
        end
    end
    
endmodule
