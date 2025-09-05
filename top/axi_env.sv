//==========================================================================================
// File: axi_env.sv
// Description: Defines the UVM environment class for AXI protocol verification.
//              Integrates master agent, slave agent, and scoreboard components.
//              Supports transaction and byte-level comparison configurations.
//==========================================================================================
class axi_env extends uvm_env;
    axi_magent magent;                      // Master agent instance for driving and monitoring
    axi_sagent sagent;                      // Slave agent instance for driving and monitoring
    axi_sbd sbd;                            // Scoreboard instance for transaction comparison
    `uvm_component_utils(axi_env)           // Register with UVM factory
    `NEW_COMP

    //----> Build Phase
    //      Creates master agent, slave agent, and scoreboard instances
    function void build();
        `uvm_info("ENV", "Build phase Hitted", "UVM_NONE")
        magent = axi_magent::type_id::create("magent", this);   // Instantiate master agent
        sagent = axi_sagent::type_id::create("sagent", this);   // Instantiate slave agent
        sbd    = axi_sbd::type_id::create("sbd", this);         // Instantiate scoreboard
    endfunction

    //----> Connect Phase
    //      Connects master and slave monitors to the scoreboard
    //      Slave connection is enabled only for transaction-level comparison
    function void connect();
        `uvm_info("ENV", "Connet phase completed", UVM_HIGH)              
        magent.mon.ap_port.connect(sbd.imp_master);         // Connect master monitor to scoreboard
        `ifdef TX_COMPARE
            sagent.mon.ap_port.connect(sbd.imp_slave);      // Connect slave monitor to scoreboard
        `endif
    endfunction

endclass
//==========================================================================================
