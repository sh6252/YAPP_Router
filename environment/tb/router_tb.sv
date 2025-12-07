class router_tb extends uvm_env;

function new(string name,uvm_component parent);
    super.new(name,parent);
endfunction


yapp_env yapp;

channel_env channel_0;
channel_env channel_1;
channel_env channel_2;

hbus_env hbus;

clock_and_reset_env clock_and_reset;

router_mcsequencer mcseqr;

//router_scoreboard scoreboard;
router_module_env router_module;

yapp_router_regs_vendor_Cadence_Design_Systems_library_Yapp_Registers_version_1_5 yapp_rm;
hbus_reg_adapter reg2hbus;

`uvm_component_utils_begin(router_tb)
    `uvm_field_object(yapp_rm,UVM_ALL_ON);
`uvm_component_utils_end

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    yapp=yapp_env::type_id::create("yapp",this);

    channel_0=channel_env::type_id::create("channel_0",this);
    channel_1=channel_env::type_id::create("channel_1",this);
    channel_2=channel_env::type_id::create("channel_2",this);

    uvm_config_int::set(this,"channel_0.*","channel_id",0);
    uvm_config_int::set(this,"channel_1.*","channel_id",1);
    uvm_config_int::set(this,"channel_2.*","channel_id",2);

    hbus=hbus_env::type_id::create("hbus",this);

    uvm_config_int::set(this,"hbus","num_masters",1);
    uvm_config_int::set(this,"hbus","num_slaves",0);    

    clock_and_reset=clock_and_reset_env::type_id::create("clock_and_reset",this);

    mcseqr = router_mcsequencer::type_id::create("mcseqr", this); 

    //scoreboard=router_scoreboard::type_id::create("scoreboard",this);
    router_module=router_module_env::type_id::create("router_module",this);

      yapp_rm=yapp_router_regs_vendor_Cadence_Design_Systems_library_Yapp_Registers_version_1_5::type_id::create("yapp_rm",this);
    yapp_rm.build();
    yapp_rm.lock_model();
    yapp_rm.set_hdl_path_root("hw_top.dut");
    yapp_rm.default_map.set_auto_predict(1);

    reg2hbus=hbus_reg_adapter::type_id::create("reg2hbus",this);
endfunction

virtual function void connect_phase(uvm_phase phase);
    mcseqr.hbus_seqr = hbus.masters[0].sequencer;  // חיבור לה-bus sequencer
    mcseqr.yapp_seqr = yapp.agent.sequencer;    // חיבור ל-yapp sequencer
    yapp.agent.monitor.collect_packet_port.connect(router_module.reference.yapp_in);
    channel_0.rx_agent.monitor.item_collected_port.connect(router_module.scoreboard.chan0_in);
    channel_1.rx_agent.monitor.item_collected_port.connect(router_module.scoreboard.chan1_in);
    channel_2.rx_agent.monitor.item_collected_port.connect(router_module.scoreboard.chan2_in);
    hbus.masters[0].monitor.item_collected_port.connect(router_module.reference.hbus_in);
//with analysis_export and tlm_analysis_fifo
// yapp.agent.monitor.collect_packet_port.connect(router_module.yapp_in);
//     channel_0.rx_agent.monitor.item_collected_port.connect(router_module.sb_chan0);
//     channel_1.rx_agent.monitor.item_collected_port.connect(router_module.sb_chan1);
//     channel_2.rx_agent.monitor.item_collected_port.connect(router_module.sb_chan2);
//     hbus.masters[0].monitor.item_collected_port.connect(router_module.hbus_in);

    yapp_rm.default_map.set_sequencer(hbus.masters[0].sequencer, reg2hbus);


endfunction

endclass