class router_reference extends uvm_component;
    `uvm_component_utils(router_reference)

    `uvm_analysis_imp_decl(_yapp)
    uvm_analysis_imp_yapp#(yapp_packet, router_reference) yapp_in;

    `uvm_analysis_imp_decl(_hbus) 
    uvm_analysis_imp_hbus#(hbus_transaction, router_reference) hbus_in;

    uvm_analysis_port #(yapp_packet) yapp_out;

    bit [7:0] maxpksize=8'h3f;
    bit [7:0] router_en= 1'b1;
    int big_size=0;
    int not_en=0;
    int addr_3=0;
    int count_packets=0;

    function new(string name,uvm_component parent);
        super.new(name,parent);
        yapp_in=new("yapp_in",this);
        hbus_in=new("hbus_in",this);
        yapp_out=new("yapp_out",this);
    endfunction

    function void write_hbus(hbus_transaction transaction);
       if(transaction.hwr_rd==HBUS_WRITE)begin
        if(transaction.haddr=='b1000)
            maxpksize=transaction.hdata;
        else if(transaction.haddr=='b1001)
                router_en=transaction.hdata;
    end
    endfunction

    function void write_yapp(yapp_packet pkt);
    count_packets++;
        if(!router_en) begin
            not_en++;
            return;
        end
        if(pkt.length>maxpksize) begin
            big_size++;
            return;
        end
        if(pkt.addr==3)
            addr_3++;
        else yapp_out.write(pkt);
    endfunction


    function void report_phase(uvm_phase phase);
        `uvm_info(get_full_name(),$sformatf("total_packets: %d router_not_enable: %d jumbo_packets: %d address_3: %d",count_packets,not_en,big_size,addr_3),UVM_LOW)
    endfunction


endclass