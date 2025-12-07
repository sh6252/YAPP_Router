class router_module_env extends uvm_env;
    `uvm_component_utils(router_module_env)

    router_reference reference;
    router_scoreboard scoreboard;

    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        reference=router_reference::type_id::create("reference",this);
        scoreboard=router_scoreboard::type_id::create("scoreboard",this);
    endfunction

    function void connect_phase(uvm_phase phase);
            reference.yapp_out.connect(scoreboard.yapp_in);
    endfunction


    //---------with analysis_export---------
    //  uvm_analysis_export #(yapp_packet) yapp_in;
    // uvm_analysis_export #(hbus_transaction) hbus_in;

    // uvm_analysis_export #(channel_packet) sb_chan0;
    // uvm_analysis_export #(channel_packet) sb_chan1;
    // uvm_analysis_export #(channel_packet) sb_chan2;

    // router_reference reference;
    // router_scoreboard scoreboard;

    // function new(string name,uvm_component parent);
    //     super.new(name,parent);
    //     yapp_in=new("yapp_in",this);
    //     hbus_in=new("hbus_in",this);
    //     sb_chan0=new("sb_chan0",this);  
    //     sb_chan1=new("sb_chan1",this);
    //     sb_chan2=new("sb_chan2",this);

    // endfunction

    // function void build_phase(uvm_phase phase);
    //     super.build_phase(phase);
    //     reference=router_reference::type_id::create("reference",this);
    //     scoreboard=router_scoreboard::type_id::create("scoreboard",this);
    // endfunction

    // function void connect_phase(uvm_phase phase);
    //         yapp_in.connect(reference.yapp_in);
    //         hbus_in.connect(reference.hbus_in);
    //         sb_chan0.connect(scoreboard.chan0_in);
    //         sb_chan1.connect(scoreboard.chan1_in);
    //         sb_chan2.connect(scoreboard.chan2_in);

    //         reference.yapp_out.connect(scoreboard.yapp_in);
    // endfunction

//with tlm_analysis_fifo
// function void connect_phase(uvm_phase phase);
//             yapp_in.connect(scoreboard.yapp_fifo.analysis_export);
//             hbus_in.connect(scoreboard.hbus_fifo.analysis_export);
//             sb_chan0.connect(scoreboard.chan0_fifo.analysis_export);
//             sb_chan1.connect(scoreboard.chan1_fifo.analysis_export);
//             sb_chan2.connect(scoreboard.chan2_fifo.analysis_export);

//             //reference.yapp_out.connect(scoreboard.yapp_fifo);
//     endfunction

endclass