
module svc_tb;

//-----------------------------------

  parameter DATA_SIZE  = 32;
  parameter ADDR_SIZE  = 32;

  parameter CORE_ROUND = 4;    // 1,2,4,... for hardware accelerated calculations 
  parameter BLOCK_SIZE = 256;  // 

//-----------------------------------

  parameter half_period = 1; 
  parameter period = 2*half_period;

  logic clk='0;
  always #(period) clk = ~clk; 

  logic areset='0;
  task clear_reset();
    #(33.3*period) areset = '1; 
    #(33.3*period);
  endtask

//-----------------------------------  
  

  logic [ADDR_SIZE-1:0] a_i = '0;  // address
  logic [DATA_SIZE-1:0] d_i = '0;  // data
  logic [DATA_SIZE-1:0] d_o;
  logic                 w_i = '0;  // write enable
  logic                 c_i = '0;  // chip  select
  logic [2:0]           s_i =  2;  // size: 0-byte, 1-halfwodr,2-word

  logic                 ready;     // core ready   
  
  `include "programm.sv" 

  logic [255:0] hash_data_a1, rand_data_a1;
  assign hash_data_a1 = 256'h2DFBC1B372D89A1188C09C52E0EEC61FCE52032AB1022E8E67ECE6672B043EE5;
  assign rand_data_a1 = 256'h77105C9B20BCD3122823C8CF6FCC7B956DE33814E95B7FE64FED924594DCEAB3;


//----------------------------------- 

  svarog #(DATA_SIZE,ADDR_SIZE,CORE_ROUND,BLOCK_SIZE)
  ecc (
    .areset(areset),
    .clk(clk),

    .a_i(a_i),
    .c_i(c_i),
    .w_i(w_i),
    .s_i(s_i),
    .d_i(d_i),
    .d_o(d_o),

    .hash_i(hash_data_a1),
    .rand_i(rand_data_a1),

    .rand_req_o(),
    .rand_ready_i('1),
 
    .irq_o(),  
    .ready(ready));

  logic enable_edge_count='0;
  logic [31:0] edge_count='0;

  always @(posedge clk)
    if (enable_edge_count) edge_count <= edge_count+1;


  initial begin

    clear_reset();
    //load_prg(); prg in rom imitator

    gost_a1_example();
 

  #(777*period) $finish; end


  logic [31:0] r [8];
  logic [31:0] s [8];

//----------------------------------- 
// basic bus operations

  task write_single_word (
    input logic [31:0] addr,
    input logic [31:0] data
  );
    @(posedge clk) #1
      s_i =  2;
      a_i = addr; d_i = data; 
      w_i = '1; c_i = '1;
    @(posedge clk) #1
      s_i =  2;
      a_i = '0; d_i = '0; 
      w_i = '0; c_i = '0;
  endtask


  task write_half_word (
    input logic [31:0] addr,
    input logic [31:0] data
  );
    @(posedge clk) #1
      s_i =  1;
      a_i = addr; d_i = data; 
      w_i = '1; c_i = '1;
    @(posedge clk) #1
      a_i = '0; d_i = '0; 
      w_i = '0; c_i = '0;
  endtask

  task read_single_word (
    input logic [31:0] addr,
    output logic [31:0] data
  );
    @(posedge clk) #1
      s_i =  2;
      a_i = addr;  
      w_i = '0; c_i = '1;
    @(posedge clk) #1
      a_i = '0; data = d_o;
      w_i = '0; c_i = '0;
  endtask


  task run_calc();
    s_i =  2;
    write_single_word(32'h000,32'h1);
  endtask


//----------------------------------- 
// programm loading

  task load_prg();
    s_i =  1;
    for (int i =0; i<PRG_SIZE;i++) 
      write_half_word(32'h700+2*i,instruction[i]);

  endtask


//----------------------------------- 

  task gost_a1_example();


    write_single_word(32'h100,32'h00000431);   // write field_reg_a
    write_single_word(32'h104,32'h00000000);   // curve field
    write_single_word(32'h108,32'h00000000);
    write_single_word(32'h10c,32'h00000000);
    write_single_word(32'h110,32'h00000000);   
    write_single_word(32'h114,32'h00000000);
    write_single_word(32'h118,32'h00000000);
    write_single_word(32'h11c,32'h80000000);


    write_single_word(32'h200,32'h3ACCF5B3);   // write field_reg_b
    write_single_word(32'h204,32'hC59CFC19);   // subgroup order
    write_single_word(32'h208,32'h92976154);
    write_single_word(32'h20c,32'h50FE8A18);
    write_single_word(32'h210,32'h00000001);   
    write_single_word(32'h214,32'h00000000);
    write_single_word(32'h218,32'h00000000);
    write_single_word(32'h21c,32'h80000000);


    write_single_word(32'h300,32'h91EC3B28);   // write core_reg_a
    write_single_word(32'h304,32'h1D19CE98);   // signature key
    write_single_word(32'h308,32'h49397EEE);
    write_single_word(32'h30c,32'h1B60961F);
    write_single_word(32'h310,32'hD39A72C1);   
    write_single_word(32'h314,32'h10ED359D);
    write_single_word(32'h318,32'h789BB9BE);
    write_single_word(32'h31c,32'h7A929ADE);



    write_single_word(32'h400,32'h00000007);   // write core_reg_b
    write_single_word(32'h404,32'h00000000);   // curve a
    write_single_word(32'h408,32'h00000000);
    write_single_word(32'h40c,32'h00000000);
    write_single_word(32'h410,32'h00000000);   
    write_single_word(32'h414,32'h00000000);
    write_single_word(32'h418,32'h00000000);
    write_single_word(32'h41c,32'h00000000);



    write_single_word(32'h500,32'h00000002);   // write core_reg_c
    write_single_word(32'h504,32'h00000000);   // point x-coordinate
    write_single_word(32'h508,32'h00000000);
    write_single_word(32'h50c,32'h00000000);
    write_single_word(32'h510,32'h00000000);   
    write_single_word(32'h514,32'h00000000);
    write_single_word(32'h518,32'h00000000);
    write_single_word(32'h51c,32'h00000000);


    write_single_word(32'h600,32'hEA7E8FC8);   // write core_reg_d
    write_single_word(32'h604,32'h2B96ABBC);   // point y-coordinate
    write_single_word(32'h608,32'h9CA26712);
    write_single_word(32'h60c,32'h85C97F0A);
    write_single_word(32'h610,32'h0E16D19C);   
    write_single_word(32'h614,32'hBD631603);
    write_single_word(32'h618,32'hE65147D4);
    write_single_word(32'h61c,32'h08E2A8A0);



    enable_edge_count = '1;

    run_calc();
    wait(ready);

    enable_edge_count = '0;



    for (int i=0; i<8;i++) read_single_word(32'h400+4*i,r[i]);
    for (int i=0; i<8;i++) read_single_word(32'h500+4*i,s[i]);  

    $display("r: %h", {r[7],r[6],r[5],r[4]});
    $display("   %h", {r[3],r[2],r[1],r[0]});

    $display("s: %h", {s[7],s[6],s[5],s[4]});
    $display("   %h", {s[3],s[2],s[1],s[0]});

    $display("\ncalculations have: %d tacts",edge_count);

  endtask

endmodule



