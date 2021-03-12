
module sv_ex #(
  parameter BLOCK_SIZE = 512,
  parameter CORE_ROUND = 4) 
(
  input  logic  clk,
  input  logic  areset,

  input  logic        v_i,
  input  logic [14:0] i_i,

  input  logic [7:0] freg_a [BLOCK_SIZE/8],   // p  
  input  logic [7:0] freg_b [BLOCK_SIZE/8],   // q
  input  logic [7:0] freg_c [BLOCK_SIZE/8],   // hash
  input  logic [7:0] freg_d [BLOCK_SIZE/8],   // rand
  input  logic [7:0] freg_e [BLOCK_SIZE/8],   // key
  input  logic [7:0] freg_f [BLOCK_SIZE/8],   // curve_a   
  input  logic [7:0] freg_g [BLOCK_SIZE/8],   // x_p
  input  logic [7:0] freg_h [BLOCK_SIZE/8],   // y_p

  output logic       comp_o,

  output logic [7:0] hash_a [BLOCK_SIZE/8], 
  output logic [7:0] hash_b [BLOCK_SIZE/8], 
  output logic [7:0] hash_c [BLOCK_SIZE/8], 
  output logic [7:0] hash_d [BLOCK_SIZE/8], 
  output logic [7:0] hash_e [BLOCK_SIZE/8], 
  output logic [7:0] hash_f [BLOCK_SIZE/8], 
  output logic [7:0] hash_g [BLOCK_SIZE/8], 
  output logic [7:0] hash_h [BLOCK_SIZE/8], 

  output logic       rand_req_o,
  input  logic       rand_ready_i,

  output logic       ready);

  logic [7:0] a_ex [BLOCK_SIZE/8];
  logic [7:0] b_ex [BLOCK_SIZE/8];
  logic [7:0] l_ex [BLOCK_SIZE/8];
  logic [7:0] h_ex [BLOCK_SIZE/8];

  logic [7:0] f_ex [BLOCK_SIZE/8];

  logic v_th, r_fh, c_fl;

  typedef enum {
    IDLE,
    HASHING,
    WAIT_HASH,
    TEMP} fsm_state;
  fsm_state state;

  always @(posedge clk or negedge areset)
    if (~areset) begin
      state <= IDLE;
      v_th <= '0;
      comp_o <= '0;
      for (int i=0; i < BLOCK_SIZE/8; i++) begin
        f_ex[i]   <= '0;
        a_ex[i]   <= '0;
        b_ex[i]   <= '0;
        hash_a[i] <= '1;
        hash_b[i] <= '1;
        hash_c[i] <= '1;
        hash_d[i] <= '1;
        hash_e[i] <= '1;
        hash_f[i] <= '1;
        hash_g[i] <= '1;
        hash_h[i] <= '1;
      end
    end

    else case (state)

      IDLE: begin
        if (v_i) begin
          state <= HASHING;
          if (i_i[11]) v_th <= '1;
          f_ex <= i_i[0] ? freg_b : freg_a; 
          case (i_i[4:1])
            0: for (int i=0; i < BLOCK_SIZE/8; i++) a_ex[i] <= '0;
            1: for (int i=0; i < BLOCK_SIZE/8; i++) a_ex[i] <= '1; 
            2: a_ex <= freg_c; 
            3: a_ex <= freg_d; 
            4: a_ex <= freg_e;  
            5: a_ex <= freg_f; 
            6: a_ex <= freg_g; 
            7: a_ex <= freg_h; 
            8: a_ex <= hash_a;
            9: a_ex <= hash_b;
           10: a_ex <= hash_c;
           11: a_ex <= hash_d; 
           12: a_ex <= hash_e; 
           13: a_ex <= hash_f;
           14: a_ex <= hash_g; 
           15: a_ex <= hash_h;
          endcase  
          case (i_i[7:5])
            0: b_ex <= hash_a;
            1: b_ex <= hash_b;
            2: b_ex <= hash_c;
            3: b_ex <= hash_d; 
            4: b_ex <= hash_e; 
            5: b_ex <= hash_f; 
            6: b_ex <= hash_g;
            7: b_ex <= hash_h; 
          endcase 
        end
      end

      HASHING: begin
        if (i_i[11]) begin
          v_th <= '0;
          state <= WAIT_HASH;
        end
        else begin
          state <= IDLE;
          if (i_i[14:12] > 5) comp_o <= c_fl;
          else case (i_i[10:8])
            0: hash_a <= l_ex; 
            1: hash_b <= l_ex; 
            2: hash_c <= l_ex; 
            3: hash_d <= l_ex;    
            4: hash_e <= l_ex;     
            5: hash_f <= l_ex;    
            6: hash_g <= l_ex;     
            7: hash_h <= l_ex;     
          endcase
        end
      end  

      WAIT_HASH: begin
        if (r_fh) begin
          state <= IDLE;
          case (i_i[10:8])
            0: hash_a <= h_ex; 
            1: hash_b <= h_ex; 
            2: hash_c <= h_ex; 
            3: hash_d <= h_ex; 
            4: hash_e <= h_ex;    
            5: hash_f <= h_ex;   
            6: hash_g <= h_ex;    
            7: hash_h <= h_ex;          
          endcase
        end   
      end
    endcase
  

  sv_la #(BLOCK_SIZE)
  sv_la  (  
    .q_i(f_ex),
    .i_i(i_i[14:12]),
    .a_i(a_ex),
    .b_i(b_ex),
    .r_o(l_ex), 
    .c_o(c_fl));


  sv_ha #(BLOCK_SIZE,CORE_ROUND) 
  sv_ha (
    .clk(clk),
    .areset(areset),
    .v_i(v_th),
    .q_i(f_ex),
    .i_i(i_i[14:12]),
    .a_i(a_ex),
    .b_i(b_ex),
    .r_o(h_ex), 
    .rand_req_o(rand_req_o),
    .rand_ready_i(rand_ready_i), 
    .ready(r_fh));

  assign ready = state == IDLE;

endmodule



