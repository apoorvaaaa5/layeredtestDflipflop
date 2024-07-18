class transaction;
  rand bit d;
  bit q;
  
  function void display(string name);
    $display("-------------------------");
    $display(" %s ",name);
    $display("-------------------------");
    $display("  d= %0d",d);
    $display(" q = %0d",q);
    $display("-------------------------");
  endfunction
endclass
