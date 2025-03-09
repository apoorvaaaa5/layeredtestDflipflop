# Layered Testbench for D Flip-Flop

## Overview
This repository contains a **layered testbench** for verifying a **D Flip-Flop (DFF)** using **SystemVerilog**. The testbench follows a modular approach with components like **driver, monitor, generator, and scoreboard** to ensure a robust verification environment.

## What is a Layered Testbench?

A layered testbench in SystemVerilog is an organized way to verify a design under test (DUT) by dividing testbench functionality into separate components. This improves code reusability and debugging efficiency.

### Layers in the Testbench:

1. Interface: Connects signals between the DUT and testbench.

2. Driver: Generates stimulus (inputs) and drives them to the DUT.

3. Monitor: Captures the output responses from the DUT.

4. Scoreboard: Compares actual DUT output with expected results.

5. Generator: Creates different sets of input patterns.

6. Transaction: Defines the structure of test stimulus and expected outputs.

7. Environment: Connects all the components together.

8. Test: Defines the test scenario to be executed.

9. Testbench: Top-level module to instantiate all components.
   
## Design Under Test (DUT) - D Flip-Flop
The **D Flip-Flop is a sequential circuit** that stores the input data (D) on the rising edge of the clock (clk). The output (Q) follows D after the clock edge, with additional reset and preset functionality.
The **D Flip-Flop (DFF)** is implemented in `design.sv` as follows:

DUT Code (D Flip-Flop)

```systemverilog
module d_ff (
    input bit d, clk, reset, preset,
    output bit q
);
    always_ff @(posedge clk, posedge reset, posedge preset)
        if (reset)
            q <= 1'b0;
        else if (preset)
            q <= 1'b1;
        else if (reset && preset)
            q <= 1'b0;
        else
            q <= d;
endmodule
```
### Explanation of the Design:

- The module d_ff defines a D Flip-Flop with additional reset and preset functionalities.

- The always_ff block is triggered on the rising edge of clk, reset, or preset.

- If reset is high, the output q is set to 0.

- If preset is high, the output q is set to 1.

- If both reset and preset are high, q is set to 0 (reset has priority).

- Otherwise, q follows the input d on the next clock edge.

## Testbench Structure
The testbench follows a layered approach and consists of the following components:

### 1. **Interface (`interface.sv`)**
The interface connects the testbench and the DUT, defining the **signals** and **modports**.

```systemverilog
interface intf(input bit clk, reset, preset);
  bit d;
  bit q;

  clocking cb @(posedge clk);
    output d;
    input q;
  endclocking

  clocking monitor_cb @(posedge clk);
    input d;
    input q;
  endclocking

  modport DRIVER (clocking cb, input clk, reset, preset);
  modport MONITOR (clocking monitor_cb, input clk, reset, preset);
endinterface
```

#### **Explanation**:
- The **interface** bundles the signals `d`, `q`, `clk`, `reset`, and `preset`.
- **Clocking Blocks:**
  - `cb` (used by the **Driver**) controls input `d` and samples `q`.
  - `monitor_cb` (used by the **Monitor**) observes `d` and `q` without affecting them.
- **Modports:**
  - `DRIVER` → Used by the **Driver** to drive inputs (`d`).
  - `MONITOR` → Used by the **Monitor** to passively observe signals.
    
- The clocking cb block is used by the driver to control d and read q.

- The clocking monitor_cb block is used by the monitor to observe d and q.

- modport DRIVER allows the driver to drive inputs and observe outputs.

- modport MONITOR allows the monitor to observe signals.

### 2. **Mailbox in the Testbench**
**Mailboxes** provide a communication mechanism between different testbench components. They act as message-passing queues, enabling transaction-based verification.

#### **Usage of Mailboxes in the Testbench**:
- **Generator → Driver Communication:**
  - `generator` creates transactions and sends them via `gen2driv` mailbox.
  - `driver` retrieves transactions and applies them to the DUT.
- **Monitor → Scoreboard Communication:**
  - `monitor` observes DUT responses and sends transactions via `mon2scb` mailbox.
  - `scoreboard` retrieves transactions and checks correctness.

```systemverilog
mailbox gen2driv;
mailbox mon2scb;
```

### 3. **Transaction (`transaction.sv`)**
Defines the basic unit of communication between testbench components.

```systemverilog
class transaction;
  rand bit d;
  bit q;

  function void display(string name);
    $display("-------------------------");
    $display(" %s ", name);
    $display("-------------------------");
    $display("  d= %0d", d);
    $display(" q = %0d", q);
    $display("-------------------------");
  endfunction
endclass
```

### 4. **Generator (`generator.sv`)**
Generates randomized transactions and sends them to the driver.

```systemverilog
class generator;
  transaction trans;
  mailbox gen2driv;
  
  function new(mailbox gen2driv);
    this.gen2driv = gen2driv;
  endfunction

  task main();
    repeat(1) begin
      trans = new();
      trans.randomize();
      gen2driv.put(trans);
    end
  endtask
endclass
```

### 5. **Driver (`driver.sv`)**
Receives transactions and drives the DUT inputs.

```systemverilog
`define DRIV_IF vif.DRIVER.cb
class driver;
  virtual intf vif;
  mailbox gen2driv;
  transaction trans;
  covergroup cover1;
    coverpoint trans.d;
  endgroup

  function new(virtual intf vif, mailbox gen2driv);
    this.vif = vif;
    this.gen2driv = gen2driv;
    cover1 = new();
  endfunction

  task main;
    repeat(1) begin
      gen2driv.get(trans);
      @(posedge vif.DRIVER.clk);
      `DRIV_IF.d <= trans.d;
      trans.q = `DRIV_IF.q;
      cover1.sample();
      $display("Coverage: %0f", cover1.get_coverage());
    end
  endtask
endclass
```

### 6. **Monitor (`monitor.sv`)**
Observes DUT inputs/outputs and sends transactions to the scoreboard.

```systemverilog
`define MON_IF vif.MONITOR.monitor_cb
class monitor;
  virtual intf vif;
  mailbox mon2scb;
  transaction trans;

  function new(virtual intf vif, mailbox mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction  

  task main;
    repeat(1) #25 begin
      trans = new();      
      @(posedge vif.MONITOR.clk);
      trans.d = `MON_IF.d;
      trans.q = `MON_IF.q;
      mon2scb.put(trans);       
    end
  endtask
endclass
```

### 7. **Scoreboard (`scoreboard.sv`)**
Verifies correctness by comparing expected and actual outputs.

```systemverilog
class scoreboard;
  mailbox mon2scb;

  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction

  task main;
    transaction trans;
    repeat(1) begin
      mon2scb.get(trans);
      if (trans.d == trans.q)
        $display("Result is as Expected");
      else
        $error("Wrong Result, %0t", $time);
    end
  endtask
endclass
```

### 8. **Environment (`environment.sv`)**
Connects all components and handles simulation flow.

```systemverilog
class environment;
  generator gen;
  driver driv;
  monitor mon;
  scoreboard scb;
  mailbox m1, m2;
  virtual intf vif;

  function new(virtual intf vif);
    this.vif = vif;
    m1 = new();
    m2 = new();
    gen = new(m1);
    driv = new(vif, m1);
    mon = new(vif, m2);
    scb = new(m2);
  endfunction

  task run;
    fork 
      gen.main();
      driv.main();
      mon.main();
      scb.main();
    join
  endtask
endclass
```

## **Conclusion**
This testbench follows a structured **layered verification methodology**, ensuring modularity, reusability, and efficient debugging. 🚀

