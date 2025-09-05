//=============================================================================================
// File: axi_config.sv
// Description: Defines common macros and utility constructs for the AXI UVM testbench.
//              Includes macros for test tasks, sizing, constructors, and scoreboard variables.
//=============================================================================================

//==================================== Macros for Multiple Write/Read Test ====================
//    Defines the number of transactions and test-specific restrictions
`define NUM_OF_TX 5
    //----> Test-Specific Value Restrictions
    //      axi_n_wr_rd_test: No restrictions on values
    //      axi_burst_len_test: Burst length must not exceed 16
//=============================================================================================

//==================================== Macros for Signal Sizing ================================
//    Defines width parameters for AXI signals
`define ADDR_WIDTH 32
`define DATA_WIDTH 32
`define STRB_WIDTH `DATA_WIDTH/8
//=============================================================================================

//==================================== Macros for Constructors =================================
//----> Constructor for UVM Components
`define NEW_COMP \
    function new(string name="", uvm_component parent); \
        super.new(name, parent); \
    endfunction

//----> Constructor for UVM Objects
`define NEW_OBJ \
    function new(string name=""); \
        super.new(name); \
    endfunction
//=============================================================================================

//==================================== Macro for Run Phase Task ================================
//    Defines a standard run phase task for test execution
`define TEST_RUN_TASK \
    task run_phase(uvm_phase phase); \
        phase.raise_objection(this); \
        phase.phase_done.set_drain_time(this, 50); \
        seq.start(env.magent.sqr); \
        phase.drop_objection(this); \
    endtask
//=============================================================================================

//==================================== Global Variables for Scoreboard =========================
//    Tracks matches, mismatches, and expected byte count for AXI verification
int num_missmatches;
int num_matches;
//----> Expected byte count for byte-level comparison
int exp_byte_count;
//=============================================================================================
