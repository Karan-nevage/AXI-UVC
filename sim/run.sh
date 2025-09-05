#=======================================================================================
# File: run.sh
# Description: Shell script for compiling and simulating the AXI UVM testbench using VCS and Verdi.
#              Supports transaction-level or byte-level comparison configurations.
#=======================================================================================

#========================= Compilation and Elaboration ==================================
#    -sverilog: Specifies SystemVerilog file compilation
#    -full64: Uses 64-bit VCS tool (supports 32-bit and 64-bit tools)
#    -debug_access+all: Enables full debug access for all components
#    -kdb: Generates a database for Verdi waveform viewing
#    Compilation options support: 1. BYTE_COMPARE  2. TX_COMPARE
#=======================================================================================

vcs -sverilog -full64 -debug_access+all -kdb \
        +incdir+../top \
        +incdir+../master \
        +incdir+../slave \
        +incdir+../common \
        +incdir+../src \
        +define+UVM_NO_DPI \
        -l comp.log \
        +define+TX_COMPARE \
        +define+NONOVERLAPPING \
        -cm line+cond+tgl+fsm+assert+branch \
        list.sv
#---------------------------------------------------------------------------------------

#================================ Simulation ===========================================
#    Executes simulation with specified test and random seed
#    Generates coverage metrics for line, condition, toggle, FSM, assertion, and branch
#=======================================================================================

./simv -l sim.log +ntb_random_seed=4380470 +UVM_TESTNAME=axi_wrap_transf_test \
        -cm line+cond+tgl+fsm+assert+branch
#---------------------------------------------------------------------------------------
