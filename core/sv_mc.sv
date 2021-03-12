
module sv_mc #(
  parameter DATA_WIDTH = 512,
  parameter ROUND_PER_TACT = 4) 
(
  input  logic  clk,
  input  logic  areset,


  input  logic  [7:0] q_i [DATA_WIDTH/8],

  input  logic        v_i, 
  input  logic  [7:0] x_i [DATA_WIDTH/8],  
  input  logic  [7:0] y_i [DATA_WIDTH/8],  

  output logic  [7:0] p_o [DATA_WIDTH/8],  

  output logic        ready);

  logic [DATA_WIDTH-1:0] x_tc, x_fc;
  logic [DATA_WIDTH-1:0] y_tc, y_fc;
  logic [DATA_WIDTH-1:0] z_tc, z_fc;
  logic [DATA_WIDTH-1:0] q_tc, q_fc;  
  logic [DATA_WIDTH-1:0] x_u, y_u, q_u, p_u;

  genvar i;

  generate for (i=0; i < DATA_WIDTH/8; i++) begin
    assign p_o[i] = p_u[8*(i+1)-1:8*i];
    assign q_u[8*(i+1)-1:8*i] = q_i[i];
    assign x_u[8*(i+1)-1:8*i] = x_i[i];
    assign y_u[8*(i+1)-1:8*i] = y_i[i];
  end endgenerate

  typedef enum {
    IDLE,
    HASHING,
    TEMP
  } fsm_state;
  fsm_state state;

  logic [$clog2(DATA_WIDTH/ROUND_PER_TACT):0] round;

  always @(posedge clk or negedge areset) 
    if (~areset) begin
      state <= IDLE;
      round <= '0;
      x_tc <= '0;
      y_tc <= '0;
      p_u <= '0;
    end 
    else case (state)
      IDLE: begin
        round <= '0;
        if (v_i) begin
          state <= HASHING;
          y_tc <= y_u;
          z_tc <= '0;
        end
      end
      HASHING: begin
        round <= round + 1;
          y_tc <= y_fc;
          z_tc <= z_fc;                 
        if (round == DATA_WIDTH/ROUND_PER_TACT-1) begin
          p_u <= z_fc;
          state <= IDLE;
        end
      end
    endcase


  sv_me #(DATA_WIDTH, ROUND_PER_TACT)
  sv_me (
    .q_i(q_u),

    .x_i(x_u),
    .y_i(y_tc),
    .z_i(z_tc),

    .y_o(y_fc),
    .z_o(z_fc));


  assign ready = state == IDLE;

endmodule
