/*-----------------------------------------------------------------
File name     : yapp_tx_seqs.sv
Developers    : Kathleen Meade, Brian Dickinson
Created       : 01/04/11
Description   : YAPP UVC simple TX test sequence for labs 2 to 4
Notes         : From the Cadence "SystemVerilog Advanced Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// SEQUENCE: base yapp sequence - base sequence with objections from which 
// all sequences can be derived
//
//------------------------------------------------------------------------------
class yapp_base_seq extends uvm_sequence #(yapp_packet);
  
  // Required macro for sequences automation
  `uvm_object_utils(yapp_base_seq)

  // Constructor
  function new(string name="yapp_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

endclass : yapp_base_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: yapp_5_packets
//
//  Configuration setting for this sequence
//    - update <path> to be hierarchial path to sequencer 
//
//  uvm_config_wrapper::set(this, "<path>.run_phase",
//                                 "default_sequence",
//                                 yapp_5_packets::get_type());
//
//------------------------------------------------------------------------------
class yapp_5_packets extends yapp_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(yapp_5_packets)

  // Constructor
  function new(string name="yapp_5_packets");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_5_packets sequence", UVM_LOW)
     repeat(5)
      `uvm_do(req)
  endtask
  
endclass : yapp_5_packets

class yapp_1_seq extends yapp_base_seq;

`uvm_object_utils(yapp_1_seq)

function new(string name="yapp_1_seq");
super.new(name);
endfunction

virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_1_seq sequence", UVM_LOW)
    `uvm_do_with(req, {addr==1;})
endtask

endclass

class yapp_012_seq extends yapp_base_seq;

`uvm_object_utils(yapp_012_seq)

function new(string name="yapp_012_seq");
super.new(name);
endfunction

virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_012_seq sequence", UVM_LOW)
    `uvm_do_with(req, {addr==0;})
    `uvm_do_with(req, {addr==1;})
    `uvm_do_with(req, {addr==2;})

endtask

endclass

class yapp_111_seq extends yapp_base_seq;

`uvm_object_utils(yapp_111_seq)

function new(string name="yapp_111_seq");
super.new(name);
endfunction

yapp_1_seq y_1_s;

virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_111_seq sequence", UVM_LOW)
     repeat(3) `uvm_do(y_1_s)
endtask

endclass

class yapp_repeat_addr_seq extends yapp_base_seq;

`uvm_object_utils(yapp_repeat_addr_seq)

function new(string name="yapp_repeat_addr_seq");
super.new(name);
endfunction

//rand bit [1:0] address;
int prev_addr;
//constraint c1 {address!=3;}


virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_repeat_addr_seq sequence", UVM_LOW)
     //ok=address.randomize();
     `uvm_do(req)
prev_addr=req.addr;

      `uvm_do_with(req, {addr==prev_addr;}) 
endtask

endclass

class yapp_incr_payload_seq extends yapp_base_seq;

`uvm_object_utils(yapp_incr_payload_seq)

function new(string name="yapp_incr_payload_seq");
super.new(name);
endfunction

int ok,data;
virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_incr_payload_seq sequence", UVM_LOW)
    
    `uvm_create(req)

    ok= req.randomize();
    data=0;   
    repeat(req.length) begin 
	req.payload[data]=data;
	data=data+1;
end

req.set_parity();

`uvm_send(req);
endtask

endclass

class yapp_rnd_seq extends yapp_base_seq;

`uvm_object_utils(yapp_rnd_seq)

function new(string name="yapp_rnd_seq");
super.new(name);
endfunction

rand int count;
constraint limit_count {count>0; count<=10;}

virtual task body();
    `uvm_info(get_type_name(), $sformatf("Executing yapp_rnd_seq sequence the count is: %d ",count), UVM_LOW)

    repeat (count)
         `uvm_do(req)    
endtask

endclass

class six_yapp_seq extends yapp_base_seq;

`uvm_object_utils(six_yapp_seq)

function new(string name="six_yapp_seq");
super.new(name);
endfunction

yapp_rnd_seq yrs;

virtual task body();
    `uvm_info(get_type_name(),"Executing six_yapp_seq sequence", UVM_LOW)
     `uvm_do_with(yrs,{count==6;})    
endtask

endclass


class yapp_exhaustive_seq extends yapp_base_seq;

`uvm_object_utils(yapp_exhaustive_seq)

function new(string name="yapp_exhaustive_seq");
super.new(name);
endfunction

int ok;
yapp_1_seq y_1_s;
yapp_012_seq y_012_s;
yapp_111_seq y_111_s;
yapp_repeat_addr_seq repeat_addr;
yapp_incr_payload_seq inc_payload;
six_yapp_seq six_count;



virtual task body();
`uvm_do(y_1_s)
`uvm_do(y_012_s)
`uvm_do(y_111_s)
`uvm_do(repeat_addr)
`uvm_do(inc_payload)
`uvm_create(six_count)
ok=six_count.randomize();
`uvm_do(six_count)

endtask


endclass


class yapp_long_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_long_seq)

  function new(string name = "yapp_long_seq");
    super.new(name);
  endfunction

  int address = 0, payload_size = 1;

  virtual task body();
    `uvm_create(req)
    req.packet_delay=1;
    for(int ad=0;ad<4;ad++)begin
      req.addr=ad;
      for(int ln=1;ln<23;ln++)begin
        req.length=ln;
        req.payload=new[ln];
        for(int pld=0;pld<ln;pld++)
          req.payload[pld]=pld;
        randcase
          20:req.parity_type=BAD_PARITY;
          80:req.parity_type=GOOD_PARITY;
        endcase
        req.set_parity();
        `uvm_send(req)
      end
    end
    `uvm_info(get_type_name(), "Completed sequence", UVM_LOW)
  endtask
endclass