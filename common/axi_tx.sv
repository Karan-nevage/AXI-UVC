//=============================================================================================
// File: axi_tx.sv
// Description: Defines the UVM transaction class for AXI protocol operations.
//              Supports burst transactions with constraints for write and read operations.
//              Includes fields for address, data, burst parameters, and responses.
// *NOTE: AXI supports burst-type transactions requiring multiple data transfers.
//=============================================================================================

//----> Burst Type Declaration
//      Enumerates supported AXI burst types
typedef enum {FIXED = 0, INCR, WRAP, RSVD_BT} burst_type_t;
//=============================================================================================

class axi_tx extends uvm_sequence_item;

    //----> Transaction Fields
    //      Randomizable fields for AXI transaction properties
    rand bit                    wr_rd;          // Write (1) or read (0) indicator
    rand bit [3:0]              tx_id;          // Transaction ID (awid, wid, bid, arid, rid)
    rand bit [`ADDR_WIDTH-1:0]  addr;           // Address (awaddr, araddr)
    rand bit [`DATA_WIDTH-1:0]  dataQ[$];       // Data queue for burst transfers
    rand bit [3:0]              burst_len;      // Burst length
    rand bit [2:0]              burst_size;     // Burst size
    rand burst_type_t           burst_type;     // Burst type (FIXED, INCR, WRAP)
    rand bit [1:0]              respQ[$];       // Response queue
    rand bit [`STRB_WIDTH-1:0]  strbQ[$];       // Strobe queue for write transactions

    //----> Register Fields with UVM Factory
    `uvm_object_utils_begin(axi_tx)
        `uvm_field_int(tx_id, UVM_ALL_ON);          
        `uvm_field_int(addr, UVM_ALL_ON);
        `uvm_field_queue_int(dataQ, UVM_ALL_ON);
        `uvm_field_int(burst_len, UVM_ALL_ON);
        `uvm_field_int(burst_size, UVM_ALL_ON);
        `uvm_field_enum(burst_type_t, burst_type, UVM_ALL_ON);
        `uvm_field_queue_int(respQ, UVM_ALL_ON);
        `uvm_field_queue_int(strbQ, UVM_ALL_ON);
        `uvm_field_int(wr_rd, UVM_ALL_ON);  
    `uvm_object_utils_end

    //===============================< Constraints >=====================================
    
    //----> Data Queue Size Constraint
    //      Ensures data queue size matches burst length + 1 for writes, zero for reads
    constraint data_queue_cons {
        (wr_rd == 1) -> dataQ.size() == burst_len + 1;
        (wr_rd == 0) -> dataQ.size() == 0;
    }

    //----> Strobe Queue Size Constraint
    //      Ensures strobe queue size matches burst length + 1 for writes, zero for reads
    constraint strb_queue_cons {
        (wr_rd == 1) -> strbQ.size() == burst_len + 1;
        (wr_rd == 0) -> strbQ.size() == 0;
    }

    //----> Strobe Value Constraint
    //      Sets default strobe value to 4'hF for write transactions
    constraint strb_val_cons {
        foreach (strbQ[i]) {
            soft strbQ[i] == 4'hF;
        }
    }

    //----> WRAP Transaction Constraint
    //      Ensures burst length is a power of 2 (up to 16) and address is aligned for WRAP
    constraint wrap_cons {
        burst_type == WRAP -> burst_len inside {1, 3, 7, 15};
        burst_type == WRAP -> addr % (2**burst_size) == 0;
    }

    //----> Burst Type Constraint
    //      Prevents reserved burst type and sets default values for burst size and type
    constraint burst_type_cons {
        burst_type != RSVD_BT;
        soft burst_size == 2;       // Default burst size is 2
        soft burst_type == INCR;    // Default burst type is INCR
    }
    
    //----> Burst Size Constraint
    //      Limits burst size to less than 3
    constraint burst_size_cons {
        burst_size < 3;
    }

    //==============================================================================
    //----> Constructor
    //      Initializes the transaction object
    function new(string name="");
        super.new(name);                  // Call parent constructor
    endfunction
  
endclass
//=============================================================================================
