
module sv_ec #(
  parameter BLOCK_SIZE = 256,
  parameter CORE_ROUND = 1) 
(
  input  logic  clk,
  input  logic  areset,

  input  logic  v_i,
  
  input  logic  [7:0] freg_a [BLOCK_SIZE/8],     
  input  logic  [7:0] freg_b [BLOCK_SIZE/8], 
  input  logic  [7:0] freg_c [BLOCK_SIZE/8],
  input  logic  [7:0] freg_d [BLOCK_SIZE/8],
  input  logic  [7:0] freg_e [BLOCK_SIZE/8],
  input  logic  [7:0] freg_f [BLOCK_SIZE/8],     
  input  logic  [7:0] freg_g [BLOCK_SIZE/8], 
  input  logic  [7:0] freg_h [BLOCK_SIZE/8], 

  output logic  [7:0] hash_a [BLOCK_SIZE/8], 
  output logic  [7:0] hash_b [BLOCK_SIZE/8], 
  output logic  [7:0] hash_c [BLOCK_SIZE/8], 
  output logic  [7:0] hash_d [BLOCK_SIZE/8], 
  output logic  [7:0] hash_e [BLOCK_SIZE/8], 
  output logic  [7:0] hash_f [BLOCK_SIZE/8], 
  output logic  [7:0] hash_g [BLOCK_SIZE/8], 
  output logic  [7:0] hash_h [BLOCK_SIZE/8], 

  input  logic [15:0] instr_i,    
  output logic [15:0] iaddr_o,
  output logic        ivalid_o,

  input  logic  [7:0] start_addr_i,

  output logic        rand_req_o,
  input  logic        rand_ready_i,

  output logic        ready);

  logic [15:0] i_te;
  logic v_te, c_fe, r_fe;
  
  logic v_ti, r_fi;

  typedef enum {
    IDLE,
    HASHING,
    WAIT_HASH,
    TEMP} fsm_state;

  fsm_state state;


  always @(posedge clk or negedge areset) 
    if (~areset) begin
      state <= IDLE;
      v_ti <= '0;
    end
    else case (state)
      IDLE: begin
        if (v_i) begin
          state <= HASHING;
          v_ti <= '1;
        end
      end
      HASHING: begin
        v_ti <= '0;
        state <= WAIT_HASH;
      end
      WAIT_HASH: begin
        if (r_fi)
          state <= IDLE;
      end
    endcase



  sv_if #(BLOCK_SIZE,CORE_ROUND) 
  sv_if (
    .clk(clk),
    .areset(areset),

    .v_i(v_ti),

    .instr_i(instr_i),    
    .iaddr_o(iaddr_o),
    .ivalid_o(ivalid_o),

    .ex_i_o(i_te),
    .ex_v_o(v_te),
    .ex_r_i(r_fe),
    .ex_c_i(c_fe),

    .st_a_i(start_addr_i),

    .ready(r_fi));




  sv_ex #(BLOCK_SIZE,CORE_ROUND) 
  sv_ex (
    .clk(clk),
    .areset(areset),

    .v_i(v_te),
    .i_i(i_te),

    .freg_a(freg_a),     
    .freg_b(freg_b), 
    .freg_c(freg_c), 
    .freg_d(freg_d), 
    .freg_e(freg_e), 
    .freg_f(freg_f), 
    .freg_g(freg_g), 
    .freg_h(freg_h), 
 
    .comp_o(c_fe),

    .hash_a(hash_a),
    .hash_b(hash_b),
    .hash_c(hash_c),
    .hash_d(hash_d),
    .hash_e(hash_e),
    .hash_f(hash_f),
    .hash_g(hash_g),
    .hash_h(hash_h),

    .rand_req_o(rand_req_o),
    .rand_ready_i(rand_ready_i),

    .ready(r_fe));


  assign ready = state == IDLE;


endmodule
