module transmitter(
    input GCLK, reset,
    input wr_enb,           // Signal to start transmission
    input [7:0] data_in,    // Changed to 8-bit bus
    input enb,              // Pulsed by Baud Rate Generator
    output reg tx,
    output busy
);
    parameter idle_state  = 2'b00;
    parameter start_state = 2'b01;
    parameter data_state  = 2'b10;
    parameter stop_state  = 2'b11;

    reg [1:0] state;
    reg [7:0] data_reg;
    reg [2:0] index;

    always @ (posedge GCLK or posedge reset) begin
        if (reset) begin
            state <= idle_state;
            tx <= 1'b1;
            index <= 0;
        end else begin
            case(state)
                idle_state: begin
                    tx <= 1'b1;
                    if (wr_enb) begin
                        data_reg <= data_in; // Capture the byte
                        state <= start_state;
                    end
                end

                start_state: begin
                    if (enb) begin
                        tx <= 1'b0; // Start bit
                        state <= data_state;
                        index <= 0;
                    end
                end

                data_state: begin
                    if (enb) begin
                        tx <= data_reg[index];
                        if (index == 3'h7)
                            state <= stop_state;
                        else
                            index <= index + 1;
                    end
                end

                stop_state: begin
                    if (enb) begin
                        tx <= 1'b1; // Stop bit
                        state <= idle_state;
                    end
                end
            endcase
        end
    end

    assign busy = (state != idle_state);
endmodule
