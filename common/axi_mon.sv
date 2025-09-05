//=============================================================================================
// File: axi_mon.sv
// Description: Defines the UVM monitor class for observing AXI transactions.
//              Captures write and read transactions and sends them to the scoreboard.
//=============================================================================================

class axi_mon extends uvm_monitor;

    //----> Analysis Port
    //      Sends AXI transactions to the scoreboard
    uvm_analysis_port #(axi_tx) ap_port;

    //----> Virtual Interface
    //      Reference to the AXI interface
    virtual axi_intf vif;

    //----> Transaction Naming
    //      Strings for naming write and read transactions
    string wr_txA_name, rd_txA_name;

    //----> Transaction Maps
    //      Arrays to store write and read transactions
    axi_tx wr_txA[15:0];  // Write transactions indexed by ID
    axi_tx rd_txA[15:0];  // Read transactions indexed by ID

    `uvm_component_utils(axi_mon)          // Register with UVM factory
    `NEW_COMP                              // NEW constructor
    
    //----> Build Phase
    //      Initializes the analysis port and retrieves the virtual interface
    function void build();
        //----> Get virtual interface from resource database
        if (!uvm_resource_db#(virtual axi_intf)::read_by_name("GLOBAL", "PIF", vif, this))
            `uvm_fatal("NO_VIF", "Virtual interface not set for axi_mon")
        ap_port = new("ap_port", this);   // Create analysis port
    endfunction

    //----> Run Phase
    //      Monitors AXI transactions on the interface
    task run();
        forever begin
            @(posedge vif.aclk);                // Wait for clock edge
            //----> Monitor Write Transactions
            //========================={ wr_txA }=============================//
            if (vif.awvalid && vif.awready) begin
                wr_txA_name = $sformatf("wr_txA[%0d]", vif.awid);
                wr_txA[vif.awid] = axi_tx::type_id::create(wr_txA_name);
                wr_txA[vif.awid].wr_rd      = 1'b1;
                wr_txA[vif.awid].addr       = vif.awaddr; 
                wr_txA[vif.awid].burst_size = vif.awsize;
                wr_txA[vif.awid].burst_type = burst_type_t'(vif.awburst);
                wr_txA[vif.awid].burst_len  = vif.awlen;
                wr_txA[vif.awid].tx_id      = vif.awid;
            end
            //--------------------------------------------------//
            if (vif.wvalid && vif.wready && (vif.wid != null)) begin
                wr_txA[vif.wid].dataQ.push_back(vif.wdata);
                wr_txA[vif.wid].strbQ.push_back(vif.wstrb);
            end 
            //--------------------------------------------------//
            if (vif.bvalid && vif.bready) begin
                wr_txA[vif.bid].respQ.push_back(vif.bresp);
                ap_port.write(wr_txA[vif.bid]);
                wr_txA[vif.bid].print();
            end
            //----> Monitor Read Transactions
            //========================={ rd_txA }=============================//
            if (vif.arvalid && vif.arready) begin
                rd_txA_name = $sformatf("rd_txA[%0d]", vif.arid);
                rd_txA[vif.arid] = axi_tx::type_id::create(rd_txA_name);
                rd_txA[vif.arid].wr_rd      = 1'b0;
                rd_txA[vif.arid].addr       = vif.araddr;
                rd_txA[vif.arid].burst_size = vif.arsize;
                rd_txA[vif.arid].burst_type = burst_type_t'(vif.arburst);
                rd_txA[vif.arid].burst_len  = vif.arlen;
                rd_txA[vif.arid].tx_id      = vif.arid; 
            end
            //--------------------------------------------------//
            if (vif.rvalid && vif.rready) begin
                rd_txA[vif.rid].dataQ.push_back(vif.rdata);
                rd_txA[vif.rid].respQ.push_back(vif.rresp);
                if (vif.rlast) begin
                    ap_port.write(rd_txA[vif.rid]);
                    rd_txA[vif.rid].print();
                end
            end

        end
    endtask
endclass
//=============================================================================================
