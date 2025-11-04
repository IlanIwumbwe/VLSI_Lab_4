module Control(
    input logic clk,
    input logic rst,
    input logic test,
    output logic ctrl,
    output logic sig_ctrl,
);

    logic [5:0] counter;

    always_ff @(posedge clk) begin
        if(rst) begin
            counter <= 0;
        end else if(~test) begin
            counter <= counter + 1;
        end else
            counter <= counter;
    end

    assign ctrl = ~counter[5] & ~test;
    assign sig_ctrl = test;

endmodule
