module blink_gen #(parameter HALF_PERIOD = 50_000_000 / 4) (
    input  logic clk,
    input  logic rst_n,
    output logic blink
);
    logic tick_quarter_sec;
    logic led;
    // clk 50 MHz - 0.25s switch
    clk_divider #(HALF_PERIOD) div(
        .clk(clk),
        .rst_n(rst_n),
        .tick(tick_quarter_sec)
    );
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            led <= 0;
        else if (tick_quarter_sec)
            led <= ~led;
    end
    
    assign blink = led;
endmodule
