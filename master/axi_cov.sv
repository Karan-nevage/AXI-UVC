//=============================================================================================
// File: axi_cov.sv
// Description: Defines the UVM coverage subscriber for collecting AXI functional coverage.
//              Samples address, write/read control, burst length, size, and type from transactions.
//              Access coverage in Verdi using: verdi -cov -covdir simv.vdb &
//=============================================================================================

class axi_cov extends uvm_subscriber#(axi_tx);
    axi_tx tx;                             // Transaction instance for coverage sampling
    `uvm_component_utils(axi_cov)          // Register with UVM factory
    
    //----> Constructor
    //      Initializes the component and creates the covergroup
    function new(string name="", uvm_component parent); 
        super.new(name, parent);
        axi_cg = new();
    endfunction

    //----> Covergroup for AXI Transactions
    //      Defines coverage points for AXI transaction properties
    covergroup axi_cg;
        //----> Address Coverpoint
        //      Automatically bins address values (max 4 bins)
        ADDR_CP : coverpoint tx.addr {
            option.auto_bin_max = 4;      
        }

        //----> Write/Read Control Coverpoint
        //      Bins for write and read operations
        WR_RD_CP : coverpoint tx.wr_rd {
            bins WRITE = {1'b1};          // Bin for write operations
            bins READ = {1'b0};           // Bin for read operations
        }

        //----> Burst Length Coverpoint
        //      Automatically bins burst length values (max 8 bins)
        BURST_LEN_CP : coverpoint tx.burst_len {
            option.auto_bin_max = 8;
        }
    
        //----> Burst Size Coverpoint
        //      Bins for specific burst size values
        BURST_SIZE_CP : coverpoint tx.burst_size {
            bins BURST_SIZE_1 = {3'b000};                   
            bins BURST_SIZE_2 = {3'b001};                   
            bins BURST_SIZE_4 = {3'b010};                   
        } 

        //----> Burst Type Coverpoint
        //      Bins for supported burst types, illegal bin for reserved type
        BURST_TYPE_CP : coverpoint tx.burst_type {
            bins FIXD_BURST = {2'b00};                   
            bins INCR_BURST = {2'b01};                   
            bins WRAP_BURST = {2'b10};                   
            illegal_bins RSVD_BURST = {2'b11};                   
        }

        //----> Cross Coverage
        //      Crosses address and write/read control, burst type and write/read control
        ADDR_X_WR_RD_CP : cross ADDR_CP, WR_RD_CP;
        BURST_TYPE_X_WR_RD_CP : cross BURST_TYPE_CP, WR_RD_CP;

    endgroup

    //----> Write Method
    //      Samples coverage for the received transaction
    function void write(axi_tx t);
        $cast(tx, t);                     // Cast input transaction to local tx
        axi_cg.sample();                  // Sample covergroup
    endfunction
  
endclass
//=============================================================================================
