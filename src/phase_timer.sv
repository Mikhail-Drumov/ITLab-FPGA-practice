module phase_timer #(
    parameter SECONDS = 10,
    parameter DIV_LIMIT_1S = 50_000_000
)(
    input  logic       clk,
    input  logic       rst_n,
    output logic       timer_done,
    output logic [3:0] time_left
);
    logic tick;
    logic [3:0] timer = SECONDS;
    clk_divider #(DIV_LIMIT = DIV_LIMIT_1S) div(
        .clk(clk),
        .rst_n(rst_n),
        .tick(tick)
    );
    
    always_ff @(posedge clk or negedge rst) begin
        if (!rst_n)
            timer <= SECONDS;
        else if (timer == 0)
            timer <= SECONDS;
        else if (tick)
            timer <= timer - 1;
    end
    
    assign timer_done = (timer == 0);
    assign time_left = timer;
endmodule
