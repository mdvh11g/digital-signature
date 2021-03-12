
module sv_rq #(
  parameter DATA_WIDTH = 512,
  parameter ROUND_PER_TACT = 4) 
(
  input  logic  clk,
  input  logic  areset,

  input  logic         v_i,
  
  output logic         u_o,
  input  logic         r_i,

  output logic         ready);

  
  typedef enum {
    IDLE, 
    REQ_RND,
    WAIT_REQ_RND,
    TEMP} fsm_state; 

  fsm_state state;


  always @(posedge clk or negedge areset) 
    if (~areset) begin
      state <= IDLE;
      u_o <= '0;
    end
    else case (state)

      IDLE: begin
        if (v_i) begin
          u_o <= '1;
          state <= REQ_RND;
        end
      end 

      REQ_RND: begin
        u_o <= '0;
        state <= WAIT_REQ_RND;
      end

      WAIT_REQ_RND: begin
        if (r_i)
          state <= IDLE;
      end

    endcase


  assign ready = state == IDLE;

endmodule
