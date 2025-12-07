class base_test extends uvm_test;

`uvm_component_utils(base_test)

function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction

router_tb tb;

virtual function void build_phase(uvm_phase phase);
    uvm_config_int::set( this, "*", "recording_detail", 1);
    super.build_phase(phase);
    tb=router_tb::type_id::create("tb",this);
    //uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase",
      //                       "default_sequence",
        //                   yapp_5_packets::get_type());
    `uvm_info("BUILD_PHASE","build phase of the test is being executed",UVM_HIGH);
endfunction

function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
endfunction

function void check_phase(uvm_phase phase);
    check_config_usage();
endfunction

task run_phase(uvm_phase phase);
uvm_objection obj = phase.get_objection();
obj.set_drain_time(this,200ns);

endtask

endclass : base_test


//class test2 extends base_test;
//
//`uvm_component_utils(test2)
//
//function new(string name,uvm_component parent);
//    super.new(name,parent);
//endfunction
//virtual function void build_phase(uvm_phase phase);
//    super.build_phase(phase);
//    `uvm_info("BUILD_PHASE","build phase of the test2 is being executed",UVM_HIGH);
//endfunction
//endclass
//
//
//class short_packet_test extends base_test;
//
//    `uvm_component_utils(short_packet_test)
//
//    function new(string name,uvm_component parent);
//        super.new(name,parent);
//    endfunction
//
//    function void build_phase(uvm_phase phase);
//       set_type_override_by_type(yapp_packet::get_type(),short_yapp_packet::get_type());
//        super.build_phase(phase);
//    endfunction
//
//
//endclass
//
//
//class set_config_test extends base_test;
//
//    `uvm_component_utils(set_config_test)
//
//    function new(string name,uvm_component parent);
//        super.new(name,parent);
//    endfunction
//
//    function void build_phase(uvm_phase phase);
//        uvm_config_int::set(this,"tb.yapp.agent","is_active",UVM_PASSIVE);
//        super.build_phase(phase);
//    endfunction
//
//endclass
//
//class incr_payload_test extends base_test;
//
//`uvm_component_utils(incr_payload_test)
//
//function new(string name="incr_payload_test",uvm_component parent);
//super.new(name,parent);
//endfunction
//
//function void build_phase(uvm_phase phase);
// set_type_override_by_type(yapp_packet::get_type(),short_yapp_packet::get_type());
//super.build_phase(phase);
// uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase",
//                                "default_sequence",
//                                yapp_incr_payload_seq::get_type());
//endfunction
//
//endclass
//
//class exhaustive_seq_test extends base_test;
//
//`uvm_component_utils(exhaustive_seq_test)
//
//function new(string name="exhaustive_seq_test",uvm_component parent);
//super.new(name,parent);
//endfunction
//
//function void build_phase(uvm_phase phase);
// set_type_override_by_type(yapp_packet::get_type(),short_yapp_packet::get_type());
//super.build_phase(phase);
// uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase",
//                                "default_sequence",
//                                yapp_exhaustive_seq::get_type());
//endfunction
//
//endclass
//
//class yapp_012_test extends base_test;
//
//`uvm_component_utils(yapp_012_test)
//
//function new(string name="yapp_012_test",uvm_component parent);
//super.new(name,parent);
//endfunction
//
//function void build_phase(uvm_phase phase);
// set_type_override_by_type(yapp_packet::get_type(),short_yapp_packet::get_type());
//super.build_phase(phase);
// uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase",
//                                "default_sequence",
//                                yapp_012_seq::get_type());
//endfunction
//
//endclass

class simple_test extends base_test;

`uvm_component_utils(simple_test)

function new(string name="simple_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
// set_type_override_by_type(yapp_packet::get_type(),short_yapp_packet::get_type());

uvm_config_wrapper::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                                "default_sequence",
                                clk10_rst5_seq::get_type());

 uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase",
                                "default_sequence",
                                yapp_exhaustive_seq::get_type());
uvm_config_wrapper::set(this, "tb.channel_?.rx_agent.sequencer.run_phase",
                                "default_sequence",
                                channel_rx_resp_seq::get_type());
    
uvm_config_wrapper::set(this, "tb.hbus.masters[0].sequencer.run_phase",
                                "default_sequence",
                                hbus_small_packet_seq::get_type());
super.build_phase(phase);

endfunction

endclass

class mcseqr_test extends base_test;
    `uvm_component_utils(mcseqr_test)

    function new(string name="mcseqr_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);

        //set_type_override_by_type(yapp_packet::get_type(),short_yapp_packet::get_type());
        super.build_phase(phase);

        uvm_config_wrapper::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                                "default_sequence",
                                clk10_rst5_seq::get_type());
        uvm_config_wrapper::set(this, "tb.channel_?.rx_agent.sequencer.run_phase",
                                "default_sequence",
                                channel_rx_resp_seq::get_type());
        uvm_config_wrapper::set(this, "tb.mcseqr.run_phase",
                                "default_sequence",
                                router_simple_mcseq::get_type());
    
      
    endfunction

endclass

class  uvm_reset_test extends base_test;

    uvm_reg_hw_reset_seq reset_seq;

  // component macro
  `uvm_component_utils(uvm_reset_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
      reset_seq = uvm_reg_hw_reset_seq::type_id::create("uvm_reset_seq");
      super.build_phase(phase);
  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
     phase.raise_objection(this, "Raising Objection to run uvm built in reset test");
     // Set the model property of the sequence to our Register Model instance
     // Update the RHS of this assignment to match your instance names. Syntax is:
     //  <testbench instance>.<register model instance>
     uvm_config_wrapper::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                                "default_sequence",
                                clk10_rst5_seq::get_type());
     reset_seq.model = tb.yapp_rm;
     // Execute the sequence (sequencer is already set in the testbench)
     reset_seq.start(null);
     phase.drop_objection(this," Dropping Objection to uvm built reset test finished");
     
     
  endtask

endclass : uvm_reset_test

class  reg_access_test extends base_test;

yapp_regs_c yapp_regs;

  // component macro
  `uvm_component_utils(reg_access_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void  connect_phase(uvm_phase phase);
    yapp_regs= tb.yapp_rm.router_yapp_regs;
  endfunction

  function void build_phase(uvm_phase phase);
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
      super.build_phase(phase);
  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
     uvm_status_e status;
     bit [7:0] rdata=0;
     phase.raise_objection(this, "Raising Objection to run uvm built in reset test");
     uvm_config_wrapper::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                                "default_sequence",
                                clk10_rst5_seq::get_type());
    yapp_regs.ctrl_reg.write(status, 6'h14);
    yapp_regs.ctrl_reg.peek(status,rdata);
    `uvm_info("PEEK CTRL REG",$sformatf("the write data: 'h14 and the read data: %h",rdata),UVM_LOW)
    yapp_regs.ctrl_reg.poke(status,6'h20);
    yapp_regs.ctrl_reg.read(status,rdata);
    `uvm_info("READ CTRL REG",$sformatf("the write data: 'h20 and the read data: %h",rdata),UVM_LOW)
    
    yapp_regs.addr0_cnt_reg.poke(status,8'h20);
    yapp_regs.addr0_cnt_reg.read(status,rdata);
    `uvm_info("READ ADDR0_CNT REG",$sformatf("the write data: 'h20 and the read data: %h",rdata),UVM_LOW)
    yapp_regs.addr0_cnt_reg.write(status, 6'h14);
    yapp_regs.addr0_cnt_reg.peek(status,rdata);
    `uvm_info("PEEK ADDR0_CNT REG",$sformatf("the write data: 'h14 and the read data: %h",rdata),UVM_LOW)

    phase.drop_objection(this," Dropping Objection to uvm built reset test finished");
     
     
  endtask

endclass : reg_access_test

class  reg_function_test extends base_test;

yapp_tx_sequencer yp_sqcr;
yapp_012_seq y012seq;
yapp_regs_c yapp_regs;

  // component macro
  `uvm_component_utils(reg_function_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void  connect_phase(uvm_phase phase);
    yp_sqcr=tb.yapp.agent.sequencer;
    yapp_regs= tb.yapp_rm.router_yapp_regs;
  endfunction

  function void build_phase(uvm_phase phase);
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
      super.build_phase(phase);
      y012seq=yapp_012_seq::type_id::create("y012seq");
      uvm_config_wrapper::set(this, "tb.channel_?.rx_agent.sequencer.run_phase",
                                "default_sequence",
                                channel_rx_resp_seq::get_type());
  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
     uvm_status_e status;
     bit [7:0] rdata=0;
     tb.yapp_rm.default_map.set_check_on_read(1);
     phase.raise_objection(this, "Raising Objection to run uvm built in reset test");
     uvm_config_wrapper::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                                "default_sequence",
                                clk10_rst5_seq::get_type());
    yapp_regs.en_reg.set('b1);
    rdata=yapp_regs.en_reg.get();
    `uvm_info("READ EN_REG",$sformatf("the read data: %h",rdata),UVM_LOW)
    y012seq.start(yp_sqcr);
    yapp_regs.addr0_cnt_reg.read(status,rdata);
    `uvm_info("READ ADDR0_CNT REG",$sformatf("the read data: %h",rdata),UVM_LOW)
    yapp_regs.addr1_cnt_reg.read(status,rdata);
    `uvm_info("READ ADDR1_CNT REG",$sformatf("the read data: %h",rdata),UVM_LOW)
    yapp_regs.addr2_cnt_reg.read(status,rdata);
    `uvm_info("READ ADDR2_CNT REG",$sformatf("the read data: %h",rdata),UVM_LOW)
    yapp_regs.addr3_cnt_reg.read(status,rdata);
    `uvm_info("READ ADDR3_CNT REG",$sformatf("the read data: %h",rdata),UVM_LOW)

   yapp_regs.en_reg.write(status, 8'hff);
yapp_regs.en_reg.read(status, rdata);
    `uvm_info("READ EN_REG",$sformatf("the read data: %h",rdata),UVM_LOW)
    y012seq.start(yp_sqcr);
    yapp_regs.addr0_cnt_reg.read(status,rdata);
    `uvm_info("READ ADDR0_CNT REG",$sformatf("the read data: %h",rdata),UVM_LOW)
    yapp_regs.addr1_cnt_reg.read(status,rdata);
    `uvm_info("READ ADDR1_CNT REG",$sformatf("the read data: %h",rdata),UVM_LOW)
    yapp_regs.addr2_cnt_reg.read(status,rdata);
    `uvm_info("READ ADDR2_CNT REG",$sformatf("the read data: %h",rdata),UVM_LOW)
    yapp_regs.addr3_cnt_reg.read(status,rdata);
    `uvm_info("READ ADDR3_CNT REG",$sformatf("the read data: %h",rdata),UVM_LOW)
    yapp_regs.oversized_pkt_cnt_reg.read(status,rdata);
    `uvm_info("READ oversized_pkt_cnt_reg",$sformatf("the read data: %h",rdata),UVM_LOW)
    yapp_regs.parity_err_cnt_reg.read(status,rdata);
    `uvm_info("READ parity_err_cnt_reg",$sformatf("the read data: %h",rdata),UVM_LOW)
    


    phase.drop_objection(this," Dropping Objection to uvm built reset test finished");
     
     
  endtask

endclass : reg_function_test






