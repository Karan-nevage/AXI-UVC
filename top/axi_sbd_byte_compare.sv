//========================================================================================================
// File: axi_sbd_byte_compare.sv
// Description: Defines the UVM scoreboard class for AXI protocol byte-level verification.
//              Performs byte-level comparison for write and read transactions.
//              Tracks matches and mismatches at the byte level.
//========================================================================================================
class axi_sbd extends uvm_scoreboard;
    uvm_analysis_imp#(axi_tx, axi_sbd) imp_master;
    axi_tx mst_tx, slv_tx;
    byte mem[int];
    `uvm_component_utils(axi_sbd)
    `NEW_COMP

    //----> Build Phase
    //      Allocates memory for the master analysis port
    function void build();
        imp_master = new("imp_master", this);
    endfunction

    //----> Write Function
    //      Processes write and read transactions for byte-level comparison
    //      Stores write data in memory and verifies read data against it
    function void write(axi_tx tx);
        if (tx.wr_rd == 1) begin
            for (int i = 0; i <= tx.burst_len; i++) begin
                mem[tx.addr+3] = tx.dataQ[i][31:24];
                mem[tx.addr+2] = tx.dataQ[i][23:16];
                mem[tx.addr+1] = tx.dataQ[i][15:08];
                mem[tx.addr+0] = tx.dataQ[i][07:00];
                tx.addr += 2**tx.burst_size;
            end
        end
        else begin
            for (int i = 0; i <= tx.burst_len; i++) begin
                if (mem[tx.addr+0] == tx.dataQ[i][31:24] &&
                    mem[tx.addr+1] == tx.dataQ[i][23:16] &&
                    mem[tx.addr+2] == tx.dataQ[i][15:08] &&
                    mem[tx.addr+3] == tx.dataQ[i][07:00])
                begin 
                    num_matches = num_matches + 4;
                end
                else begin 
                    num_missmatches += 4;
                end
                tx.addr += 2**tx.burst_size;
            end
        end
    endfunction

endclass
//========================================================================================================
