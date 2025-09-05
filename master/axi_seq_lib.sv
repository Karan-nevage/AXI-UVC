//=============================================================================================
// File: axi_seq_lib.sv
// Description: Defines UVM sequence classes for AXI protocol verification.
//              Includes a base sequence and specific sequences for various test scenarios.
//=============================================================================================
//                              Base Sequence
//=============================================================================================
class axi_base_seq extends uvm_sequence#(axi_tx);
    axi_tx tx;                            // Transaction instance
    uvm_phase phase;                      // Reference to the current phase
    `uvm_object_utils(axi_base_seq)       // Register with UVM factory
    `NEW_OBJ                              // Constructor

    //----> Pre-Body Task
    //      Manages objections for sequence execution
    task pre_body();
        phase = get_starting_phase();     // Get the current run phase
        if (phase != null) begin
            phase.raise_objection(this);  // Raise objection to start phase
            phase.phase_done.set_drain_time(this, 100); // Set drain time
        end
    endtask

    //----> Post-Body Task
    //      Drops objections after sequence completion
    task post_body();
        if (phase != null) phase.drop_objection(this); // Drop objection
    endtask
  
endclass
//=============================================================================================
//                              Functional Sequences
//=============================================================================================

//-----------------------------------------------------------------------------------------
//====================== Multiple Write/Read Sequence =========================
//-----------------------------------------------------------------------------------------
// Sequence for performing multiple write transactions followed by reads
class axi_n_wr_rd_seq extends axi_base_seq;
    `uvm_object_utils(axi_n_wr_rd_seq)     // Register with UVM factory
    `NEW_OBJ                               // Constructor

    axi_tx tx;                             // Transaction object
    axi_tx txQ[$];                         // Queue for storing transactions

    //----> Body Task
    //      Executes write transactions followed by read transactions
    task body();
        //----> Write Transactions
        repeat (`NUM_OF_TX) begin
            `uvm_do_with(req, {req.wr_rd == 1'b1;}) // Write transaction
            tx = new req;                       // Shallow copy of req to tx
            txQ.push_back(tx);                  // Store transaction in queue
        end
        txQ.shuffle();

        //----> Read Transactions
        repeat (`NUM_OF_TX) begin
            tx = txQ.pop_front();               // Retrieve transaction from queue
            `uvm_do_with(req, { req.wr_rd      == 1'b0;
                                req.tx_id      == tx.tx_id;  
                                req.addr       == tx.addr;
                                req.burst_len  == tx.burst_len;
                                req.burst_size == tx.burst_size;
                                req.burst_type == tx.burst_type;
                              })    
        end
    endtask
  
endclass
//=========================================================================================

//-----------------------------------------------------------------------------------------
//====================== Burst Length Test Sequence =========================
//-----------------------------------------------------------------------------------------
// Sequence for testing different burst lengths
class axi_burst_len_seq extends axi_base_seq;
    `uvm_object_utils(axi_burst_len_seq)   // Register with UVM factory
    `NEW_OBJ                               // Constructor

    axi_tx tx;                             // Transaction object
    axi_tx txQ[$];                         // Queue for storing transactions

    //----> Body Task
    //      Executes write transactions with varying burst lengths, followed by reads
    task body();
        //----> Write Transactions
        for (int i = 0; i < `NUM_OF_TX; i++) begin
            `uvm_do_with(req, {req.wr_rd == 1'b1; req.burst_len == i;}) // Write transaction
            tx = new req;                                           // Shallow copy of req to tx
            txQ.push_back(tx);                                      // Store transaction in queue
        end
        txQ.shuffle();

        //----> Read Transactions
        repeat (`NUM_OF_TX) begin
            tx = txQ.pop_front();               // Retrieve transaction from queue
            `uvm_do_with(req, { req.wr_rd      == 1'b0;
                                req.tx_id      == tx.tx_id;  
                                req.addr       == tx.addr;
                                req.burst_len  == tx.burst_len;
                                req.burst_size == tx.burst_size;
                                req.burst_type == tx.burst_type;
                              })    
        end
    endtask
  
endclass
//=========================================================================================

//-----------------------------------------------------------------------------------------
//====================== Burst Size Test Sequence =========================
//-----------------------------------------------------------------------------------------
// Sequence for testing different burst sizes
class axi_burst_size_seq extends axi_base_seq;
    `uvm_object_utils(axi_burst_size_seq)  // Register with UVM factory
    `NEW_OBJ                               // Constructor

    axi_tx tx;                             // Transaction object
    axi_tx txQ[$];                         // Queue for storing transactions

    //----> Body Task
    //      Executes write transactions with varying burst sizes, followed by reads
    task body();
        //----> Write Transactions
        for (int i = 0; i < `NUM_OF_TX; i++) begin
            `uvm_do_with(req, {req.wr_rd == 1'b1; req.burst_size == i;}) // Write transaction
            tx = new req;                                            // Shallow copy of req to tx
            txQ.push_back(tx);                                       // Store transaction in queue
        end
        txQ.shuffle();

        //----> Read Transactions
        repeat (`NUM_OF_TX) begin
            tx = txQ.pop_front();               // Retrieve transaction from queue
            `uvm_do_with(req, { req.wr_rd      == 1'b0;
                                req.tx_id      == tx.tx_id;  
                                req.addr       == tx.addr;
                                req.burst_len  == tx.burst_len;
                                req.burst_size == tx.burst_size;
                                req.burst_type == tx.burst_type;
                              })    
        end
    endtask
  
endclass
//=========================================================================================

//-----------------------------------------------------------------------------------------
//====================== WRAP Transaction Sequence =========================
//-----------------------------------------------------------------------------------------
// Sequence for testing WRAP-type transactions
class axi_wrap_transf_seq extends axi_base_seq;
    `uvm_object_utils(axi_wrap_transf_seq) // Register with UVM factory
    `NEW_OBJ                               // Constructor

    axi_tx tx;                             // Transaction object
    axi_tx txQ[$];                         // Queue for storing transactions

    //----> Body Task
    //      Executes WRAP write transactions followed by reads
    task body();
        //----> Write Transactions
        for (int i = 0; i < `NUM_OF_TX; i++) begin
            `uvm_do_with(req, {req.wr_rd == 1'b1; req.burst_type == WRAP;}) // Write transaction
            tx = new req;                                               // Shallow copy of req to tx
            txQ.push_back(tx);                                          // Store transaction in queue
        end
        txQ.shuffle();

        //----> Read Transactions
        repeat (`NUM_OF_TX) begin
            tx = txQ.pop_front();               // Retrieve transaction from queue
            `uvm_do_with(req, { req.wr_rd      == 1'b0;
                                req.tx_id      == tx.tx_id;  
                                req.addr       == tx.addr;
                                req.burst_len  == tx.burst_len;
                                req.burst_size == tx.burst_size;
                                req.burst_type == tx.burst_type;
                              })    
        end
    endtask
  
endclass
//=============================================================================================
