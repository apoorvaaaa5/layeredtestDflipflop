interface intf(input bit clk,reset,preset);
  bit d;
  bit q;
  clocking cb@(posedge clk);
    
    output d;
    input q;
  endclocking
  
  clocking monitor_cb@(posedge clk);
    
    input d;
    input q;
    
  endclocking
  
  
  modport DRIVER  (clocking cb,input clk,reset,preset);
    modport MONITOR (clocking monitor_cb,input clk,reset,preset);
  
 
endinterface
