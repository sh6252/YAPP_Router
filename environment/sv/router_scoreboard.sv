class router_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(router_scoreboard)

    `uvm_analysis_imp_decl(_yapp)
    uvm_analysis_imp_yapp#(yapp_packet, router_scoreboard) yapp_in;

    `uvm_analysis_imp_decl(_chan0) 
    uvm_analysis_imp_chan0#(channel_packet, router_scoreboard) chan0_in;

    `uvm_analysis_imp_decl(_chan1) 
    uvm_analysis_imp_chan1#(channel_packet, router_scoreboard) chan1_in;

    `uvm_analysis_imp_decl(_chan2) 
    uvm_analysis_imp_chan2#(channel_packet, router_scoreboard) chan2_in;

    yapp_packet q_0[$];
    yapp_packet q_1[$];
    yapp_packet q_2[$];

    int packet_received_0=0,packet_received_1=0,packet_received_2=0;
    int packet_wrong_0=0,packet_wrong_1=0,packet_wrong_2=0;
    int packet_matched_0=0,packet_matched_1=0,packet_matched_2=0;
    int count_3=0;

    
    function new(string name,uvm_component parent);
        super.new(name,parent);
        yapp_in = new("yapp_in", this);
        chan0_in = new("chan0_in", this);
        chan1_in = new("chan1_in", this);
        chan2_in = new("chan2_in", this);

    endfunction

    function bit ccomp (yapp_packet yp, channel_packet cp, uvm_comparer comparer = null);
        if (comparer == null)
            comparer = new();
        ccomp = comparer.compare_field("addr", yp.addr, cp.addr, 2);
        ccomp &= comparer.compare_field("length", yp.length, cp.length, 6);
        foreach(yp.payload[i])
            ccomp &= comparer.compare_field($sformatf("payload[%d]",i),yp.payload[i],cp.payload[i],8);
        ccomp &= comparer.compare_field("parity",yp.parity,cp.parity,8);
    endfunction

    function void write_yapp(yapp_packet packet);
        yapp_packet ypkt;
        $cast( ypkt, packet.clone() );
        case (ypkt.addr)
            2'b00:q_0.push_back(ypkt);
            2'b01:q_1.push_back(ypkt);
            2'b10:q_2.push_back(ypkt);
            default:count_3++;
        endcase

    endfunction

function void write_chan0(input channel_packet cp);
    yapp_packet yp;
    packet_received_0++;
    if (q_0.size() > 0)
        yp = q_0.pop_back(); 
    else begin
        packet_wrong_0++;
        return;
    end
    if( ccomp(yp, cp) )
        packet_matched_0++;
    else
        packet_wrong_0++;
endfunction

function void write_chan1(input channel_packet cp);
    yapp_packet yp;
    packet_received_1++;
    if (q_1.size() > 0)
        yp = q_1.pop_back(); 
    else begin
        packet_wrong_1++;
        return;
    end
    if( ccomp(yp, cp) )
        packet_matched_1++;
    else
        packet_wrong_1++;
endfunction

function void write_chan2(input channel_packet cp);
    yapp_packet yp;
    packet_received_2++;

    if (q_2.size() > 0)
        yp = q_2.pop_back(); 
    else begin
        packet_wrong_2++;
        return;
    end
    if( ccomp(yp, cp) )
        packet_matched_2++;
    else
        packet_wrong_2++;
endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SC_PKT",$sformatf("number of packet_received: %d ",packet_received_0+packet_received_1+packet_received_2),UVM_LOW)
        `uvm_info("CHANNEL_0_GET",$sformatf("packet_received: %d matched: %d wrong: %d",packet_received_0,packet_matched_0,packet_wrong_0),UVM_LOW)
        `uvm_info("CHANNEL_1_GET",$sformatf("packet_received: %d matched: %d wrong: %d",packet_received_1,packet_matched_1,packet_wrong_1),UVM_LOW)
        `uvm_info("CHANNEL_2_GET",$sformatf("packet_received: %d matched: %d wrong: %d",packet_received_2,packet_matched_2,packet_wrong_2),UVM_LOW)
        if(count_3>0)
            `uvm_error("GET_ADDR_3",$sformatf("get %d to address 3",count_3))
    
    endfunction

endclass