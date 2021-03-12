
module sv_ic #(
  parameter DATA_WIDTH = 512,
  parameter ROUND_PER_TACT = 4) 
(
  input  logic  clk,
  input  logic  areset,

  input  logic         v_i,
  input  logic  [7:0]  a_i [DATA_WIDTH/8],
  input  logic  [7:0]  q_i [DATA_WIDTH/8],

  output logic  [7:0]  p_o [DATA_WIDTH/8],  

  output logic         ready);

  logic [DATA_WIDTH-1:0] a_tc, a_fc;
  logic [DATA_WIDTH-1:0] b_tc, b_fc;
  logic [DATA_WIDTH-1:0] s_tc, s_fc;
  logic [DATA_WIDTH-1:0] p_tc, p_fc;

  logic [DATA_WIDTH-1:0] a_u, q_u, p_u;

  genvar i;
 
  generate for (i=0; i < DATA_WIDTH/8; i++) begin
    assign p_o[i] = p_u[8*(i+1)-1:8*i];
    assign a_u[8*(i+1)-1:8*i] = a_i[i];
    assign q_u[8*(i+1)-1:8*i] = q_i[i];
  end endgenerate

  typedef enum {
    IDLE,
    HASHING,
    TEMP
  } fsm_state;
  fsm_state state;

  logic [$clog2(DATA_WIDTH/ROUND_PER_TACT)+1:0] round;

  always @(posedge clk or negedge areset) 
    if (~areset) begin
      state <= IDLE;
      round <= '0;
      a_tc <= '0;
      b_tc <= '0;
      s_tc <= '0;
      p_tc <= '0;
      p_u <= '0;
    end 
    else case (state)
      IDLE: begin
        round <= '0;
        if (v_i) begin
          state <= HASHING;
          a_tc <= 1;
          b_tc <= 0;
          s_tc <= a_u;
          p_tc <= q_u;
        end
      end
      HASHING: begin
        round <= round + 1;
        a_tc <= a_fc;  
        b_tc <= b_fc; 
        s_tc <= s_fc; 
        p_tc <= p_fc;              
        if (round == 2*DATA_WIDTH/ROUND_PER_TACT-1) begin
          p_u <= s_fc[0] ? a_fc : b_fc;
          state <= IDLE;
        end
      end
    endcase


  sv_ie #(DATA_WIDTH,ROUND_PER_TACT)
  sv_ie (
    .q_i(q_u),

    .a_i(a_tc),
    .b_i(b_tc),
    .s_i(s_tc),
    .p_i(p_tc),

    .a_o(a_fc),
    .b_o(b_fc),
    .s_o(s_fc),
    .p_o(p_fc)); 


  assign ready = state == IDLE;

endmodule
