module clk_divider #(parameter DIV_LIMIT = 50_000_000) (
    input  logic clk,
    input  logic rst_n,
    output logic tick
);
    logic [$clog2(DIV_LIMIT):0] counter = 0;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            /* verilator lint_off WIDTH */
        end else if (counter == DIV_LIMIT - 1) begin
            /* verilator lint_on WIDTH */
            counter <= 0;
        end else
            counter <= counter + 1;
    end
    
	 /* verilator lint_off WIDTH */
    assign tick = (counter == DIV_LIMIT - 1);
	 /* verilator lint_on WIDTH */
endmodule
