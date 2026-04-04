package RAM_pkg;
    class rand_ram_inputs;
        rand bit rst_n, en;
        rand bit [3:0] address;
        rand bit [31:0] data_in;

        constraint inputs_const {
            data_in dist {
                32'h0000_0000   := 2,
                32'h5555_5555   := 2,
                32'hAAAA_AAAA   := 2,
                32'hFFFF_FFFF   := 2,
                [1:$]           := 6
            };
        }

        constraint rst_const { rst_n   dist {0 := 1, 1 := 99}; }    // 1% rst_n
        constraint en_const  { en      dist {1 := 4, 0 :=  6}; }    // 40% en
        constraint address_const { address inside {[0:7]}; }        // address MSB = 0

    endclass //randomization
endpackage