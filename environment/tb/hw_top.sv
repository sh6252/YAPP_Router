/*-----------------------------------------------------------------
File name     : hw_top.sv
Developers    : Kathleen Meade, Brian Dickinson
Created       : 01/04/11
Description   : lab06_vif hardware top module for acceleration
              : Instantiates clock generator and YAPP interface only for testing - no DUT
Notes         : From the Cadence "SystemVerilog Accelerated Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/

module hw_top;

  // Clock and reset signals
  logic [31:0]  clock_period;
  logic         run_clock;
  logic         clock;
  logic         reset;

  yapp_if in0(clock, reset);

  channel_if c_in0(clock,reset); 
  channel_if c_in1(clock,reset);
  channel_if c_in2(clock,reset); 
  
  hbus_if hb_in(clock,reset);

  clock_and_reset_if cl_re_in(
    .clock(clock),
    .reset(reset),
    .run_clock(run_clock),
    .clock_period(clock_period) );
  

  // CLKGEN module generates clock
  clkgen clkgen (
    .clock(clock),
    .run_clock(run_clock),
    .clock_period(clock_period)
  );

 yapp_router dut(
    .reset(reset),
    .clock(clock),
    .error(),

    // YAPP interface
    .in_data(in0.in_data),
    .in_data_vld(in0.in_data_vld),
    .in_suspend(in0.in_suspend),

    // Output Channels
    //Channel 0
    .data_0(c_in0.data),
    .data_vld_0(c_in0.data_vld),
    .suspend_0(c_in0.suspend),
    //Channel 1
    .data_1(c_in1.data),
    .data_vld_1(c_in1.data_vld),
    .suspend_1(c_in1.suspend),
    //Channel 2
    .data_2(c_in2.data),
    .data_vld_2(c_in2.data_vld),
    .suspend_2(c_in2.suspend),

    // HBUS Interface 
    .haddr(hb_in.haddr),
    .hdata(hb_in.hdata_w),
    .hen(hb_in.hen),
    .hwr_rd(hb_in.hwr_rd));

  

endmodule
