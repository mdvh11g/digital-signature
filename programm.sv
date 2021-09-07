
parameter PRG_SIZE = 18;

logic [15:0] instruction [PRG_SIZE];

always_comb begin

// modular multiplications

instruction[0]  = 16'b1010_000_000_0100_00; // load core_reg_a to result[0]
instruction[1]  = 16'b0001_000_000_0101_00; // result[0] * reg_b -> result[0]
instruction[2]  = 16'b0000000000000011;     // === end ===

// elliptic point additions example (P != Q)

instruction[3]  = 16'b1010_000_000_0100_00; // load core_reg_a to result[0],   a_x
instruction[4]  = 16'b1010_001_000_0101_00; // load core_reg_b to result[1],   a_y
instruction[5]  = 16'b1010_010_000_0110_00; // load core_reg_c to result[2],   b_x
instruction[6]  = 16'b1010_011_000_0111_00; // load core_reg_d to result[3],   b_y
instruction[7]  = 16'b1000_100_000_1010_00; // result[2] - result[0] -> result[4] (b_x - a_x)
instruction[8]  = 16'b1000_101_001_1011_00; // result[3] - result[1] -> result[5] (b_y - a_y)
instruction[9]  = 16'b0101_100_100_1100_00; // result[4]^-1 -> result[4] 
instruction[10] = 16'b0001_100_101_1100_00; // result[5] * result[4] -> result[4] (lambda)
instruction[11] = 16'b0001_101_100_1100_00; // result[4] * result[4] -> result[5] (lambda^2)
instruction[12] = 16'b0110_110_010_1000_00; // result[0] + result[2] -> result[6] (a_x+b_x) 
instruction[13] = 16'b1000_110_110_1101_00; // result[5] - result[6] -> result[6] (a_x_new)
instruction[14] = 16'b1000_111_110_1000_00; // result[0] - result[6] -> result[7] (a_x-a_x_new)
instruction[15] = 16'b0001_111_111_1100_00; // result[4] * result[7] -> result[7] (lamda*(a_x-a_x_new))
instruction[16] = 16'b1000_111_001_1111_00; // result[7] - result[1] -> result[7] (b_y_new)
instruction[17] = 16'b0000000000000011;     // === end ===

end


