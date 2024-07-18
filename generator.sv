class generator;
  
  transaction trans; //Handle of Transaction class
  
  
  mailbox gen2driv;  
  //Mailbox declaration
  
  
    
  function new(mailbox gen2driv); 
    //creation of mailbox and constructor
    this.gen2driv = gen2driv;
  endfunction
  
  
task main();
    
    repeat(1)
      begin
        
    	trans = new();
        trans.randomize(); 
        //trans.display("Generator");
        gen2driv.put(trans);
        
      end
    
  
  endtask
  
endclass
