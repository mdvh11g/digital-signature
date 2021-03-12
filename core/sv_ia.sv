

module sv_ia #(parameter DATA_WIDTH = 512)
(
  input  logic [DATA_WIDTH-1:0] q_i,

  input  logic [DATA_WIDTH-1:0] a_i,
  input  logic [DATA_WIDTH-1:0] b_i,
  input  logic [DATA_WIDTH-1:0] s_i,
  input  logic [DATA_WIDTH-1:0] p_i,

  output logic [DATA_WIDTH-1:0] a_o,
  output logic [DATA_WIDTH-1:0] b_o,
  output logic [DATA_WIDTH-1:0] s_o,
  output logic [DATA_WIDTH-1:0] p_o); 

  logic [DATA_WIDTH-1:0] a;
  logic [DATA_WIDTH-1:0] b;
  logic [DATA_WIDTH-1:0] s;
  logic [DATA_WIDTH-1:0] p;  
   
  sv_ii #(DATA_WIDTH)
  ii_a (
    .q_i(q_i),
    .a_i(a_i), 
    .u_i(s_i), 
    .a_o(a),
    .u_o(s));  

  sv_ii #(DATA_WIDTH)
  ii_b (
    .q_i(q_i),
    .a_i(b_i), 
    .u_i(p_i), 
    .a_o(b),
    .u_o(p));  
  
  sv_io #(DATA_WIDTH)
  io (
    .q_i(q_i),

    .a_i(a), 
    .b_i(b),
    .u_i(s), 
    .v_i(p), 

    .a_o(a_o),
    .b_o(b_o),
    .u_o(s_o),
    .v_o(p_o)); 



endmodule
