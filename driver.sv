`define DRIV_IF vif.DRIVER.cb
class driver;
  virtual intf vif;
  mailbox gen2driv;
  transaction trans;
  covergroup cover1;
    coverpoint trans.d;
  endgroup
  
  function new(virtual intf vif,mailbox gen2driv); 
    this.vif = vif;
    this.gen2driv = gen2driv;
    cover1=new();
  endfunction
  
 task main;
    
    repeat(1) 
      begin
       //transaction trans;
       gen2driv.get(trans);
        @(posedge vif.DRIVER.clk);
        begin
       `DRIV_IF.d <= trans.d;
        trans.q = `DRIV_IF.q;
          cover1.sample();
        end
        //trans.display("Driver");
        $display("coverage of covergroup = %0f", cover1.get_coverage());      
    end
  endtask 
endclass
