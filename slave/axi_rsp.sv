//=============================================================================================
// File: axi_rsp.sv
// Description: Defines the UVM responder class for AXI protocol verification.
//              Handles slave responses for write and read transactions via the AXI interface.
//              Manages memory and address boundaries for WRAP transactions.
//=============================================================================================

class axi_rsp extends uvm_component;
    `uvm_component_utils(axi_rsp)          // Register with UVM factory
    `NEW_COMP                              // Constructor
    virtual axi_intf vif;                  // Virtual interface to connect to DUT
    byte mem[*];                           // Associative array for memory storage

    bit [`ADDR_WIDTH-1:0] wrap_upper_addr; // Upper address boundary for WRAP transactions
    bit [`ADDR_WIDTH-1:0] wrap_lower_addr; // Lower address boundary for WRAP transactions

    //----> Temporary Variables
    //      Store write and read address channel signals
    bit [`ADDR_WIDTH-1:0] awaddr_t;        // Temporary write address
    bit [3:0] awlen_t;                     // Temporary write burst length
    bit [2:0] awsize_t;                    // Temporary write burst size
    bit [1:0] awburst_t;                   // Temporary write burst type
    bit [`ADDR_WIDTH-1:0] araddr_t;        // Temporary read address
    bit [3:0] arlen_t;                     // Temporary read burst length
    bit [2:0] arsize_t;                    // Temporary read burst size
    bit [1:0] arburst_t;                   // Temporary read burst type
//=============================================================================================

    //----> Build Phase
    //      Retrieves the virtual interface from the resource database
    function void build();
        if (!uvm_resource_db#(virtual axi_intf)::read_by_name("GLOBAL", "PIF", vif, this)) begin
            `uvm_error("RESPONDER", "Unable to retrieve virtual interface")
        end
    endfunction

    //----> Run Phase
    //      Main loop for handling AXI slave responses
    // *Note: Write response (B-channel) and read response handshaking depend on write and read data channels
    task run();
        forever begin
            //----> Channel Handshaking
            @(vif.responder_cb);
            //----> Write Address Channel Handshaking
            vif.responder_cb.awready <= vif.responder_cb.awvalid;      
            if (vif.responder_cb.awvalid) begin
                awaddr_t  <= vif.responder_cb.awaddr; // Store write address
                awlen_t   <= vif.responder_cb.awlen;  // Store write burst length
                awsize_t  <= vif.responder_cb.awsize; // Store write burst size
                awburst_t <= vif.responder_cb.awburst;// Store write burst type
                
                //----> Calculate WRAP address boundaries
                wrap_lower_addr = awaddr_t - ((awaddr_t) % ((awlen_t + 1) * (2**awsize_t)));
                wrap_upper_addr = wrap_lower_addr + (((awlen_t + 1) * (2**awsize_t))-1);
                $display("LOWER ADDR %0h", wrap_lower_addr);  
                $display("UPPER ADDR %0h", wrap_upper_addr);  
            end

            //----> Write Data Channel Handshaking
            vif.responder_cb.wready <= vif.responder_cb.wvalid;      
            if (vif.responder_cb.wvalid) begin
                mem[awaddr_t+0] <= vif.responder_cb.wdata[07:00];  
                mem[awaddr_t+1] <= vif.responder_cb.wdata[15:08];  
                mem[awaddr_t+2] <= vif.responder_cb.wdata[23:16];  
                mem[awaddr_t+3] <= vif.responder_cb.wdata[31:24];  
                awaddr_t += 2**awsize_t;
                if ((awburst_t == WRAP) && (awaddr_t > wrap_upper_addr)) begin
                    awaddr_t = wrap_lower_addr;
                end
            end 
            if (vif.responder_cb.wvalid && vif.responder_cb.wlast) do_write_resp_phase(vif.responder_cb.awid);

            //----> Read Address Channel Handshaking
            vif.responder_cb.arready <= vif.responder_cb.arvalid;      
            if (vif.responder_cb.arvalid) begin
                araddr_t  <= vif.responder_cb.araddr;  // Store read address
                arlen_t   <= vif.responder_cb.arlen;   // Store read burst length
                arsize_t  <= vif.responder_cb.arsize;  // Store read burst size
                arburst_t <= vif.responder_cb.arburst; // Store read burst type
                
                //----> Calculate WRAP address boundaries
                wrap_lower_addr = araddr_t - ((araddr_t) % ((arlen_t + 1) * (2**arsize_t)));
                wrap_upper_addr = wrap_lower_addr + (((arlen_t + 1) * (2**arsize_t))-1);
                $display("LOWER ADDR %0h", wrap_lower_addr);  
                $display("UPPER ADDR %0h", wrap_upper_addr);  
            end
            if (vif.responder_cb.arvalid) do_read_data_phase(vif.responder_cb.arid, vif.responder_cb.arlen);
        end    
    endtask

//=============================================================================
//                          Response Methods
//=============================================================================
    //----> Write Response Phase Task
    //      Drives write response channel signals
    task do_write_resp_phase(bit[3:0] id);
        @(vif.responder_cb);
        vif.responder_cb.bvalid <= 1;
        vif.responder_cb.bresp  <= 2'b00;
        vif.responder_cb.bid    <= id;
        wait (vif.responder_cb.bready == 1'b1);
        vif.responder_cb.bvalid <= 0;
        vif.responder_cb.bresp  <= 2'b00;
        vif.responder_cb.bid    <= 0;
    endtask

    //----> Read Data Phase Task
    //      Drives read data and response channel signals
    task do_read_data_phase(bit[3:0] id, bit[3:0] arlen);
        for (int i = 0; i <= arlen; i++) begin
            @(vif.responder_cb);
            vif.responder_cb.rdata <= { mem[araddr_t+3],
                                        mem[araddr_t+2],
                                        mem[araddr_t+1],
                                        mem[araddr_t+0]     
                                      };
            vif.responder_cb.rresp  <= 2'b00;
            vif.responder_cb.rid    <= id;
            vif.responder_cb.rlast  <= (i == arlen) ? 1'b1 : 1'b0;
            vif.responder_cb.rvalid <= 1'b1;
            araddr_t += 2**arsize_t;
            wait (vif.responder_cb.rready == 1'b1);
        end
        //----> Deassert Signals
        @(vif.responder_cb);
        vif.responder_cb.rvalid <= 1'b0;
        vif.responder_cb.rid    <= 1'b0;
        vif.responder_cb.rdata  <= 0;
        vif.responder_cb.rresp  <= 2'b00;
        vif.responder_cb.rlast  <= 0;
    endtask
endclass
//=============================================================================================
