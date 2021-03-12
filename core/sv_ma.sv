
module sv_ma #(
  parameter DATA_WIDTH = 128)
(
  input  logic [DATA_WIDTH-1:0] q,

  input  logic [DATA_WIDTH-1:0] a, 
  input  logic [DATA_WIDTH-1:0] b, 

  output logic [DATA_WIDTH-1:0] s); 

  always_comb begin 
    if (a+b>=q) s = a+b-q;
    else s = a+b;
  end

endmodule
