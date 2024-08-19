module TLB (
    input wire clk,
    input wire reset,
    input wire we,                          // Write enable signal
    input wire [19:0] virtual_page_number,  // 20-bit virtual page number
    input wire [19:0] physical_page_number, // 20-bit physical page number
    input wire dirty_in,                    // Dirty bit input
    input wire [31:0] virtual_address,      // 32-bit virtual address input
    output reg tlb_hit,                     // TLB hit output
    output reg [31:0] physical_address      // 32-bit physical address output
);

    // Arrays for TLB entry components
    reg [7:0] valid;                        // Valid bit array
    reg [7:0] dirty;                        // Dirty bit array
    reg [19:0] tag [7:0];                   // Tag array (virtual page number)
    reg [19:0] physical_page_number_array [7:0]; // Physical page number array

    integer i;
    reg [19:0] vp_number;  // Virtual page number extracted from virtual address
    reg [11:0] page_offset; // Page offset extracted from virtual address

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Invalidate all TLB entries on reset
            for (i = 0; i < 8; i = i + 1) begin
                valid[i] <= 0;
                dirty[i] <= 0;
                tag[i] <= 0;
                physical_page_number_array[i] <= 0;
            end
            tlb_hit <= 0;
            physical_address <= 32'b0;
        end else begin
            vp_number = virtual_address[31:12]; // Extract virtual page number
            page_offset = virtual_address[11:0]; // Extract page offset

            tlb_hit = 0;
            physical_address = 32'b0;

            // Search for a matching entry in the TLB
            for (i = 0; i < 8; i = i + 1) begin
                if (valid[i] && (tag[i] == vp_number)) begin
                    tlb_hit = 1;
                    physical_address = {physical_page_number_array[i], page_offset};
                    // Exit the loop by setting the loop variable to the end value
                    i = 8; 
                end
            end

            // On a TLB miss and write enable, update the TLB with a new entry
            if (we && !tlb_hit) begin
                for (i = 0; i < 8; i = i + 1) begin
                    if (!valid[i]) begin
                        valid[i] <= 1;
                        dirty[i] <= dirty_in;
                        tag[i] <= virtual_page_number;
                        physical_page_number_array[i] <= physical_page_number;
                        // Exit the loop by setting the loop variable to the end value
                        i = 8; 
                    end
                end
            end
        end
    end
endmodule
