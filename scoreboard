class scoreboard;
  
  mailbox mon2scb;
  //transaction trans;
  
  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction
  
  task main;
    transaction trans;
    
    repeat(1)
      begin
      mon2scb.get(trans);
        
        if(trans.d ==1'b1 && trans.q==1'b1)
          $display("Result is as Expected");
        else if(trans.d == 1'b0 && trans.q==1'b0)
          $display("Result is as Expected");
        else
          $error("Wrong Result, %0t",$time);
           
         trans.display("Scoreboard");
    end
  endtask
  
endclass
