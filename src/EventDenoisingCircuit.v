module EventBasedFilterWithDenoising (
    input wire clk,
    input wire reset,
    input wire [1:0] x,
    input wire [1:0] y,
    input wire [1:0] p,
    input wire [1:0] t,
    output wire [1:0] filtered_x,
    output wire [1:0] filtered_y,
    output wire [1:0] filtered_t
);

parameter WINDOW_SIZE = 4;  // Choose the size of the moving average window

reg [1:0] x_reg [0:WINDOW_SIZE-1];
reg [1:0] y_reg [0:WINDOW_SIZE-1];
reg [1:0] t_reg [0:WINDOW_SIZE-1];
reg [1:0] sum_x;
reg [1:0] sum_y;
reg [1:0] sum_t;
reg [3:0] count;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (int i = 0; i < WINDOW_SIZE; i = i + 1) begin
            x_reg[i] <= 2'b00;
            y_reg[i] <= 2'b00;
            t_reg[i] <= 2'b00;
        end
        sum_x <= 2'b00;
        sum_y <= 2'b00;
        sum_t <= 2'b00;
        count <= 4'b0000;
    end else begin
        // Shift input data into the shift registers
        for (int i = 0; i < WINDOW_SIZE - 1; i = i + 1) begin
            x_reg[i] <= x_reg[i + 1];
            y_reg[i] <= y_reg[i + 1];
            t_reg[i] <= t_reg[i + 1];
        end
        x_reg[WINDOW_SIZE - 1] <= x;
        y_reg[WINDOW_SIZE - 1] <= y;
        t_reg[WINDOW_SIZE - 1] <= t;

        // Calculate the sum of the window for each signal
        sum_x <= sum_x + x - x_reg[0];
        sum_y <= sum_y + y - y_reg[0];
        sum_t <= sum_t + t - t_reg[0];

        // Increment the count, making sure it doesn't exceed the window size
        if (count < WINDOW_SIZE)
            count <= count + 1;
    end
end

always @* begin
    // Only output non-zero values if 'p' is high
    if (p == 2'b11) begin
        filtered_x = (count == 4'b0000) ? 2'b00 : sum_x;
        filtered_y = (count == 4'b0000) ? 2'b00 : sum_y;
        filtered_t = (count == 4'b0000) ? 2'b00 : sum_t;
    end else begin
        // 'p' is not high, so output zeros
        filtered_x = 2'b00;
        filtered_y = 2'b00;
        filtered_t = 2'b00;
    end
end

endmodule