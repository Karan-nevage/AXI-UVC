//=============================================================================================
// File: axi_intf.sv
// Description: Defines the AXI interface for connecting the DUT to the UVM testbench.
//              Includes signal declarations and clocking blocks for driver, monitor, and responder.
//=============================================================================================

interface axi_intf(input logic aclk, aresetn);

    //----> Signal Declarations
    //====================< Write Address Channel >=====================
    bit awvalid;                            // Write address valid
    bit awready;                            // Write address ready
    bit [3:0] awid;                         // Write address ID
    bit [`ADDR_WIDTH-1:0] awaddr;           // Write address
    bit [3:0] awlen;                        // Write burst length
    bit [2:0] awsize;                       // Write burst size
    bit [1:0] awburst;                      // Write burst type

    //====================< Write Data Channel >=======================
    bit wvalid;                             // Write data valid
    bit wready;                             // Write data ready
    bit [3:0] wid;                          // Write data ID
    bit [`DATA_WIDTH-1:0] wdata;            // Write data
    bit [`STRB_WIDTH-1:0] wstrb;            // Write strobe
    bit wlast;                              // Write last transfer

    //====================< Write Response Channel >==================
    bit bvalid;                             // Write response valid
    bit bready;                             // Write response ready
    bit bid;                                // Write response ID
    bit bresp;                              // Write response status

    //====================< Read Address Channel >====================
    bit arvalid;                            // Read address valid
    bit arready;                            // Read address ready
    bit [3:0] arid;                         // Read address ID
    bit [`ADDR_WIDTH-1:0] araddr;           // Read address
    bit [3:0] arlen;                        // Read burst length
    bit [2:0] arsize;                       // Read burst size
    bit [1:0] arburst;                      // Read burst type
    
    //====================< Read Data Channel >=======================
    bit rvalid;                             // Read data valid
    bit rready;                             // Read data ready
    bit [3:0] rid;                          // Read data ID
    bit [`DATA_WIDTH-1:0] rdata;            // Read data
    bit rlast;                              // Read last transfer
    bit rresp;                              // Read response status
    
//=============================================================================
//                          Clocking Blocks
//=============================================================================
    //----> Driver Clocking Block
    //      Defines timing for driver signals
    clocking bfm_cb @(posedge aclk);
        default input #0 output #0;
        output awid, awaddr, awlen, awsize, awburst, awvalid;
        input aresetn, awready, wready;
        output wid, wdata, wstrb, wlast, wvalid;
        output bready;
        input bid, bresp, bvalid;
        output arid, araddr, arlen, arsize, arburst, arvalid;
        input arready;
        output rready;
        input rid, rdata, rlast, rvalid, rresp; 
    endclocking
//----------------------------------------------------------------
    //----> Monitor Clocking Block
    //      Defines timing for monitor signals
    clocking mon_cb @(posedge aclk);
        default input #1;
        input awid, awaddr, awlen, awsize, awburst, awvalid;
        input aresetn, awready, wready;
        input wid, wdata, wstrb, wlast, wvalid;
        input bready;
        input bid, bresp, bvalid;
        input arid, araddr, arlen, arsize, arburst, arvalid;
        input arready;
        input rready;
        input rid, rdata, rlast, rvalid, rresp; 
    endclocking
//----------------------------------------------------------------
    //----> Responder Clocking Block
    //      Defines timing for slave responder signals
    clocking responder_cb @(posedge aclk);
        default input #0 output #0;
        input awid, awaddr, awlen, awsize, awburst, awvalid, aresetn;
        output awready, wready;
        input wid, wdata, wstrb, wlast, wvalid;
        input bready;
        output bid, bresp, bvalid;
        input arid, araddr, arlen, arsize, arburst, arvalid;
        output arready;
        input rready;
        output rid, rdata, rlast, rvalid, rresp; 
    endclocking

endinterface
//=============================================================================================
