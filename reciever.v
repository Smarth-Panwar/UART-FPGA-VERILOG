`timescale 1ns / 1ps

module receiver(
    input GCLK,
    input clkenb,       // From Baud Rate Gen (16x Baud Rate)
    input Rx,
    input rdy_clr,      // To clear the ready flag
    input reset,
    output reg [7:0] data_out,
    output reg rdy
);
    
    parameter idle_state  = 2'b00;
    parameter start_state = 2'b01;
    parameter data_state  = 2'b10;
    parameter stop_state  = 2'b11;
    
    reg [1:0] state;
    reg [7:0] data;
    reg [2:0] index;
    reg [3:0] sample;

    always @(posedge GCLK or posedge reset) begin
        if (reset) begin
            state    <= idle_state;
            index    <= 0;
            sample   <= 0;
            data     <= 0;
            data_out <= 0;
            rdy      <= 0;
        end else begin
            if (rdy_clr) rdy <= 0;

            // Inside your receiver always block
case(state)
    idle_state: begin
        sample <= 0;
        index  <= 0;
        // Wait for Rx to go low AND for a baud enable pulse
        if (Rx == 0 && clkenb) 
            state <= start_state;
    end

    start_state: begin
        if (clkenb) begin
            // Wait until the 7th or 8th sample (middle of Start bit)
            if (sample == 7) begin 
                sample <= 0;
                state  <= data_state;
            end else begin
                sample <= sample + 1'b1;
            end
        end
    end

    data_state: begin
        if (clkenb) begin
            if (sample == 15) begin // End of a bit period
                sample <= 0;
                if (index == 7)
                    state <= stop_state;
                else
                    index <= index + 1'b1;
            end else begin
                // Sample at the middle of the 16-sample window
                if (sample == 7) 
                    data[index] <= Rx;
                
                sample <= sample + 1'b1;
            end
        end
    end
  

                stop_state: begin
                    if (clkenb) begin
                        if (sample == 15) begin // End of stop bit
                            state    <= idle_state;
                            data_out <= data;
                            rdy      <= 1'b1;
                        end else begin
                            sample <= sample + 1'b1;
                        end
                    end
                end

                default: state <= idle_state;
            endcase
        end
    end
endmodule
