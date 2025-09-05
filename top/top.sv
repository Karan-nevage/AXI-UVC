//=============================================================================================
// Module: top
// Description: Top-level module for UVM-based verification of the AXI protocol.
//              Instantiates the DUT, AXI interface, assertions, and sets up clock and reset.
//              Configures the UVM environment and initiates the test.
//=============================================================================================
module top;
    //----> Signal Declarations
    //      Defines clock and reset signals for the testbench
    reg aclk;                               // Clock signal
    reg aresetn;                            // Active-low reset signal

    //----> Interface Instantiation
    //      Instantiates the AXI interface with clock and reset connections
    axi_intf pif(aclk, aresetn);            // Connect clock and reset to interface

    //----> Assertion Instantiation
    //      Instantiates the AXI assertion module using the interface handle
    axi_assertions axi_assertions_i(pif);   // Use axi_intf handle instead of port connections

    //=====================================================================
    //----> Clock Generation
    //      Generates a 10ns period clock (5ns high, 5ns low)
    initial begin
        aclk = 0;                           // Initialize clock
        forever #5 aclk = ~aclk;            // Toggle clock every 5 time units
    end

    //=====================================================================
    //----> Interface Registration
    //      Sets the AXI interface in the UVM resource database
    initial begin
        uvm_resource_db#(virtual axi_intf)::set("GLOBAL", "PIF", pif, null); 
    end

    //=====================================================================
    //----> Reset Generation
    //      Asserts reset for 2 clock cycles, then deasserts
    initial begin
        aresetn = 1;                        // Assert reset (active-high)
        repeat(2) @(posedge aclk);          // Hold for 2 clock cycles
        aresetn = 0;                        // Deassert reset
    end

    //=====================================================================
    //----> UVM Test Execution
    //      Initiates the specified UVM test
    initial begin
        run_test("axi_n_wr_rd_test");       // Run the multiple write/read test
    end
    
    //=====================================================================
    //----> Waveform Dumping
    //      Configures waveform dumping for simulation (Synopsys tools)
    //      Command to view in Verdi: verdi -ssf axi.fsdb &
    //      Reload waveform: Shift + L
    initial begin
        $display("Dumping vars.....");
        $fsdbDumpfile("axi_wave.fsdb");
        $fsdbDumpvars;
    end

endmodule
//=============================================================================================
