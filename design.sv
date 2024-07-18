module d_ff(input bit d,clk,reset,preset, output bit q);
  always_ff@(posedge clk,posedge reset,posedge preset)
    if(reset) q<=1'b0;
  else if(preset) q<=1'b1;
  else if(reset && preset) q<=1'b0;
  	else q<=d;
endmodule
