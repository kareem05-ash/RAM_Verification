module RAM (
    input clk,
    input rst_n,
    input en,
    input [3:0] address,
    input [31:0] data_in,
    output [31:0] data_out,
    output valid_out
);
    reg [31:0] mem [15:0];

    always @(posedge clk) begin
        // if (en && !rst_n) begin
        if (en && rst_n) begin
            mem[address] <= data_in;
        end
    end

    // assign data_out = (!rst_n) ? 0 : mem[address];                  // bug
    assign data_out = (!rst_n) ? 0 : (en? 32'h0 : mem[address]);    // fix
    assign valid_out = (!rst_n) ? 0 : ~en;
endmodule