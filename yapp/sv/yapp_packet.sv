/*-----------------------------------------------------------------
File name     : yapp_packet.sv
Description   : lab01_data YAPP UVC packet template file
Notes         : From the Cadence "SystemVerilog Advanced Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/

// Define your enumerated type(s) here
typedef enum bit {BAD_PARITY, GOOD_PARITY} parity_t;

class yapp_packet extends uvm_sequence_item;

function new(string name="yapp_packet");
      super.new(name);
endfunction

// Place the packet declarations in the following order:

  // Define protocol data

rand bit [1:0] addr;
rand bit [5:0] length;
rand bit [7:0] payload[];
     bit [7:0] parity;

  // Define control knobs

rand parity_t parity_type;
rand int packet_delay;
  // Enable automation of the packet's fields

`uvm_object_utils_begin(yapp_packet)
  `uvm_field_int(addr,UVM_ALL_ON);
  `uvm_field_int(length,UVM_ALL_ON);
  `uvm_field_int(parity,UVM_ALL_ON);
  `uvm_field_array_int(payload,UVM_ALL_ON);
  `uvm_field_enum(parity_t,parity_type,UVM_ALL_ON);
  `uvm_field_int(packet_delay,UVM_ALL_ON);
`uvm_object_utils_end

  // Define packet constraints
//constraint valid_addr {addr >=0; addr<3;}
constraint len_eq_payload_size {length==payload.size();}
//constraint good_parity_c {
  //parity_type dist { GOOD_PARITY := 5, BAD_PARITY := 1 };
//}  
constraint delay_len {packet_delay >1 ; packet_delay<20;}

// Add methods for parity calculation and class construction

function bit [7:0] calc_parity();
    bit [7:0] parity_calc;
    parity_calc ^= {addr,length};

    foreach (payload[i]) begin
        parity_calc ^= payload[i];
    end

    return parity_calc;
endfunction

function void set_parity();
parity =calc_parity();
if(parity_type == BAD_PARITY)
      parity = ~parity;
endfunction

function void post_randomize();
    set_parity();
endfunction

endclass: yapp_packet


class short_yapp_packet extends yapp_packet;

`uvm_object_utils(short_yapp_packet)

function new(string name="short_yapp_packet");
      super.new(name);
endfunction

constraint short_packet {length<15;}
//constraint addr_no_2 {addr!=2;}


endclass
