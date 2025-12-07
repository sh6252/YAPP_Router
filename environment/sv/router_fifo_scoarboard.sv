class router_fifo_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(router_scoreboard)

    // Analysis imports declarations
    `uvm_analysis_imp_decl(_yapp)
    `uvm_analysis_imp_decl(_chan0) 
    `uvm_analysis_imp_decl(_chan1) 
    `uvm_analysis_imp_decl(_chan2) 
    `uvm_analysis_imp_decl(_hbus) 

    // TLM FIFOs - תוקן התחביר
    uvm_tlm_analysis_fifo#(yapp_packet) yapp_fifo;
    uvm_tlm_analysis_fifo#(hbus_transaction) hbus_fifo;
    uvm_tlm_analysis_fifo#(channel_packet) chan0_fifo;
    uvm_tlm_analysis_fifo#(channel_packet) chan1_fifo;
    uvm_tlm_analysis_fifo#(channel_packet) chan2_fifo;

    // Packet handles
    yapp_packet yp;
    channel_packet cp;
    hbus_transaction htr;
   
    // Statistics counters
    int packet_received = 0;
    int packet_wrong = 0;
    int packet_matched = 0,packet_mismatched=0;
    int count_3 = 0;
    int big_packet=0;
    int not_en=0;
    int packet_valid=0;

    bit [7:0] maxpksize_reg=8'h3F,router_en_reg=1'b1;

    
    function new(string name, uvm_component parent);
        super.new(name, parent);

        yapp_fifo = new("yapp_fifo", this);
        hbus_fifo = new("hbus_fifo", this);
        chan0_fifo = new("chan0_fifo", this);
        chan1_fifo = new("chan1_fifo", this);
        chan2_fifo = new("chan2_fifo", this);

    endfunction

    task run_phase(uvm_phase phase);
        fork
            check_packet();
            update_register();
        join
    endtask

    task update_register();
        forever begin
            hbus_fifo.get_peek_export.get(htr);
            if(htr.hwr_rd==HBUS_WRITE)
            case(htr.haddr)
            'h1000: maxpksize_reg=htr.hdata;
            'h1001: router_en_reg =htr.hdata;
            endcase
        end
    endtask

    task check_packet();
        bit valid,pkt_comp;
        logic [1:0] addr;
        forever begin
            do begin
                yapp_fifo.get_peek_export.get(yp);
                packet_received++;
                valid=1'b1;
                if(yp.addr==3)begin
                    count_3++;
                    packet_wrong++;
                    valid=1'b0;
                end
                else if((router_en_reg==1)&&(yp.length>maxpksize_reg))begin
                big_packet++;
                packet_wrong++;
                valid=1'b0;
                end
                else if(router_en_reg==0)begin
                not_en++;
                packet_wrong++;
                valid=1'b0;
                end
                end
            while(valid==1'b0);
            packet_valid++;
            case(yp.addr)
                0: chan0_fifo.get_peek_export.get(cp);
                1: chan1_fifo.get_peek_export.get(cp);
                2: chan2_fifo.get_peek_export.get(cp);
            endcase

            pkt_comp=ccomp(yp,cp);
            if(pkt_comp)
                packet_matched++;
            else
                packet_mismatched++;
        end
    endtask

    function bit ccomp(yapp_packet yp, channel_packet cp, uvm_comparer comparer = null);
        if (comparer == null)
            comparer = new();
            
        ccomp = comparer.compare_field("addr", yp.addr, cp.addr, 2);
        ccomp &= comparer.compare_field("length", yp.length, cp.length, 6);
        
        foreach(yp.payload[i])
            ccomp &= comparer.compare_field($sformatf("payload[%d]", i), 
                                           yp.payload[i], cp.payload[i], 8);
        
        ccomp &= comparer.compare_field("parity", yp.parity, cp.parity, 8);
        
        if (!ccomp) begin
            `uvm_error("PACKET_MISMATCH", "Packet comparison failed")
            yp.print();
            cp.print();
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info("SCOREBOARD_REPORT",  {60{"="}}, UVM_LOW)
        `uvm_info("SCOREBOARD_REPORT", "Router Scoreboard Final Report", UVM_LOW)
        `uvm_info("SCOREBOARD_REPORT",  {60{"="}}, UVM_LOW)
        `uvm_info("SCOREBOARD_REPORT", $sformatf("Total packets received:  %0d", packet_received), UVM_LOW)
        `uvm_info("SCOREBOARD_REPORT", $sformatf("Packets matched:         %0d", packet_matched), UVM_LOW)
        `uvm_info("SCOREBOARD_REPORT", $sformatf("Packets mismatched:      %0d", packet_wrong), UVM_LOW)
        
        if (count_3 > 0)
            `uvm_error("INVALID_ADDRESS", $sformatf("Received %0d packet(s) with invalid address 2'b11", count_3))
        
        if (packet_wrong > 0)
            `uvm_error("TEST_FAILED", $sformatf("Test FAILED: %0d packet mismatches detected", packet_wrong))
        else if (packet_matched > 0)
            `uvm_info("TEST_PASSED", $sformatf("Test PASSED: All %0d packets matched successfully", packet_matched), UVM_LOW)
        
        `uvm_info("SCOREBOARD_REPORT",  {60{"="}}, UVM_LOW)
    endfunction

endclass