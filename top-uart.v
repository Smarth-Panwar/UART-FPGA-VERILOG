module top_uart(
    input GCLK, reset,      // Changed 'clk' to 'GCLK' to match XDC 
    input wr_enb,           // Signal to start transmission 
    input [7:0] sw_input,   // Input bus from switches [cite: 63, 64]
    input rdy_clr,
    output bsy,
    output [7:0] rx_data,   // Matches your XDC LED names [cite: 47, 48, 49]
    output rdy
);
    wire w1, w2, tx_temp;

    baud_rate bd(
        .GCLK(GCLK),        // Match internal GCLK port
        .reset(reset),
        .Tx_clkenb(w1), 
        .Rx_clkenb(w2)
    );
    
    transmitter tm(
        .GCLK(GCLK),
        .reset(reset),
        .wr_enb(wr_enb),
        .data_in(sw_input),
        .enb(w1),
        .tx(tx_temp),
        .busy(bsy)
    );
    
    receiver rs(
        .GCLK(GCLK),
        .clkenb(w2),
        .Rx(tx_temp),        // Loopback: TX connects to RX
        .reset(reset),
        .rdy_clr(rdy_clr),
        .data_out(rx_data), // Fixed name to match top-level 'rx_data'
        .rdy(rdy)
    );
    
endmodule
