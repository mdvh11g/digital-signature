
module svarog #(
  parameter DATA_SIZE  = 32,
  parameter ADDR_SIZE  = 32,
  parameter CORE_ROUND = 1,
  parameter BLOCK_SIZE = 256)
(
  input  logic areset,
  input  logic clk,

  input  logic  [ADDR_SIZE-1:0] a_i,
  input  logic                  c_i,
  input  logic                  w_i,
  input  logic            [2:0] s_i,
  input  logic  [DATA_SIZE-1:0] d_i,
  output logic  [DATA_SIZE-1:0] d_o,

  input  logic [BLOCK_SIZE-1:0] hash_i,
  input  logic [BLOCK_SIZE-1:0] rand_i,

  output logic       rand_req_o,
  input  logic       rand_ready_i,
 
  output logic       irq_o,  
  output logic       ready);

  logic [7:0] freg_a [BLOCK_SIZE/8];     
  logic [7:0] freg_b [BLOCK_SIZE/8]; 
  logic [7:0] creg_a [BLOCK_SIZE/8];    
  logic [7:0] creg_b [BLOCK_SIZE/8];
  logic [7:0] creg_c [BLOCK_SIZE/8];    
  logic [7:0] creg_d [BLOCK_SIZE/8];

  logic [7:0] hash_a [BLOCK_SIZE/8];     
  logic [7:0] hash_b [BLOCK_SIZE/8]; 
  logic [7:0] hash_c [BLOCK_SIZE/8]; 
  logic [7:0] hash_d [BLOCK_SIZE/8]; 
  logic [7:0] hash_e [BLOCK_SIZE/8]; 
  logic [7:0] hash_f [BLOCK_SIZE/8]; 
  logic [7:0] hash_g [BLOCK_SIZE/8]; 
  logic [7:0] hash_h [BLOCK_SIZE/8]; 

  logic [7:0] i_hash [BLOCK_SIZE/8];     
  logic [7:0] i_rand [BLOCK_SIZE/8]; 

  logic [15:0] instruction;
  logic [7:0] inst_address; 
  logic  instruction_valid;

  logic [15:0] update_data;
  logic  [7:0] update_addr;
  logic        update_bank; 
  logic instruction_update;

  logic v_tc, r_fc;

  logic [7:0] start_addr;  

  genvar i;

  generate for (i=0; i <BLOCK_SIZE/8; i++) begin
    assign i_hash[i] = hash_i[8*(i+1)-1:8*i];
    assign i_rand[i] = rand_i[8*(i+1)-1:8*i];

  end endgenerate
  
  
  typedef enum {
    IDLE,
    HASHING,
    WAIT_HASH,
    TEMP} fsm_state;

  fsm_state state;

  always @(posedge clk or negedge areset)
    if (~areset) begin
      v_tc <= '0;
      irq_o <= '0;
      state <= IDLE;
      start_addr <= '0;
      update_addr <= '0;
      update_data <= '0;
      instruction_update <= '0;
      for (int i=0; i < BLOCK_SIZE/8; i++) begin
        freg_a[i] <= '0; 
        freg_b[i] <= '0;
        creg_a[i] <= '0;
        creg_b[i] <= '0;
        creg_c[i] <= '0;
        creg_d[i] <= '0;
      end
    end
    else case (state)
      
      IDLE: begin
        irq_o <= '0;
        update_bank <= '0;
        instruction_update <= '0;
        if (c_i & w_i) begin
          case (a_i[ADDR_SIZE-1:8])

            0: begin 
                  if (a_i[7] == '0) begin
                    state <= HASHING;
                    v_tc <= '1;
                  end
                  else begin
                    case (a_i[6:0])
                      0: start_addr <= d_i[7:0];
                    endcase 
                  end
                end 

            1: case (s_i)
                 0:  freg_a[a_i[7:0]] <= d_i[7:0];
                 1: {freg_a[a_i[7:0]+1],
                     freg_a[a_i[7:0]]} <= d_i[15:0]; 
                 2: {freg_a[a_i[7:0]+3],
                     freg_a[a_i[7:0]+2],
                     freg_a[a_i[7:0]+1],
                     freg_a[a_i[7:0]]} <= d_i[31:0];
              // 3: ...
               endcase 

            2: case (s_i)
                 0:  freg_b[a_i[7:0]] <= d_i[7:0];
                 1: {freg_b[a_i[7:0]+1],
                     freg_b[a_i[7:0]]} <= d_i[15:0]; 
                 2: {freg_b[a_i[7:0]+3],
                     freg_b[a_i[7:0]+2],
                     freg_b[a_i[7:0]+1],
                     freg_b[a_i[7:0]]} <= d_i[31:0];
              // 3: ...
               endcase 

            3: case (s_i)
                 0:  creg_a[a_i[7:0]] <= d_i[7:0];
                 1: {creg_a[a_i[7:0]+1],
                     creg_a[a_i[7:0]]} <= d_i[15:0]; 
                 2: {creg_a[a_i[7:0]+3],
                     creg_a[a_i[7:0]+2],
                     creg_a[a_i[7:0]+1],
                     creg_a[a_i[7:0]]} <= d_i[31:0];
              // 3: ...
               endcase   

            4: case (s_i)
                 0:  creg_b[a_i[7:0]] <= d_i[7:0];
                 1: {creg_b[a_i[7:0]+1],
                     creg_b[a_i[7:0]]} <= d_i[15:0]; 
                 2: {creg_b[a_i[7:0]+3],
                     creg_b[a_i[7:0]+2],
                     creg_b[a_i[7:0]+1],
                     creg_b[a_i[7:0]]} <= d_i[31:0];
              // 3: ...
               endcase   

            5: case (s_i)
                 0:  creg_c[a_i[7:0]] <= d_i[7:0];
                 1: {creg_c[a_i[7:0]+1],
                     creg_c[a_i[7:0]]} <= d_i[15:0]; 
                 2: {creg_c[a_i[7:0]+3],
                     creg_c[a_i[7:0]+2],
                     creg_c[a_i[7:0]+1],
                     creg_c[a_i[7:0]]} <= d_i[31:0];
              // 3: ...
               endcase  

            6: case (s_i)
                 0:  creg_d[a_i[7:0]] <= d_i[7:0];
                 1: {creg_d[a_i[7:0]+1],
                     creg_d[a_i[7:0]]} <= d_i[15:0]; 
                 2: {creg_d[a_i[7:0]+3],
                     creg_d[a_i[7:0]+2],
                     creg_d[a_i[7:0]+1],
                     creg_d[a_i[7:0]]} <= d_i[31:0];
              // 3: ...
               endcase 

            7: begin 
                 if (s_i[0]=='1) begin
                   update_addr <= update_bank ? a_i[7:1]+128 : a_i[7:1];
                   update_data <= a_i[0] ? d_i[31:16] : d_i[15:0];
                   instruction_update <= '1;
                 end
               end

          endcase 
        end

        if (c_i & ~w_i)  begin

          case (a_i[ADDR_SIZE-1:8])
            0: case (s_i)
                 0: d_o <= {DATA_SIZE/8{hash_a[a_i[7:0]]}};
                 1: d_o <= {DATA_SIZE/16{hash_a[a_i[7:0]+1],hash_a[a_i[7:0]]}};
                 2: d_o <= {DATA_SIZE/32{hash_a[a_i[7:0]+3],hash_a[a_i[7:0]+2],
                                         hash_a[a_i[7:0]+1],hash_a[a_i[7:0]]}};
              // 3: ...
               endcase 
            1: case (s_i)
                 0: d_o <= {DATA_SIZE/8{hash_b[a_i[7:0]]}};
                 1: d_o <= {DATA_SIZE/16{hash_b[a_i[7:0]+1],hash_b[a_i[7:0]]}};
                 2: d_o <= {DATA_SIZE/32{hash_b[a_i[7:0]+3],hash_b[a_i[7:0]+2],
                                         hash_b[a_i[7:0]+1],hash_b[a_i[7:0]]}};
              // 3: ...
               endcase 
            2: case (s_i)
                 0: d_o <= {DATA_SIZE/8{hash_c[a_i[7:0]]}};
                 1: d_o <= {DATA_SIZE/16{hash_c[a_i[7:0]+1],hash_c[a_i[7:0]]}};
                 2: d_o <= {DATA_SIZE/32{hash_c[a_i[7:0]+3],hash_c[a_i[7:0]+2],
                                         hash_c[a_i[7:0]+1],hash_c[a_i[7:0]]}};
              // 3: ...
               endcase 
            3: case (s_i)
                 0: d_o <= {DATA_SIZE/8{hash_d[a_i[7:0]]}};
                 1: d_o <= {DATA_SIZE/16{hash_d[a_i[7:0]+1],hash_d[a_i[7:0]]}};
                 2: d_o <= {DATA_SIZE/32{hash_d[a_i[7:0]+3],hash_d[a_i[7:0]+2],
                                         hash_d[a_i[7:0]+1],hash_d[a_i[7:0]]}};
              // 3: ...
               endcase 
            4: case (s_i)
                 0: d_o <= {DATA_SIZE/8{hash_e[a_i[7:0]]}};
                 1: d_o <= {DATA_SIZE/16{hash_e[a_i[7:0]+1],hash_e[a_i[7:0]]}};
                 2: d_o <= {DATA_SIZE/32{hash_e[a_i[7:0]+3],hash_e[a_i[7:0]+2],
                                         hash_e[a_i[7:0]+1],hash_e[a_i[7:0]]}};
              // 3: ...
               endcase 
            5: case (s_i)
                 0: d_o <= {DATA_SIZE/8{hash_f[a_i[7:0]]}};
                 1: d_o <= {DATA_SIZE/16{hash_f[a_i[7:0]+1],hash_f[a_i[7:0]]}};
                 2: d_o <= {DATA_SIZE/32{hash_f[a_i[7:0]+3],hash_f[a_i[7:0]+2],
                                         hash_f[a_i[7:0]+1],hash_f[a_i[7:0]]}};
              // 3: ...
               endcase 
            6: case (s_i)
                 0: d_o <= {DATA_SIZE/8{hash_g[a_i[7:0]]}};
                 1: d_o <= {DATA_SIZE/16{hash_g[a_i[7:0]+1],hash_g[a_i[7:0]]}};
                 2: d_o <= {DATA_SIZE/32{hash_g[a_i[7:0]+3],hash_g[a_i[7:0]+2],
                                         hash_g[a_i[7:0]+1],hash_g[a_i[7:0]]}};
              // 3: ...
               endcase 
            7: case (s_i)
                 0: d_o <= {DATA_SIZE/8{hash_h[a_i[7:0]]}};
                 1: d_o <= {DATA_SIZE/16{hash_h[a_i[7:0]+1],hash_h[a_i[7:0]]}};
                 2: d_o <= {DATA_SIZE/32{hash_h[a_i[7:0]+3],hash_h[a_i[7:0]+2],
                                         hash_h[a_i[7:0]+1],hash_h[a_i[7:0]]}};
              // 3: ...
               endcase 

          endcase 
        end
      end
  

      HASHING: begin
        v_tc <= '0;
        state <= WAIT_HASH;
      end

      WAIT_HASH: begin
        if (r_fc) begin
          irq_o <= '1;
          state <= IDLE;
        end
      end
    
    endcase



  sv_ec #(BLOCK_SIZE,CORE_ROUND) 
  sv_ec  (

    .clk(clk),
    .areset(areset),

    .v_i(v_tc),
  
    .freg_a(freg_a),  // p
    .freg_b(freg_b),  // q
    .freg_c(i_hash),  // hash   
    .freg_d(i_rand),  // rand
    .freg_e(creg_a),  // key   
    .freg_f(creg_b),  // curve a
    .freg_g(creg_c),  // x_p   
    .freg_h(creg_d),  // y_p

    .hash_a(hash_a), 
    .hash_b(hash_b),
    .hash_c(hash_c),
    .hash_d(hash_d),
    .hash_e(hash_e),
    .hash_f(hash_f),
    .hash_g(hash_g),
    .hash_h(hash_h),

    .instr_i(instruction),    
    .iaddr_o(inst_address),
    .ivalid_o(instruction_valid),

    .rand_req_o(rand_req_o),
    .rand_ready_i(rand_ready_i),

    .start_addr_i(start_addr),

    .ready(r_fc));


  sv_im #(BLOCK_SIZE,CORE_ROUND) 
  sv_im (
    .clk(clk),
    .areset(areset),

    .valid_i(instruction_valid),
    .iaddr_i(inst_address),
    .instr_o(instruction),

    .update_i(instruction_update),
    .upaddr_i(update_addr),
    .updata_i(update_data));


  assign ready = state == IDLE;


endmodule



