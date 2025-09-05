//========================================================================================================
// File: axi_sbd.sv
// Description: Defines the UVM scoreboard class for AXI protocol verification.
//              Tracks matches and mismatches for transaction-level and byte-level comparisons.
//              Maintains separate queues for master and slave transactions.
//========================================================================================================
`uvm_analysis_imp_decl(_master)
`uvm_analysis_imp_decl(_slave)

class axi_sbd extends uvm_scoreboard;
    uvm_analysis_imp_master#(axi_tx, axi_sbd) imp_master;
    uvm_analysis_imp_slave#(axi_tx, axi_sbd) imp_slave;
    axi_tx mst_txQ[$];
    axi_tx slv_txQ[$];
    axi_tx mst_tx, slv_tx;
    `uvm_component_utils(axi_sbd)
    `NEW_COMP

    //----> Build Phase
    //      Allocates memory for master and slave analysis ports
    function void build();
        imp_master = new("imp_master", this);
        imp_slave = new("imp_slave", this);
    endfunction

    //----> Write Master Transactions
    //      Pushes master transactions into the master queue
    function void write_master(axi_tx tx);
        mst_txQ.push_back(tx);
    endfunction
        
    //----> Write Slave Transactions
    //      Pushes slave transactions into the slave queue
    function void write_slave(axi_tx tx);
        slv_txQ.push_back(tx);
    endfunction

    //----> Run Phase
    //      Compares master and slave transactions, updating match/mismatch counts
    task run();
        forever begin
            wait(mst_txQ.size() > 0 && slv_txQ.size() > 0);
            mst_tx = mst_txQ.pop_front();
            slv_tx = slv_txQ.pop_front();
            if (mst_tx.compare(slv_tx)) begin
                num_matches++;
            end
            else begin
                num_missmatches++;
            end
        end
    endtask

endclass
//========================================================================================================
