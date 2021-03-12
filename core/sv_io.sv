
module sv_io #(
  parameter DATA_WIDTH = 128)
(
  input logic [DATA_WIDTH-1:0]  q_i,

  input  logic [DATA_WIDTH-1:0] a_i, 
  input  logic [DATA_WIDTH-1:0] b_i,
  input  logic [DATA_WIDTH-1:0] u_i, 
  input  logic [DATA_WIDTH-1:0] v_i, 

  output logic [DATA_WIDTH-1:0] a_o,
  output logic [DATA_WIDTH-1:0] b_o,
  output logic [DATA_WIDTH-1:0] u_o,
  output logic [DATA_WIDTH-1:0] v_o); 

  logic [DATA_WIDTH-1:0] sa, sb;

  sv_ms #(DATA_WIDTH) ms_a (q_i,a_i,b_i,sa);
  sv_ms #(DATA_WIDTH) ms_b (q_i,b_i,a_i,sb);

  always_comb begin
    if (u_i>=v_i) {a_o,b_o,u_o,v_o} = {sa,b_i,u_i-v_i,v_i};
    else {a_o,b_o,u_o,v_o} = {a_i,sb,u_i,v_i-u_i}; end

endmodule
