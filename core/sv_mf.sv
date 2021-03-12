
module sv_mf #(
  parameter DATA_WIDTH = 128) 
(
  input  logic  [DATA_WIDTH-1:0] q_i,

  input  logic  [DATA_WIDTH-1:0] x_i,
  input  logic  [DATA_WIDTH-1:0] y_i,
  input  logic  [DATA_WIDTH-1:0] z_i,

  output logic  [DATA_WIDTH-1:0] y_o,
  output logic  [DATA_WIDTH-1:0] z_o); 

  logic [DATA_WIDTH-1:0] d; 
  logic [DATA_WIDTH-1:0] s;

  sv_ma #(DATA_WIDTH) double   (q_i,z_i,z_i,d);
  sv_ma #(DATA_WIDTH) addition (q_i,d,x_i,s);

  assign z_o = y_i[DATA_WIDTH-1] ? s : d;
  assign y_o = {y_i[DATA_WIDTH-2:0],'0};

endmodule

