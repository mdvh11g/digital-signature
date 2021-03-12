
// .......1 - brantches
// ......11 - ret
// .....001 - nop
// ....1101 - jump 
// ....0101 - jump if compare result true

// .......0 - execute


module sv_if #(
  parameter BLOCK_SIZE = 512,
  parameter CORE_ROUND = 4) 
(
  input  logic  clk,
  input  logic  areset,

  input  logic  v_i,


  input  logic [15:0] instr_i,    
  output logic  [7:0] iaddr_o,
  output logic        ivalid_o,

  output logic [14:0] ex_i_o,
  output logic        ex_v_o,
  input  logic        ex_c_i,
  input  logic        ex_r_i,

  input  logic  [7:0] st_a_i,

  output logic        ready);

  logic [7:0] pc, save_pc;

  typedef enum {
    IDLE,
    INSTRUCTION_REQUEST,
    INSTRUCTION_FETCH,
    INSTRUCTION_DECODE,    
    INSTRUCTION_EXECUTE,
    WAIT_EXECUTE_RESULT,
    TEMP} fsm_state;

  fsm_state state; 

  assign iaddr_o = pc;
  assign ex_i_o = instr_i[15:1];

  always @(posedge clk or negedge areset)
    if (~areset) begin
      pc <= '0;
      save_pc <= '0;
      state <= IDLE;
      ivalid_o <= '0; 
      ex_v_o <= '0; 
    end

    else case (state)
      IDLE: begin
        pc <= st_a_i;
        ivalid_o <= '0; 
        if (v_i) begin
          ivalid_o <= '1;
          state <= INSTRUCTION_REQUEST;
        end
      end

      INSTRUCTION_REQUEST: begin 
        ivalid_o <= '0;
        state <= INSTRUCTION_FETCH;
      end

      INSTRUCTION_FETCH: begin    
        state <= INSTRUCTION_DECODE;
      end
 
      INSTRUCTION_DECODE: begin
        if (instr_i[0]) begin
          if (instr_i[1]) state <= IDLE;
          else begin

              if (instr_i[2]) begin
                if (instr_i[3]) begin
                  pc <= instr_i[15:4]; 
                  ivalid_o <= '1;
                  state <= INSTRUCTION_REQUEST;
                end
                else begin
                  if (ex_c_i) begin
                    pc <= instr_i[15:4]; 
                    ivalid_o <= '1;
                    state <= INSTRUCTION_REQUEST;
                  end
                  else begin 
                    pc <= pc + 1;
                    ivalid_o <= '1;
                    state <= INSTRUCTION_REQUEST;
                  end
                end
              end
              else begin
                pc <= pc + 1;
                ivalid_o <= '1;
                state <= INSTRUCTION_REQUEST;
              end 
            end

        end

        else begin
          ex_v_o <= '1;
          state <= INSTRUCTION_EXECUTE; 
        end 
      end

      INSTRUCTION_EXECUTE: begin
        ex_v_o <= '0;      
        state <= WAIT_EXECUTE_RESULT;
      end

      WAIT_EXECUTE_RESULT: begin
        if (ex_r_i) begin
          pc <= pc + 1;
          ivalid_o <= '1;
          state <= INSTRUCTION_REQUEST;
        end
      end

    endcase

  assign ready = state == IDLE;

endmodule


