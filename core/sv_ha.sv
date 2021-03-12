
module sv_ha #(
  parameter BLOCK_SIZE = 512,
  parameter CORE_ROUND = 4) 
(
  input  logic  clk,
  input  logic  areset,

  input  logic [7:0] q_i [BLOCK_SIZE/8],

  input  logic       v_i,
  input  logic [2:0] i_i,

  input  logic [7:0] a_i [BLOCK_SIZE/8],
  input  logic [7:0] b_i [BLOCK_SIZE/8],

  output logic [7:0] r_o [BLOCK_SIZE/8],  

  output logic       rand_req_o,
  input  logic       rand_ready_i, 

  output logic       ready);

  logic v_tm, v_td, v_ti, v_tq;
  logic r_fm, r_fd, r_fi, t_fq;

  logic [7:0] p_fm [BLOCK_SIZE/8];
  logic [7:0] p_fd [BLOCK_SIZE/8];
  logic [7:0] p_fi [BLOCK_SIZE/8];

  always_comb begin 
   {v_tm, v_td, v_ti} = '0;
    case (i_i)
      0: v_tm = v_i;
      1: v_td = v_i;
      2: v_ti = v_i;
      3: v_tq = v_i;
    endcase
  end

  always_comb begin 
    for (int i = 0; i < BLOCK_SIZE/8; i++ )r_o[i] = '0;
    case (i_i)
      0: r_o = p_fm;
      1: r_o = p_fd;
      2: r_o = p_fi;
    endcase 
  end

  sv_mc #(BLOCK_SIZE,CORE_ROUND) 
  sv_mc (
    .clk(clk),
    .areset(areset),
    .q_i(q_i),
    .v_i(v_tm), 
    .x_i(a_i),  
    .y_i(b_i),  
    .p_o(p_fm),  
    .ready(r_fm));

  sv_dc #(BLOCK_SIZE,CORE_ROUND) 
  sv_dc (
    .clk(clk),
    .areset(areset),
    .v_i(v_td),
    .a_i(a_i),
    .q_i(q_i),
    .p_o(p_fd),  
    .ready(r_fd));
  
  sv_ic #(BLOCK_SIZE,CORE_ROUND)
  sv_ic (
    .clk(clk),
    .areset(areset),
    .v_i(v_ti),
    .a_i(b_i),
    .q_i(q_i),
    .p_o(p_fi),  
    .ready(r_fi));


  sv_rq #(BLOCK_SIZE,CORE_ROUND) 
  sv_rq (
    .clk(clk),
    .areset(areset),

    .v_i(v_tq),
  
    .u_o(rand_req_o),
    .r_i(rand_ready_i),

    .ready(r_fq));


  assign ready = r_fm & r_fd & r_fi;

endmodule



