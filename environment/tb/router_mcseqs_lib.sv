class router_simple_mcseq extends uvm_sequence;

    `uvm_object_utils(router_simple_mcseq)
    `uvm_declare_p_sequencer(router_mcsequencer)
    
    hbus_small_packet_seq h_small;  // Handle לרצף HBUS
    hbus_read_max_pkt_seq h_read_max;
    hbus_set_default_regs_seq h_dflt_reg;
    yapp_012_seq y_012;
    six_yapp_seq y_six_rnd;

    function new(string name="router_simple_mcseq");
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

    task body();
        `uvm_do_on(h_small,p_sequencer.hbus_seqr)
        `uvm_do_on(h_read_max,p_sequencer.hbus_seqr)
        `uvm_do_on(y_012,p_sequencer.yapp_seqr)
        `uvm_do_on(y_012,p_sequencer.yapp_seqr)
        `uvm_do_on(h_dflt_reg,p_sequencer.hbus_seqr)
        `uvm_do_on(h_read_max,p_sequencer.hbus_seqr)
        `uvm_do_on(y_six_rnd,p_sequencer.yapp_seqr)
    endtask

endclass