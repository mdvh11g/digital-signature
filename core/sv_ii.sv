
module sv_ii #(
  parameter DATA_WIDTH = 128)
(
  input logic [DATA_WIDTH-1:0]  q_i,

  input  logic [DATA_WIDTH-1:0] a_i, 
  input  logic [DATA_WIDTH-1:0] u_i, 

  output logic [DATA_WIDTH-1:0] a_o,
  output logic [DATA_WIDTH-1:0] u_o); 

  logic [DATA_WIDTH:0] s;
 
  assign s = a_i + q_i;

  always_comb begin
    if (u_i[0]) {u_o, a_o} = {u_i, a_i};
    else begin
      u_o = {'0,u_i[DATA_WIDTH-1:1]}; 
      if (a_i[0]) a_o = s [DATA_WIDTH:1];
      else a_o = {'0,a_i[DATA_WIDTH-1:1]}; 
    end 
  end

endmodule
