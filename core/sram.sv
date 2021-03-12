
module sram #(
  parameter TYPE = "GENERIC_LATCH",
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 8)
(
  input  logic                   clk,
  input  logic  [ADDR_WIDTH-1:0] ad_i,
  input  logic  [DATA_WIDTH-1:0] d_i,
  output logic  [DATA_WIDTH-1:0] d_o,
  input  logic                   we_i,
  input  logic                   cs_i);

  generate 

    if (TYPE == "GENERIC") begin
      logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH];

      initial begin 
        for (int i = 0; i < 2**ADDR_WIDTH; i++) 
        mem[i] = '0; 
      end

      logic  [ADDR_WIDTH-1:0] addr_reg;
      always @ (posedge clk) begin
        addr_reg <= ad_i;
        if (we_i) mem[ad_i] <= d_i;
      end
      assign d_o = mem[addr_reg];

    end

    if (TYPE == "GENERIC_LATCH") begin
      logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH];
      always_latch
        if (cs_i &  we_i) mem[ad_i] <= d_i;
      assign d_o = mem[ad_i];  
    end


    if (TYPE == "INTEL_RECOMENDATIONS" | 
        TYPE == "ALTERA" ) begin
      logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH];
      logic  [ADDR_WIDTH-1:0] addr_reg;
      always @ (posedge clk) begin
        addr_reg <= ad_i;
        if (we_i) mem[ad_i] <= d_i;
      end
      assign d_o = mem[addr_reg];
    end


    if ( TYPE == "ALTERA_INVERT" ) begin
      logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH];
      logic  [ADDR_WIDTH-1:0] addr_reg;

      logic clk_inv;
      assign clk_inv = ~clk;
  
      always @ (posedge clk_inv) begin
        addr_reg <= ad_i;
        if (we_i) mem[ad_i] <= d_i;
      end
      assign d_o = mem[addr_reg];
    end


    
    if (TYPE == "MICRON_SPS2HD_4096x8m16d4_R0_M4") begin


      SPS2HD_4096x8m16d4_R0_M4_ns mem (
        .Q(d_o),  
        .CK(clk), 
        .CSN(~cs_i), 
        .WEN(~we_i), 
        .OEN('0), 
        .A(ad_i), 
        .D(d_i));  

    end


    if (TYPE == "MICRON_SPS2HD_4096x39m8d4_R0_M4") begin


      SPS2HD_4096x39m8d4_R0_M4_ns mem (
        .Q(d_o),  
        .CK(clk), 
        .CSN(~cs_i), 
        .WEN(~we_i), 
        .OEN('0), 
        .A(ad_i), 
        .D(d_i));  

    end


    if (TYPE == "MICRON_SPS2HD_1024x8m8d4_R0_M4") begin


      SPS2HD_1024x8m8d4_R0_M4_ns mem (
        .Q(d_o),  
        .CK(clk), 
        .CSN(~cs_i), 
        .WEN(~we_i), 
        .OEN('0), 
        .A(ad_i), 
        .D(d_i));  

    end


    if (TYPE == "MICRON_SPS_1024x32m4") begin

      SPS_1024x32m4 mem (
        .Q(d_o),  
        .CK(clk), 
        .CSN(~cs_i), 
        .WEN(~we_i), 
        .OEN('0), 
        .A(ad_i), 
        .D(d_i));

    end   


  endgenerate





endmodule



