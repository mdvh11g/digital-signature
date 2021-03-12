
module sv_ms #(
  parameter DATA_WIDTH = 1024)
(
  input  logic [DATA_WIDTH-1:0] q,

  input  logic [DATA_WIDTH-1:0] a,
  input  logic [DATA_WIDTH-1:0] b,

  output logic [DATA_WIDTH-1:0] s);

  always_comb begin 
    if (b>a) s = a-b + q;
    else s = a-b; end


endmodule
