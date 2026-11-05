module blink_gen (
    input  logic clk,
    input  logic rst_n,
    output logic blink
);
    logic tick_quarter_sec;
    logic led;
    // clk 50 MHz - 0.25s switch
    clk_divider #(DIV_LIMIT=50_000_000 / 4) div(
        .clk(clk),
        .rst_n(rst_n),
        .tick(tick_quarter_sec)
    );
    
    always_ff @(posedge clk or negedge rst) begin
        if (!rst_n)
            led <= 0;
        else if (tick_quarter_sec)
            led <= ~led;
    end
    
    assign blink = led;
endmodule
