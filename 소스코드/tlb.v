`include "range.v"
`include "state.v"

module TLB 
#(
    parameter SADDR=32, // size of address
    parameter SPAGE=12, // size of page
    parameter NSET=8,   // set number
    parameter SPCID=12, // size of pcid
    parameter NWAY=8    // way number
)
(
    input clk,
    input shutdown,             // clear tlb
    input insert,               // forcibly insert PTE
    input  [SADDR-1:0] va,      // virtual address
    input  [SADDR-1:0] pa,      // physical address
    input  [SPCID-1:0] pcid,    // process-context identifier
    output reg [SADDR-1:0] ta,  // translated address
    output reg hit,
    output reg miss
);

function [6:0] new_plru(input [6:0] old_plru, input [6:0] mask, input [6:0] value);
    begin 
        new_plru = (old_plru & ~mask) | (mask & value); // Update the PLRU state
    end
endfunction 

`STATE

// Extracting local address, set, and tag from the virtual address
wire [SPAGE-1:0]                    local_addr      = va[SPAGE-1:0];
wire [$clog2(NSET)-1:0]             set             = va[SPAGE+$clog2(NSET)-1:SPAGE];
wire [SADDR-1-SPAGE-$clog2(NSET):0] tag             = va[SADDR-1:SPAGE+$clog2(NSET)];

reg [`STATE_R] state; // Register to store the current state of the FSM
reg [NWAY-2:0] plru [NSET-1:0];    // Array for storing PLRU state for each set
reg [SADDR-1:0] prev_addr = 0;     // Previous address
reg [SPCID-1:0] prev_pcid = 0;     // Previous PCID

// Array for storing TLB entries (valid bit, tag, PCID, physical address)
reg [SADDR-$clog2(NSET)-SPAGE+SPCID+SADDR-SPAGE:0] entries [NSET-1:0][NWAY-1:0];

// Initial block to reset PLRU and TLB entries
initial begin: init_plru_and_entries
    integer  w_ind, s_ind, a;
    state[`STATE_R] = state_waiting; // Initialize the state to waiting

    for (a = 0; a < NSET; a = a + 1)
        plru[a] = 0; // Initialize PLRU for each set
    
    for (s_ind = 0; s_ind < NSET; s_ind = s_ind + 1) begin
        for (w_ind = 0; w_ind < NWAY; w_ind = w_ind + 1) begin
            entries[s_ind][w_ind]`VALIDE_BIT    = 0; // Initialize valid bit
            entries[s_ind][w_ind]`TAG_RANGE     = 0; // Initialize tag
            entries[s_ind][w_ind]`PCID_RANGE    = 0; // Initialize PCID
            entries[s_ind][w_ind]`PA_RANGE      = 0; // Initialize physical address
        end
    end
end

/********************************************************************
                             STATE MACHINE
********************************************************************/
// Generate block to handle TLB shutdown and clear all entries
genvar s_ind;
generate
    for (s_ind = 0; s_ind < NSET; s_ind = s_ind + 1) begin: clear
        always @(posedge clk) begin: shutdown_stlb
            if (state == state_shutdown) begin: shutdown_tlb
                integer  w_ind;
                for (w_ind = 0; w_ind < NWAY; w_ind = w_ind + 1) begin
                    entries[s_ind][w_ind]`VALIDE_BIT    <= 0; // Clear valid bit
                    entries[s_ind][w_ind]`TAG_RANGE     <= 0; // Clear tag
                    entries[s_ind][w_ind]`PCID_RANGE    <= 0; // Clear PCID
                    entries[s_ind][w_ind]`PA_RANGE      <= 0; // Clear physical address
                end
            end
        end
    end
endgenerate 

// Main always block for state transitions
always @(posedge clk) begin
    // Check if a new request is made or shutdown/insert signals are asserted
    if (state != state_shutdown && ( prev_addr != va || pcid != prev_pcid)) begin
       state <= state_req; // Move to request state
       prev_addr <= va;    // Update previous address
       prev_pcid <= pcid;  // Update previous PCID
    end else if (shutdown != 0) begin
        state <= state_shutdown; // Move to shutdown state
    end else if (insert != 0) begin
        state <= state_insert; // Move to insert state
    end

    // State machine
    case (state)
        state_waiting: begin
            miss <= 0; // Reset miss signal
            hit  <= 0; // Reset hit signal
        end
        
        state_req: begin
            ta[SPAGE-1:0] <= local_addr; // Set the lower bits of the translated address
            hit <= 1'b1; // Default to a hit (this may be reset later if there's a miss)
            state <= state_waiting; // Return to waiting state

            // Check each way in the set for a tag and PCID match
            if(entries[set][0]`TAG_RANGE == tag && entries[set][0]`PCID_RANGE == pcid) begin
                plru[set] = new_plru(plru[set], 7'b0001011, 7'b0000000); // Update PLRU state
                ta[SADDR-1:SPAGE] <= entries[set][0]`PA_RANGE; // Set physical address

            end else if(entries[set][1]`TAG_RANGE == tag && entries[set][1]`PCID_RANGE == pcid) begin
                plru[set] = new_plru(plru[set], 7'b0001011, 7'b0001000); // Update PLRU state
                ta[SADDR-1:SPAGE] <= entries[set][1]`PA_RANGE;

            end else if(entries[set][2]`TAG_RANGE == tag && entries[set][2]`PCID_RANGE == pcid) begin
                plru[set] = new_plru(plru[set], 7'b0001011, 7'b0000010); // Update PLRU state
                ta[SADDR-1:SPAGE] <= entries[set][2]`PA_RANGE;

            end else if(entries[set][3]`TAG_RANGE == tag && entries[set][3]`PCID_RANGE == pcid) begin
                plru[set] = new_plru(plru[set], 7'b0010011, 7'b0010010); // Update PLRU state
                ta[SADDR-1:SPAGE] <= entries[set][3]`PA_RANGE;

            end else if(entries[set][4]`TAG_RANGE == tag && entries[set][4]`PCID_RANGE == pcid) begin
                plru[set] = new_plru(plru[set], 7'b0100101, 7'b0000001); // Update PLRU state
                ta[SADDR-1:SPAGE] <= entries[set][4]`PA_RANGE;

            end else if(entries[set][5]`TAG_RANGE == tag && entries[set][5]`PCID_RANGE == pcid) begin
                plru[set] = new_plru(plru[set], 7'b0100101, 7'b0100001); // Update PLRU state
                ta[SADDR-1:SPAGE] <= entries[set][5]`PA_RANGE;

            end else if(entries[set][6]`TAG_RANGE == tag && entries[set][6]`PCID_RANGE == pcid) begin
                plru[set] = new_plru(plru[set], 7'b1000101, 7'b0000101); // Update PLRU state
                ta[SADDR-1:SPAGE] <= entries[set][6]`PA_RANGE;

            end else if(entries[set][7]`TAG_RANGE == tag && entries[set][7]`PCID_RANGE == pcid) begin
                plru[set] = new_plru(plru[set], 7'b1000101, 7'b1000101); // Update PLRU state
                ta[SADDR-1:SPAGE] <= entries[set][7]`PA_RANGE;
            end else begin
                miss <= 1'b1; // Set miss signal if no match is found
                hit <= 1'b0;  // Reset hit signal
                state <= state_miss; // Move to miss state
            end
        // end state_req
        end
        
        state_miss: begin
            miss <= 1'b0; // Reset miss signal
            state <= state_waiting; // Return to waiting state
        end

        state_insert: begin
            // Insert the new entry based on PLRU state
            if (plru[set][0]) begin
                plru[set][0] = !plru[set][0];
                if (plru[set][1]) begin
                    plru[set][1] = !plru[set][1];
                    plru[set][3] = !plru[set][3];
                    
                    if (plru[set][3]) begin
                        entries[set][1]`TAG_RANGE  <= tag; // Update tag
                        entries[set][1]`PCID_RANGE <= pcid; // Update PCID
                        entries[set][1]`PA_RANGE   <= pa[SADDR-1:SPAGE]; // Update physical address
                    end
                    else begin
                        entries[set][0]`TAG_RANGE  <= tag;
                        entries[set][0]`PCID_RANGE <= pcid;
                        entries[set][0]`PA_RANGE   <= pa[SADDR-1:SPAGE];
                    end
                end else begin
                    plru[set][1] = !plru[set][1];
                    plru[set][4] = !plru[set][4];
                    
                    if (plru[set][4]) begin
                        entries[set][3]`TAG_RANGE  <= tag;
                        entries[set][3]`PCID_RANGE <= pcid;
                        entries[set][3]`PA_RANGE   <= pa[SADDR-1:SPAGE];
                    end
                    else begin
                        entries[set][2]`TAG_RANGE  <= tag;
                        entries[set][2]`PCID_RANGE <= pcid;
                        entries[set][2]`PA_RANGE   <= pa[SADDR-1:SPAGE];
                    end
                end
            end else begin
                plru[set][0] = !plru[set][0];
                if (plru[set][2]) begin
                    plru[set][2] = !plru[set][2];
                    plru[set][5] = !plru[set][5];

                    if (plru[set][5]) begin
                        entries[set][5]`TAG_RANGE  <= tag;
                        entries[set][5]`PCID_RANGE <= pcid;
                        entries[set][5]`PA_RANGE   <= pa[SADDR-1:SPAGE];
                    end
                    else begin
                        entries[set][4]`TAG_RANGE  <= tag;
                        entries[set][4]`PCID_RANGE <= pcid;
                        entries[set][4]`PA_RANGE   <= pa[SADDR-1:SPAGE];
                    end
                end else begin
                    plru[set][2] = !plru[set][2];
                    plru[set][6] = !plru[set][6];

                    if (plru[set][6]) begin
                        entries[set][7]`TAG_RANGE  <= tag;
                        entries[set][7]`PCID_RANGE <= pcid;
                        entries[set][7]`PA_RANGE   <= pa[SADDR-1:SPAGE];
                    end
                    else begin
                        entries[set][6]`TAG_RANGE  <= tag;
                        entries[set][6]`PCID_RANGE <= pcid;
                        entries[set][6]`PA_RANGE   <= pa[SADDR-1:SPAGE];
                    end
                end
            end
            state <= state_waiting; // Return to waiting state
        // end state_insert
        end

        state_shutdown: begin
            // another always block: line 66 handles the shutdown
            state <= state_waiting; // Return to waiting state after shutdown
        // end state_shutdown
        end
        default: ;
    endcase
end
endmodule
