//=============================================================================================
// File: axi_magent.sv
// Description: Defines the UVM master agent class for AXI protocol verification.
//              Integrates driver, sequencer, monitor, and coverage components.
//=============================================================================================

class axi_magent extends uvm_agent;
    axi_drv drv;                          // Driver for driving AXI transactions
    axi_sqr sqr;                          // Sequencer for controlling sequence execution
    axi_mon mon;                          // Monitor for observing AXI transactions
    axi_cov cov;                          // Coverage subscriber for collecting functional coverage
    `uvm_component_utils(axi_magent)      // Register with UVM factory
    `NEW_COMP                             // Constructor
    
    //----> Build Phase
    //      Creates driver, sequencer, monitor, and coverage components
    function void build();
        drv = axi_drv::type_id::create("drv", this); // Create driver
        sqr = axi_sqr::type_id::create("sqr", this); // Create sequencer
        cov = axi_cov::type_id::create("cov", this); // Create coverage subscriber
        mon = axi_mon::type_id::create("mon", this); // Create monitor
    endfunction

    //----> Connect Phase
    //      Connects driver to sequencer and monitor to coverage subscriber
    function void connect();
        `uvm_info("MAGENT", "Connected phase hitted", UVM_HIGH)
        //----> Connect driver’s sequence item port to sequencer’s export
        drv.seq_item_port.connect(sqr.seq_item_export);
        //----> Connect monitor’s analysis port to coverage subscriber’s export
        mon.ap_port.connect(cov.analysis_export);
    endfunction
  
endclass
//=============================================================================================
