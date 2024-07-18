`include "interface.sv"
`include "test"
module tbench_top;
  bit clk;
  bit reset;
  bit preset;
  
  always #5 clk = ~clk;
  initial begin
   reset =1'b1;
 #10 reset =1'b0; preset=1'b1;
 #10 reset=1'b0; preset=1'b0;
  end
  
  intf i_intf(clk,reset,preset);
  
  test t1(i_intf);
  
  d_ff d1(
    .d(i_intf.d),
    .clk(i_intf.clk),
  .reset(i_intf.reset), 
    .preset(i_intf.preset), 
  .q(i_intf.q)
    );
  
  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
  end
endmodule
