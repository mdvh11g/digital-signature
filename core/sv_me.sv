

module sv_me #(
  parameter DATA_WIDTH = 512,
  parameter ROUND_PER_TACT = 1)
(
  input  logic   [DATA_WIDTH-1:0] q_i,

  input  logic   [DATA_WIDTH-1:0] x_i,
  input  logic   [DATA_WIDTH-1:0] y_i,
  input  logic   [DATA_WIDTH+1:0] z_i,

  output logic   [DATA_WIDTH-1:0] y_o,
  output logic   [DATA_WIDTH+1:0] z_o);


  logic   [DATA_WIDTH-1:0] y [0:ROUND_PER_TACT];
  logic   [DATA_WIDTH-1:0] z [0:ROUND_PER_TACT];

  assign y[0] = y_i;
  assign z[0] = z_i;

  genvar i;

  generate for (i=0; i<ROUND_PER_TACT; i++) begin
    sv_mf #(DATA_WIDTH) 
    sv_mf (
      .q_i(q_i),

      .x_i(x_i),
      .y_i(y[i]),
      .z_i(z[i]),

      .y_o(y[i+1]),
      .z_o(z[i+1])); 

  end endgenerate

  assign y_o = y[ROUND_PER_TACT];
  assign z_o = z[ROUND_PER_TACT];  



endmodule
