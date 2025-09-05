//=========================================================================================
// File: axi_test_lib.sv
// Description: Defines UVM test classes for AXI protocol verification.
//              Includes a base test class and derived tests for various scenarios.
//=========================================================================================
//                              Base Test Case
//=========================================================================================
class axi_base_test extends uvm_test;
    axi_env env;                           // Environment instance for AXI verification
    `uvm_component_utils(axi_base_test)    // Register with UVM factory
    `NEW_COMP                              // Macro for constructor

    //----> Build Phase
    //      Creates the AXI environment instance
    function void build();
        `uvm_info("ENV", "Build phase Hitted", "UVM_NONE")
        env = axi_env::type_id::create("env", this); // Factory creation of environment
    endfunction

    //----> End of Elaboration Phase
    //      Prints factory overrides and UVM component topology
    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_factory factory = uvm_factory::get(); // Get factory instance (UVM 1.2)
        factory.print();                         // Print factory overrides
        uvm_top.print_topology();                // Print UVM component hierarchy
    endfunction

    //----> Report Phase
    //      Reports test status based on transaction or byte comparison results
    function void report();
        `ifdef TX_COMPARE
        if ((num_missmatches == 0) && (num_matches == (`NUM_OF_TX))) begin
            `uvm_info("REPORT", $psprintf("TEST PASSED SUCCCESFULLY.......! \n Num of Matches:%0d \n NUM of Miss-Matches:%d", num_matches, num_missmatches), UVM_NONE)
        `elsif BYTE_COMPARE
        if ((num_missmatches == 0) || (num_matches == (exp_byte_count))) begin
            `uvm_info("REPORT", $psprintf("TEST PASSED SUCCCESFULLY.......! \n Expected Bytes:%0d", exp_byte_count), UVM_NONE)
        `endif
        end
        else begin
            `uvm_error("REPORT", $psprintf("TEST FAILED.......! \n Expected Bytes:%0d \n Num of Matches:%0d \n NUM of Miss-Matches:%d", exp_byte_count, num_matches, num_missmatches))
        end
    endfunction

endclass
//======================================================================================
//                          Functional Test Cases
//======================================================================================

//--------------------------------------------------------------------------------------
//====================== Multiple Write Read Test ===========================
//--------------------------------------------------------------------------------------
class axi_n_wr_rd_test extends axi_base_test;
    `uvm_component_utils(axi_n_wr_rd_test)              // Register with UVM factory
    `NEW_COMP                                           // NEW constructor
    axi_n_wr_rd_seq seq;                                // Sequence instance for multiple write/read

    //----> Build Phase
    //      Creates the sequence for multiple write/read operations
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = new("seq");
    endfunction
    
    //----> Run Phase
    //      Executes the multiple write/read sequence
    task run_phase(uvm_phase phase); 
        phase.raise_objection(this);                    // Raise objection to start phase
        phase.phase_done.set_drain_time(this, 150);     // Set drain time to 150 ns
        seq.start(env.magent.sqr);                      // Start the sequence on master sequencer
        phase.drop_objection(this);                     // Drop objection to end phase
    endtask

endclass
//======================================================================================

//--------------------------------------------------------------------------------------
//===================== Different Burst Length Test =========================
//--------------------------------------------------------------------------------------
class axi_burst_len_test extends axi_base_test;
    `uvm_component_utils(axi_burst_len_test)            // Register with UVM factory
    `NEW_COMP                                           // NEW constructor
    axi_burst_len_seq seq;                              // Sequence instance for burst length tests

    //----> Build Phase
    //      Creates the sequence for testing different burst lengths
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = new("seq");
    endfunction
    
    //----> Run Phase
    //      Executes the burst length test sequence
    task run_phase(uvm_phase phase); 
        phase.raise_objection(this);                    // Raise objection to start phase
        phase.phase_done.set_drain_time(this, 150);     // Set drain time to 150 ns
        seq.start(env.magent.sqr);                      // Start the sequence on master sequencer
        phase.drop_objection(this);                     // Drop objection to end phase
    endtask

endclass
//======================================================================================

//--------------------------------------------------------------------------------------
//===================== Different Burst Size Test ==========================
//--------------------------------------------------------------------------------------
class axi_burst_size_test extends axi_base_test;
    `uvm_component_utils(axi_burst_size_test)           // Register with UVM factory
    `NEW_COMP                                           // NEW constructor
    axi_burst_size_seq seq;                             // Sequence instance for burst size tests

    //----> Build Phase
    //      Creates the sequence for testing different burst sizes
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = new("seq");
    endfunction
    
    //----> Run Phase
    //      Executes the burst size test sequence
    task run_phase(uvm_phase phase); 
        phase.raise_objection(this);                    // Raise objection to start phase
        phase.phase_done.set_drain_time(this, 150);     // Set drain time to 150 ns
        seq.start(env.magent.sqr);                      // Start the sequence on master sequencer
        phase.drop_objection(this);                     // Drop objection to end phase
    endtask

endclass
//======================================================================================

//--------------------------------------------------------------------------------------
//======================= WRAP Transaction Test ===========================
//--------------------------------------------------------------------------------------
class axi_wrap_transf_test extends axi_base_test;
    `uvm_component_utils(axi_wrap_transf_test)          // Register with UVM factory
    `NEW_COMP                                           // NEW constructor
    axi_wrap_transf_seq seq;                            // Sequence instance for WRAP transactions

    //----> Build Phase
    //      Creates the sequence for testing WRAP transactions
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = new("seq");
    endfunction
    
    //----> Run Phase
    //      Executes the WRAP transaction test sequence
    task run_phase(uvm_phase phase); 
        phase.raise_objection(this);                    // Raise objection to start phase
        phase.phase_done.set_drain_time(this, 150);     // Set drain time to 150 ns
        seq.start(env.magent.sqr);                      // Start the sequence on master sequencer
        phase.drop_objection(this);                     // Drop objection to end phase
    endtask

endclass
//======================================================================================
