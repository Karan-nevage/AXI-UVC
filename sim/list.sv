//=============================================================================================
// File: list.sv
// Description: Includes the UVM package and imports all its components.
//              Lists all project files for inclusion using a bottom-up approach.
//=============================================================================================

//----> Import UVM Package
//      Includes and imports the UVM package for verification
`include "uvm_pkg.sv"                      // Include UVM package
import uvm_pkg::*;                         // Import all UVM package symbols

//----> Include Project Files
//      Lists all necessary UVM component files in bottom-up order
`include "axi_config.sv"                   // Common configuration definitions
`include "axi_assertions.sv"               // Assertion-based verification module
`include "axi_tx.sv"                       // Transaction class for AXI transactions
`include "axi_intf.sv"                     // AXI interface definition
`include "axi_drv.sv"                      // Driver component for AXI master
`include "axi_rsp.sv"                      // Slave responder component
`include "axi_sqr.sv"                      // Sequencer typedef for AXI
`include "axi_mon.sv"                      // Monitor component for AXI
`include "axi_cov.sv"                      // Coverage component for AXI
//-------------------------------
`ifdef TX_COMPARE
`include "axi_sbd.sv"                      // Scoreboard for transaction-level comparison
`elsif BYTE_COMPARE
`include "axi_sbd_byte_compare.sv"         // Scoreboard for byte-level comparison
`endif
//-------------------------------
`include "axi_magent.sv"                   // Master agent component
`include "axi_sagent.sv"                   // Slave agent component
`include "axi_env.sv"                      // Environment component for AXI verification
`include "axi_seq_lib.sv"                  // Sequence library for AXI tests
`include "axi_test_lib.sv"                 // Test library for AXI test cases
`include "top.sv"                          // Top-level testbench module
//=============================================================================================
