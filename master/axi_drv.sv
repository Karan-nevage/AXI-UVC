//=============================================================================================
// File: axi_drv.sv
// Description: Defines the UVM driver class for AXI protocol verification.
//              Drives transactions from the sequencer to the DUT via the AXI interface.
//              Uses semaphores to prevent data override during write operations.
//=============================================================================================

class axi_drv extends uvm_driver#(axi_tx);
    virtual axi_intf vif;                 // Virtual interface to connect to DUT
    semaphore wd_smp = new(1);            // Semaphore for write data phase
    semaphore wr_smp = new(1);            // Semaphore for write response phase
    `uvm_component_utils(axi_drv)         // Register with UVM factory
    `NEW_COMP                             // Constructor

    //----> Run Phase
    //      Main driver loop to process transactions
    task run();
        uvm_resource_db#(virtual axi_intf)::read_by_name("GLOBAL", "PIF", vif, this);
        wait (vif.bfm_cb.aresetn == 0);   // Wait for reset deassertion
        forever begin
            //----> Process Transactions
            seq_item_port.get_next_item(req); // Request next transaction
            `ifdef NONOVERLAPPING
                req.print();                  // Print transaction details
                drive_tx(req);                // Drive transaction to DUT
                seq_item_port.item_done();    // Signal completion of transaction
            `endif
            `ifdef OVERLAPPING
                fork
                    req.print();              // Print transaction details
                    drive_tx(req);            // Drive transaction to DUT
                join_none
                seq_item_port.item_done();    // Signal completion of transaction
                #70;                          // Delay to avoid simultaneous writes
            `endif
        end
    endtask

    //===================================//
  
    //----> Drive Transaction Task
    //      Drives write or read transaction signals to the DUT
    task drive_tx(axi_tx tx);
        //----> Write Transactions
        if (tx.wr_rd == 1) begin      
            write_address_phase(tx);      // Drive write address phase
            write_data_phase(tx);         // Drive write data phase
            write_response_phase(tx);     // Drive write response phase
            exp_byte_count += (tx.burst_len + 1)*(2**(tx.burst_size)); 
        end      
        //----> Read Transactions
        if (tx.wr_rd == 0) begin      
            read_address_phase(tx);       // Drive read address phase
            read_data_phase(tx);          // Drive read data and response phase
        end
    endtask

//==============================================================================
//                          Driving Tasks by Channel
//==============================================================================    
    //----> Write Address Phase Task
    //      Drives write address channel signals
    task write_address_phase(axi_tx tx);
        @(posedge vif.aclk);
        vif.awid    = tx.tx_id;
        vif.awlen   = tx.burst_len;
        vif.awsize  = tx.burst_size;
        vif.awburst = tx.burst_type;
        vif.awaddr  = tx.addr;
        vif.awvalid = 1'b1;
        wait (vif.awready == 1'b1);
        //----> Deassert Signals
        @(posedge vif.aclk);
        vif.awaddr  = 0;
        vif.awlen   = 0;
        vif.awsize  = 0;
        vif.awburst = 0;
        vif.awid    = 0;
        vif.awvalid = 0;    
    endtask

    //----> Write Data Phase Task
    //      Drives write data channel signals
    task write_data_phase(axi_tx tx);
        for (int i = 0; i <= tx.burst_len; i++) begin
            wd_smp.get(1);
            @(posedge vif.aclk);
            $display("This is iteration %0d", i+1);
            vif.wdata  = tx.dataQ.pop_front();
            vif.wstrb  = tx.strbQ.pop_front();
            vif.wid    = tx.tx_id;
            vif.wvalid = 1'b1;
            vif.wlast  = (i == tx.burst_len) ? 1'b1 : 1'b0;
            wd_smp.put(1);
        end    
        //----> Deassert Signals
        @(posedge vif.aclk);
        vif.wdata  = 0;
        vif.wstrb  = 0;
        vif.wid    = 0;
        vif.wvalid = 0;
        vif.wlast  = 0;
    endtask

    //----> Write Response Phase Task
    //      Handles write response channel signals
    task write_response_phase(axi_tx tx);
        while (vif.bvalid == 1'b0) begin
            @(posedge vif.aclk);
        end
        wr_smp.get(1);
        vif.bready = 1'b1;
        @(posedge vif.aclk);
        vif.bready = 1'b0;
        wr_smp.put(1);
    endtask
    
    //----> Read Address Phase Task
    //      Drives read address channel signals
    task read_address_phase(axi_tx tx);
        @(posedge vif.aclk);
        vif.arid    = tx.tx_id;
        vif.arlen   = tx.burst_len;
        vif.arsize  = tx.burst_size;
        vif.arburst = tx.burst_type;
        vif.araddr  = tx.addr;
        vif.arvalid = 1'b1;
        wait (vif.arready == 1'b1);
        //----> Deassert Signals
        @(posedge vif.aclk);
        vif.araddr  = 0;
        vif.arlen   = 0;
        vif.arsize  = 0;
        vif.arburst = 0;
        vif.arid    = 0;
        vif.arvalid = 0;    
    endtask

    //----> Read Data Phase Task
    //      Handles read data and response channel signals
    task read_data_phase(axi_tx tx);
        @(posedge vif.aclk);
        repeat (tx.burst_len + 1) begin
            while (vif.rvalid == 0) begin
                @(posedge vif.aclk);
            end    
            vif.rready = 1'b1;
            @(posedge vif.aclk);
            vif.rready = 1'b0;
        end
    endtask

endclass
//=============================================================================================
