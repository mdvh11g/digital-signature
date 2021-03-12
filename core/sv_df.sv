
module sv_df #(parameter DATA_WIDTH = 16)
(
  input  logic  [DATA_WIDTH-1:0]  a_i,
  input  logic  [2*DATA_WIDTH-1:0]  q_i,

  output logic  [DATA_WIDTH-1:0]  a_o,
  output logic  [2*DATA_WIDTH-1:0]  q_o);

  always_comb begin
    q_o = {q_i[0],q_i[2*DATA_WIDTH-1:1]};
    if (a_i >= q_o) a_o = a_i-q_o;
    else a_o = a_i; end

endmodule
