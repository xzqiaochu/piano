module dds #(parameter PLAYER_NUM = 3,
             parameter THETA_WIDTH = 8,
             parameter AM_WIDTH = 8)
            (input wire [THETA_WIDTH*PLAYER_NUM-1:0] theta,
             output wire [AM_WIDTH*PLAYER_NUM-1:0] am);
    
    reg [AM_WIDTH-1:0] dds [0:(1<<THETA_WIDTH)-1];
    initial $readmemh("dds.mem", dds);
    
    genvar i;
    generate
    for (i=0; i<PLAYER_NUM; i=i+1)
        assign am[AM_WIDTH*i+:AM_WIDTH] = dds[theta[THETA_WIDTH*i+:THETA_WIDTH]];
    endgenerate
    
endmodule
