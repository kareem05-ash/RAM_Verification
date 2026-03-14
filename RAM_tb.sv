`define WORD_SIZE   32
`define DEPTH       16

module RAM_tb;
    
    // DUT Inputs
        logic           clk_tb;
        logic           rst_n_tb;
        logic           en_tb;
        logic [3:0]     address_tb;
        logic [`WORD_SIZE - 1:0]    data_in_tb;

    // DUT Outputs
        logic [`WORD_SIZE - 1:0]    data_out_dut;
        logic           valid_out_dut;

    // TB Needed Signals
        logic [`WORD_SIZE - 1:0] data_out_gm;
        logic                   valid_out_gm;
        logic [3:0] adr_arr[];
        logic [`WORD_SIZE - 1:0] data_arr[];
        int tot_tests = 0;
        int passed = 0;

    // DUT Instantiation
        RAM DUT(
            // Inputs
                .clk(clk_tb),
                .rst_n(rst_n_tb),
                .en(en_tb),
                .address(address_tb),
                .data_in(data_in_tb),

            // Outputs 
                .data_out(data_out_dut),
                .valid_out(valid_out_dut)
        );

    // GM Instantiation
        RAM_gm GM(
            // Inputs
                .clk(clk_tb),
                .rst_n(rst_n_tb),
                .en(en_tb),
                .address(address_tb),
                .data_in(data_in_tb),

            // Outputs 
                .data_out(data_out_gm),
                .valid_out(valid_out_gm)
        );

    // CLK Generatino
        initial clk_tb = 0;
        always #5 clk_tb = ~clk_tb;

    // TASKs
        // RST Task: rst_task()
            task rst_task(); begin
                rst_n_tb = 0;       // activate rst_n_tb
                #1;                 // delay to recognize async rst_n
                rst_n_tb = 1;       // release rst_n_tb
            end
            endtask

        // Assign Data Task: en, [3:0] address, [`WORD_SIZE - 1:0] data_in
            task assign_data(
                input logic en,
                input logic [3:0] address,
                input logic [`WORD_SIZE - 1:0] data_in
            ); begin
                @ (negedge clk_tb);     // Drive Inputs
                en_tb = en;
                address_tb = address;
                data_in_tb = data_in;
                @ (negedge clk_tb);     // Assert outputs
            end
            endtask

        // Scoreboard Task: sb()
            task sb(); begin
                tot_tests++;
                if (data_out_dut === data_out_gm && valid_out_dut === valid_out_gm) begin
                    passed++;
                    $display("  > [PASS] en = %b, address = %h, data_in = %h | data_out = %h, exp = %h | valid_out = %b, exp = %b",
                                en_tb, address_tb, data_in_tb, data_out_dut, data_out_gm, valid_out_dut, valid_out_gm);
                end

                else                
                    $display("  > [FAIL] en = %b, address = %h, data_in = %h | data_out = %h, exp = %h | valid_out = %b, exp = %b",
                                en_tb, address_tb, data_in_tb, data_out_dut, data_out_gm, valid_out_dut, valid_out_gm);
            end
            endtask

        // Write Read Task
            task write_read(); begin
                // """This task writes all data patterns in data_arr then read them for all possible addresses"""
                for (int i = 0; i < `DEPTH; i++) begin
                    $display("\nMemory Slot With Address [%0h]", i);
                    foreach (data_arr[j]) begin
                        assign_data(.en(1'b1),  .address(i),    .data_in(data_arr[j]));
                        @ (negedge clk_tb);
                        en_tb = 1'b0;       // read
                        @ (negedge clk_tb);
                        sb();
                    end
                end
            end
            endtask

    // Stimulus
        initial begin
            // 1st Scenario < Initialize Memroy >
                $display("\n==================== 1st Scenario < Initialize Memroy > ====================\n");
                $readmemh("mem_load.txt", DUT.mem);         // DUT RAM Initialization
                $readmemh("mem_load.txt", GM.mem);          // GM RAM Initialization
                rst_task();
                for (int i = 0; i <  `DEPTH; i++) begin
                    assign_data(.en(1'b0),  .address(i),    .data_in($random()));
                    sb();
                end

            
            // 2nd Scenario < Reset Behavior >
                $display("\n==================== 2nd Scenario < Reset Behavior > ====================\n");
                rst_task();
                sb();

            
            // 3rd Scenario < Write/Read In/From All Entries Random Data >
                $display("\n==================== 3rd Scenario < Write/Read In/From All Entries Random Data > ====================\n");
                data_arr = new[5];
                for (int i = 0; i < 5; i++) begin
                    data_arr[i] = $random();
                end
                write_read();
                data_arr.delete();          // free memory

            
            // 4th Scenario < Write & Read {0000_0000H, 5555_5555H, AAAA_AAAAH, FFFF_FFFFH} >
                $display("\n==================== 4th Scenario < Write & Read {0000_0000H, 5555_5555H, AAAA_AAAAH, FFFF_FFFFH} > ====================\n");
                data_arr = new[4];
                data_arr = '{32'h0000_0000, 32'h5555_5555, 32'hAAAA_AAAA, 32'hFFFF_FFFF};
                write_read();
                data_arr.delete();
            
            // 5th Scenario < Reset After Write (within the same clk cycle) >
                $display("\n==================== 5th Scenario < Reset After Write (within the same clk cycle) > ====================\n");
                @ (negedge clk_tb);
                en_tb = 1;      // write
                address_tb = 4'hA;
                data_in_tb = $random();
                @ (posedge clk_tb);
                rst_task();
                @ (negedge clk_tb);
                en_tb = 0;      // read
                @ (negedge clk_tb);
                sb();


            
            // <  STOP Simulation  >
                $display("\n------------------------------------------------------------");
                $display("-------------------- <  End Simulation  > --------------------");
                $display("------------------------------------------------------------");
                $display("  > > ALL TEST CASEs: %0d", tot_tests);
                $display("  > > PASSed        : %0d", passed);
                $display("  > > FAILed        : %0d", tot_tests - passed);
                $stop;
        end

    // // monitor
    //     initial begin
    //         $monitor("[%g] rst_n_tb = %b, adrress_tb = %h, en_tb = %b, data_in_tb = %h | data_out_dut = %h, valid_out_dut = %b | data_out_gm = %h, valid_out_gm = %b", 
    //                     $time, rst_n_tb, address_tb, en_tb, data_in_tb, data_out_dut, valid_out_dut, data_out_gm, valid_out_gm);
    //     end

endmodule