//=============================================================================================
// File: axi_sagent.sv
// Description: Defines the UVM slave agent class for AXI protocol verification.
//              Integrates responder and monitor components for slave-side operations.
//=============================================================================================

class axi_sagent extends uvm_agent;
    axi_rsp rsp;                          // Responder for handling slave transactions
    axi_mon mon;                          // Monitor for observing transactions
    `uvm_component_utils(axi_sagent)      // Register with UVM factory
    `NEW_COMP                             // Constructor
    
    //----> Build Phase
    //      Creates responder and monitor components
    function void build();
        rsp = axi_rsp::type_id::create("rsp", this); // Create responder
        mon = axi_mon::type_id::create("mon", this); // Create monitor
    endfunction

endclass
//=============================================================================================
