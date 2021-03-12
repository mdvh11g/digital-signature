

module sv_de #(
  parameter DATA_WIDTH = 512,
  parameter ROUND_PER_TACT = 1)
(

  input  logic  [DATA_WIDTH-1:0]  a_i,
  input  logic  [2*DATA_WIDTH-1:0]  q_i,

  output logic  [DATA_WIDTH-1:0]  a_o,
  output logic  [2*DATA_WIDTH-1:0]  q_o);
 
  logic [DATA_WIDTH-1:0] a [0:ROUND_PER_TACT];
  logic [2*DATA_WIDTH-1:0] q [0:ROUND_PER_TACT];
  
  assign a[0] = a_i;
  assign q[0] = q_i;

  genvar i;

  generate for (i=0; i<ROUND_PER_TACT; i++) begin

    sv_df #(DATA_WIDTH)
    df (
      .a_i(a[i]),
      .q_i(q[i]),

      .a_o(a[i+1]),
      .q_o(q[i+1])); 

  end endgenerate

  assign a_o = a[ROUND_PER_TACT];
  assign q_o = q[ROUND_PER_TACT]; 

endmodule
