
module sv_dc #(
  parameter DATA_WIDTH = 512,
  parameter ROUND_PER_TACT = 4) 
(
  input  logic  clk,
  input  logic  areset,

  input  logic  [7:0]  a_i [DATA_WIDTH/8],
  input  logic  [7:0]  q_i [DATA_WIDTH/8],
  input  logic         v_i,

  output logic  [7:0]  p_o [DATA_WIDTH/8],  

  output logic         ready);

  logic [DATA_WIDTH-1:0] a_tc, a_fc;
  logic [2*DATA_WIDTH-1:0] q_tc, q_fc;  
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

  logic [$clog2(DATA_WIDTH/ROUND_PER_TACT):0] round;

  always @(posedge clk or negedge areset) 
    if (~areset) begin
      state <= IDLE;
      round <= '0;
      a_tc <= '0;
      q_tc <= '0;
      p_u <= '0;
    end 
    else case (state)
      IDLE: begin
        round <= '0;
        if (v_i) begin
          state <= HASHING;
          a_tc <= a_u;
          q_tc <= {q_u,{DATA_WIDTH{1'b0}}};
        end
      end
      HASHING: begin
        round <= round + 1;
        a_tc <= a_fc;
        q_tc <= q_fc;                  
        if (round == DATA_WIDTH/ROUND_PER_TACT-1) begin
          p_u <= a_fc;
          state <= IDLE;
        end
      end
    endcase

  sv_de #(
    DATA_WIDTH,
    ROUND_PER_TACT)
  de (
    .a_i(a_tc),
    .q_i(q_tc),
    .a_o(a_fc),
    .q_o(q_fc));

  assign ready = state == IDLE;

endmodule
