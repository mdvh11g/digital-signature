`define rom
`ifdef sram

module sv_im #(
  parameter BLOCK_SIZE = 512,
  parameter CORE_ROUND = 4) 
(
  input  logic  clk,
  input  logic  areset,

  input  logic  [7:0]  iaddr_i,
  output logic  [15:0] instr_o,
  input  logic         valid_i,

  input  logic         update_i,
  input  logic  [7:0]  upaddr_i,
  input  logic  [15:0] updata_i);

  logic [7:0] addr;
  
  assign addr = update_i ? upaddr_i : iaddr_i;
    
  sram #("GENERIC",16,8)
  sram  (
    .clk(clk),
    .ad_i(addr),
    .d_i(updata_i),
    .d_o(instr_o),
    .we_i(update_i),
    .cs_i('1));  



endmodule

`else 


module sv_im #(
  parameter BLOCK_SIZE = 512,
  parameter CORE_ROUND = 4) 
(
  input  logic  clk,
  input  logic  areset,

  input  logic  [7:0]  iaddr_i,
  output logic  [15:0] instr_o,
  input  logic         valid_i,

  input  logic         update_i,
  input  logic  [7:0]  upaddr_i,
  input  logic  [15:0] updata_i);


  logic [15:0] instr [128];

  logic [7:0] addr_reg;

  always @ (posedge clk)
    addr_reg <= iaddr_i;  
  
  assign instr_o = instr[addr_reg]; 
   

  always_comb begin
    
   
    instr[0]  = 16'b0111_100_000_0001_00; // request random_number

    instr[1]  = 16'b1010_100_000_0001_00; // load     '1 to reg_e (b_x)
    instr[2]  = 16'b1010_110_000_0110_00; // load freg_g to reg_g (a_x) 
    instr[3]  = 16'b1010_111_000_0111_00; // load freg_h to reg_h (a_y) 

    instr[4]  = 16'b0011_000_000_0011_10; // load (k) mod_q to reg_a
    instr[5]  = 16'b1100_000_000_0000_00; // compare reg_a with zero
    instr[6]  = 16'b000001000111_01_01;   // if reg_a is zero jump to i[71] - end;

    instr[7]  = 16'b1110_000_000_0000_00; // reg_a is odd ?
    instr[8]  = 16'b000000001010_01_01;   // if reg_a is odd jump to i[10]-{k--; b=ECSum(a,b)};
    instr[9]  = 16'b000000110101_11_01;   // else jump to i[53]-{k/2; a=ECSum(a,a)};


// {k--; b=ECSum(a,b);}

    instr[10] = 16'b1100_000_110_0001_00; // compare reg_g (a_x) with '1
    instr[11] = 16'b000000101110_01_01;   // if a_x is zero jump to i[46]  
    instr[12] = 16'b1100_000_100_0001_00; // else compare reg_e (b_x) with '1
    instr[13] = 16'b000000101100_01_01;   // if b_x is zero jump to i[44] 

    instr[14] = 16'b1100_000_100_1110_00; // compare reg_g with reg_e 
    instr[15] = 16'b000000011101_01_01;   // if comparation jump to i[29] - point doulbing with zero checing

    instr[16] = 16'b1000_001_101_1111_00; // reg_h - reg_f -> reg_b (a_y - b_y)
    instr[17] = 16'b1000_010_100_1110_00; // reg_g - reg_e -> reg_c (a_x - b_x)

    instr[18] = 16'b0101_010_010_0000_00; // reg_c^-1 -> reg_c 
    instr[19] = 16'b0001_001_010_1001_00; // reg_b * reg_c -> reg_b (lambda)   
    instr[20] = 16'b0001_010_001_1001_00; // reg_b * reg_b -> reg_c (lambda^2)
    instr[21] = 16'b0110_011_100_1110_00; // reg_g + reg_e -> reg_d (a_x+b_x) 
    instr[22] = 16'b1000_011_011_1010_00; // reg_c - reg_d -> reg_d (a_x_new)
    instr[23] = 16'b1000_010_011_1110_00; // reg_d - reg_g -> reg_c (a_x-a_x_new)
    instr[24] = 16'b0001_010_010_1001_00; // reg_b * reg_c -> reg_c (lamda*(a_x-a_x_new))
    instr[25] = 16'b1000_101_111_1010_00; // reg_c - reg_h -> reg_f (b_y_new)
    instr[26] = 16'b1010_100_000_1011_00; // load reg_d to reg_e (b_x_new) 

    instr[27] = 16'b0000_000_000_0000_00; // reg_a-- (k--)
    instr[28] = 16'b000000000101_11_01;   // jump to k check - i[5]

    instr[29] = 16'b1000_001_101_0000_00; // '0 - reg_f -> reg_b
    instr[30] = 16'b1100_000_111_0001_10; // compare reg_b with reg_h
    instr[31] = 16'b000000110010_01_01;   // if comparation jump to i[50] - load_zero point

    instr[32] = 16'b0001_001_110_1110_00; // reg_g * reg_g -> reg_b (a_x^2)
    instr[33] = 16'b0110_010_001_1001_00; // reg_b + reg_b -> reg_c (2*a_x^2) 
    instr[34] = 16'b0110_001_010_1001_00; // reg_b + reg_c -> reg_b (3*a_x^2)
    instr[35] = 16'b0110_001_001_0101_00; // reg_b + a     -> reg_b (3*a_x^2+a)
    instr[36] = 16'b0110_010_111_1111_00; // reg_h + reg_h -> reg_c (2*a_y)
    instr[37] = 16'b0101_010_010_0000_00; // reg_c^-1      -> reg_c (2*a_y^-1) 
    instr[38] = 16'b0001_001_010_1001_00; // reg_b * reg_c -> reg_b (lambda)    
    instr[39] = 16'b0001_010_001_1001_00; // reg_b * reg_b -> reg_c (lambda^2)
    instr[40] = 16'b0110_011_110_1110_00; // reg_g + reg_g -> reg_d (2*a_x) 
    instr[41] = 16'b1000_011_011_1010_00; // reg_c - reg_d -> reg_d (a_x_new)
    instr[42] = 16'b1000_010_011_1110_00; // reg_d - reg_g -> reg_c (a_x-a_x_new)
    instr[43] = 16'b0001_010_010_1001_00; // reg_b * reg_c -> reg_c 
    instr[44] = 16'b1000_101_111_1010_00; // reg_c - reg_h -> reg_f (b_y_new)
    instr[45] = 16'b1010_100_000_1011_00; // load reg_d to reg_e (b_x_new) 

    instr[46] = 16'b0110_100_110_0000_10; // load reg_g to reg_e (a_x -> b_x)  
    instr[47] = 16'b0110_101_111_0000_10; // load reg_h to reg_f (a_y -> b_y)

    instr[48] = 16'b0000_000_000_0000_00; // reg_a-- (k--)
    instr[49] = 16'b000000000101_11_01;   // jump to k check - i[5]
    instr[50] = 16'b1010_100_000_0001_00; // load     '1 to reg_e (b_x)
    instr[51] = 16'b0000_000_000_0000_00; // reg_a-- (k--)
    instr[52] = 16'b000000000101_11_01;   // jump to k check - i[5]


// {k/2; a=ECSum(a,a);}

    instr[53] = 16'b1100_000_110_0001_00; // compare reg_g (a_x) with '1
    instr[54] = 16'b000001000101_01_01;   // if x_p is zero jump to i[69]  <<---??
    instr[55] = 16'b0001_001_110_1110_00; // reg_g * reg_g -> reg_b (a_x^2)
    instr[56] = 16'b0110_010_001_1001_00; // reg_b + reg_b -> reg_c (2*a_x^2) 
    instr[57] = 16'b0110_001_010_1001_00; // reg_b + reg_c -> reg_b (3*a_x^2)
    instr[58] = 16'b0110_001_001_0101_00; // reg_b + a     -> reg_b (3*a_x^2+a)
    instr[59] = 16'b0110_010_111_1111_00; // reg_h + reg_h -> reg_c (2*a_y)
    instr[60] = 16'b0101_010_010_0000_00; // reg_c^-1      -> reg_c (2*a_y^-1) 
    instr[61] = 16'b0001_001_010_1001_00; // reg_b * reg_c -> reg_b (lambda)    
    instr[62] = 16'b0001_010_001_1001_00; // reg_b * reg_b -> reg_c (lambda^2)
    instr[63] = 16'b0110_011_110_1110_00; // reg_g + reg_g -> reg_d (2*a_x) 
    instr[64] = 16'b1000_011_011_1010_00; // reg_c - reg_d -> reg_d (a_x_new)
    instr[65] = 16'b1000_010_011_1110_00; // reg_d - reg_g -> reg_c (a_x-a_x_new)
    instr[66] = 16'b0001_010_010_1001_00; // reg_b * reg_c -> reg_c 
    instr[67] = 16'b1000_111_111_1010_00; // reg_c - reg_h -> reg_h (a_y_new)
    instr[68] = 16'b1010_110_000_1011_00; // load reg_d to reg_g (a_x) 

    instr[69] = 16'b0100_000_000_0000_00; // reg_a >> 1  (k/2)
    instr[70] = 16'b000000000101_11_01;   // jump to k check - i[5]

    instr[71] = 16'b0011_100_000_1100_10; // load (a_x_new) mod_q to reg_e
    instr[72] = 16'b1100_000_100_0000_00; // compare reg_e (a_x) with '0
    instr[73] = 16'b000000000000_01_01;   // if (a_x_new) == '0 jump to i[0] 
    instr[74] = 16'b0001_101_100_0100_10; // d * reg_e -> reg_f (rd mod q)  

    instr[75] = 16'b0011_001_000_0010_10; // load (hash) mod_q to reg_b
    instr[76] = 16'b1100_000_001_0000_00; // compare reg_b (a_x) with '0
    instr[77] = 16'b000001010001_01_01;   // if (reg_b) == '0 jump to i[81] ???

    instr[78] = 16'b0001_001_001_0011_10; // k * reg_b -> reg_b (k*e mod q)
    instr[79] = 16'b0110_101_101_1001_10; // reg_b + reg_f -> reg_f (s)
    instr[80] = 16'b1100_000_101_0000_00; // compare reg_f (s) with '0
    instr[81] = 16'b000000000000_01_01;   // if (a_x_new) == '0 jump to i[0] 
    instr[82] = 16'b0000000000000011;     // === end ===
    
    instr[83] = 16'b0001_100_100_0000_00; //  reg_e++;
    instr[84] = 16'b000001001110_11_01;   // jump to 78


  end




endmodule

`endif


