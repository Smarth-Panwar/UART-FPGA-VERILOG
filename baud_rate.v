module baud_rate(
    input GCLK,
    input reset,
    output Tx_clkenb, 
    output Rx_clkenb
);

    reg [9:0] countrx;
    reg [3:0] tx_divider; // 4-bit counter to count 16 Rx pulses

    // 1. Generate the 16x Baud Rate (Rx Clock Enable)
    always @(posedge GCLK or posedge reset) begin
        if(reset) begin
            countrx <= 0;
        end else begin
            if(countrx == 650) // Adjust for 0-indexing: (Clock / (Baud * 16)) - 1
                countrx <= 0;
            else
                countrx <= countrx + 1'b1;
        end
    end

    assign Rx_clkenb = (countrx == 0);

    // 2. Derive Tx Clock Enable from Rx Clock Enable
    always @(posedge GCLK or posedge reset) begin
        if(reset) begin
            tx_divider <= 0;
        end else if (Rx_clkenb) begin
            tx_divider <= tx_divider + 1'b1;
        end
    end

    // Tx pulse occurs once every 16 Rx pulses
    assign Tx_clkenb = (Rx_clkenb && (tx_divider == 4'd15));

endmodule
