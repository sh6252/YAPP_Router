class yapp_tx_monitor extends uvm_monitor;
   `uvm_component_utils(yapp_tx_monitor)

    virtual interface yapp_if vif;
    uvm_analysis_port #(yapp_packet) collect_packet_port;

  yapp_packet pkt;
  int num_pkt_col;

covergroup yapp_cg;
  option.per_instance = 1;
  REQ1_length: coverpoint pkt.length{
    bins MIN={1};
    bins MAX={63};
    bins SHORT= {[2:10]};
    bins MEDIUM = {[11:40]};
    bins LONG = {[41:62]};
  }
  REQ2_addr : coverpoint pkt.addr{
    bins addr_0={0};
    bins addr_1={1};
    bins addr_2={2};
    bins addr_3={3};
  }
  REQ3_len_addr_cross : cross REQ1_length, REQ2_addr iff(pkt.parity_type == BAD_PARITY){
    bins short_addr0 = binsof(REQ1_length.SHORT)&&binsof(REQ2_addr.addr_0);
    bins short_addr1 = binsof(REQ1_length.SHORT)&&binsof(REQ2_addr.addr_1);
    bins short_addr2 = binsof(REQ1_length.SHORT)&&binsof(REQ2_addr.addr_2);
    bins short_addr3 = binsof(REQ1_length.SHORT)&&binsof(REQ2_addr.addr_3);
    bins medium_addr0 = binsof(REQ1_length.MEDIUM)&&binsof(REQ2_addr.addr_0);
    bins medium_addr1 = binsof(REQ1_length.MEDIUM)&&binsof(REQ2_addr.addr_1);
    bins medium_addr2 = binsof(REQ1_length.MEDIUM)&&binsof(REQ2_addr.addr_2);
    bins medium_addr3 = binsof(REQ1_length.MEDIUM)&&binsof(REQ2_addr.addr_3);
    bins long_addr0 = binsof(REQ1_length.LONG)&&binsof(REQ2_addr.addr_0);
    bins long_addr1 = binsof(REQ1_length.LONG)&&binsof(REQ2_addr.addr_1);
    bins long_addr2 = binsof(REQ1_length.LONG)&&binsof(REQ2_addr.addr_2);
    bins long_addr3 = binsof(REQ1_length.LONG)&&binsof(REQ2_addr.addr_3);
  }
endgroup :yapp_cg


    function new(string name,uvm_component parent);
        super.new(name,parent);
        collect_packet_port=new("collect_packet_port",this);
        yapp_cg=new();
    endfunction




 task run_phase(uvm_phase phase);
    // Look for packets after reset
    @(posedge vif.reset)
    @(negedge vif.reset)
    `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)
    forever begin 
      // Create collected packet instance
      pkt = yapp_packet::type_id::create("pkt", this);

      // concurrent blocks for packet collection and transaction recording
      fork
        // collect packet
        vif.collect_packet(pkt.length, pkt.addr, pkt.payload, pkt.parity);
        // trigger transaction at start of packet
        @(posedge vif.monstart) void'(begin_tr(pkt, "Monitor_YAPP_Packet"));
      join

      pkt.parity_type = (pkt.parity == pkt.calc_parity()) ? GOOD_PARITY : BAD_PARITY;
      // End transaction recording
      end_tr(pkt);
      yapp_cg.sample();

      `uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s", pkt.sprint()), UVM_LOW)
      collect_packet_port.write(pkt);
      num_pkt_col++;
    end
  endtask : run_phase

  function void connect_phase(uvm_phase phase);
	if(!yapp_vif_config::get(this,get_full_name(),"vif",vif))
		`uvm_error("NO_VIF","Missing Virtual I/F")
endfunction

 function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: YAPP Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
  endfunction : report_phase


endclass
