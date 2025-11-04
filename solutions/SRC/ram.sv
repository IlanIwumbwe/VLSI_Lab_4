module ram(
    input clk,
    input logic [4:0] addr,
    input logic [31:0] data,
    input logic web,

    output logic [31:0] q
);

logic [31:0] block[32];

always_ff@(posedge clk) begin
    if(web)
        block[addr] <= data;
    else
        q <= block[addr];
end

endmodule
