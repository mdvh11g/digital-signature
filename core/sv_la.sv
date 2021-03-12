
module sv_la #(
  parameter BLOCK_SIZE = 1024)
(  

  input  logic [7:0] q_i [BLOCK_SIZE/8],

  input  logic [2:0] i_i,
  input  logic [7:0] a_i [BLOCK_SIZE/8],
  input  logic [7:0] b_i [BLOCK_SIZE/8],

  output logic [7:0] r_o [BLOCK_SIZE/8], 
  output logic       c_o);

  logic [BLOCK_SIZE-1:0] q_u, a_u, b_u, r_u, r_a, r_s;

  genvar i;

  generate for (i = 0; i < BLOCK_SIZE/8; i++) begin
    assign r_o[i] = r_u[8*(i+1)-1:8*i];
    assign q_u[8*(i+1)-1:8*i] = q_i[i];
    assign a_u[8*(i+1)-1:8*i] = a_i[i];
    assign b_u[8*(i+1)-1:8*i] = b_i[i];
  end endgenerate 

  always_comb begin {c_o, r_u} = '0;
    case (i_i)
      0: r_u = b_u-1; // a-1
      1: r_u = b_u+1; // a+1
      2: r_u = {1'b0,b_u[BLOCK_SIZE-1:1]}; // a>>1  
      3: r_u = r_a; // (a+b) mod q
      4: r_u = r_s; // (a-b) mod q
      5: r_u = a_u; // 
      6: c_o = (a_u == b_u)? '1:'0;  // a equal b
      7: c_o = (b_u[0]=='1)? '1:'0; // odd/even


    //6: {c_o, r_u} = {(a_u > b_u) ? 1'b1:1'b0,'0}; // a > b  
    //7: {c_o, r_u} = {(a_u < b_u) ? 1'b1:1'b0,'0}; // a < b
    endcase 
  end

  sv_ma #(BLOCK_SIZE)
  sv_ma   (
    .q(q_u),
    .a(a_u), 
    .b(b_u), 
    .s(r_a));   

  sv_ms #(BLOCK_SIZE)
  sv_ms (
    .q(q_u),
    .a(a_u),
    .b(b_u),
    .s(r_s));




endmodule


