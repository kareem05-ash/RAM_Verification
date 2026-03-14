module RAM_gm (
    // Inputs
        input          clk,                 // active high clk
        input          rst_n,               // async - active low rst_n
        input          en,                  // write enable
        input [3:0]    address,
        input [31:0]   data_in,             // Input Bus
    
    // Outputs
        output reg [31:0]   data_out,       // Output Bus
        output reg          valid_out       // Validation Flag
);

    logic [31:0] mem [15:0];                // Ram

    always_ff @( posedge clk or negedge rst_n ) begin

        if (!rst_n) begin                   // rst_n
            data_out <= 32'h0000;
            valid_out <= 1'b0;

        end else if (en) begin              // write
            mem[address] <= data_in;
            valid_out <= 1'b0;
        end

        else begin                          // read
            data_out <= mem[address];
            valid_out <= 1'b1;
        end

    end

endmodule