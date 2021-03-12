
module sv_ie #(
  parameter DATA_WIDTH = 512,
  parameter ROUND_PER_TACT = 1)
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

  logic [DATA_WIDTH-1:0] a [0:ROUND_PER_TACT];
  logic [DATA_WIDTH-1:0] b [0:ROUND_PER_TACT];
  logic [DATA_WIDTH-1:0] s [0:ROUND_PER_TACT];
  logic [DATA_WIDTH-1:0] p [0:ROUND_PER_TACT];

  assign a[0] = a_i;
  assign b[0] = b_i;
  assign s[0] = s_i;
  assign p[0] = p_i;

  genvar i;

  generate for (i=0; i<ROUND_PER_TACT; i++) begin
    sv_ia #(DATA_WIDTH)
    sv_ia (
      .q_i(q_i),

      .a_i(a[i]),
      .b_i(b[i]),
      .s_i(s[i]),
      .p_i(p[i]),

      .a_o(a[i+1]),
      .b_o(b[i+1]),
      .s_o(s[i+1]),
      .p_o(p[i+1])); 

  end endgenerate

  assign a_o = a[ROUND_PER_TACT];
  assign b_o = b[ROUND_PER_TACT];
  assign s_o = s[ROUND_PER_TACT];
  assign p_o = p[ROUND_PER_TACT];

endmodule


