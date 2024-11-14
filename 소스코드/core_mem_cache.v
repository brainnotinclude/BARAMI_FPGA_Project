module core_mem_cache(
    input clk,
    input rst_n,
    // about i cache
    input [31:0] memory_in0,
    input [31:0] memory_in1,
    input memready, //store buffer mem ready signal
    
    output [1:0] evict_line0,
    output [1:0] evict_line1,
    output memory_read0,
    output memory_read1,
    output [31:0] mem_address,  //store buffer mem addr signal
    output [31:0] mem_data,      // store buffer mem data signal
    output mem_write_en
    
    );
  
  wire [31:0] instA;
  wire [31:0] instB;
  wire [31:0] d_cache_data;
  wire [31:0] d_cache_addr;
  wire [31:0] store_addr;
  wire [31:0] store_data;
  wire [64:0] completed_inst_0;
  wire [64:0] completed_inst_1;
  
    Dual_Cache_Subarray u_icache (
    .address0(pcF1),
    .address1(pcF2),
    .selected_data0(selected_data0),
    .selected_data1(selected_data1),
    .hit0(hit0),
    .hit1(hit1),
    .clk(clk),
    .rst_n(rst_n),
    .evict_line0(evict_line0),
    .evict_line1(evict_line1),
    .memory_data0(memory_data0),
    .memory_data1(memory_data1),
    .memory_in0(memory_in0),
    .memory_in1(memory_in1),
    .memory_read0(memory_read0),
    .memory_read1(memory_read1)
);

    d_cache u_dcache (
    .address(address),
    .write_data(d_cache_store_data),
    .read_enable(d_cache_store_addr),
    .write_enable(write_enable),
    .read_data(read_data),
    .hit(hit),
    .clk(clk),
    .rst_n(rst_n),
    .memory_read(memory_read),
    .memory_write(memory_write),
    .memory_data_in(memory_data_in),
    .memory_data_out(memory_data_out)
);

core_simple u_core(
    .clk(clk),
    .rst_n(rst_n),
    .instA(instA),
    .instB(instB),
    .store_finish(store_finish),
    .store_fin_addr(store_fin_addr),
    .completed_inst_0(completed_inst_0),
    .completed_inst_1(completed_inst_1),
    .pcF1(pcF1),
    .pcF2(pcF2),
    .load_we(load_we),
    .store_we(store_we)
);

load_store_controller u_load_store_controller(
    .clk(clk),
    .reset(rst_n),
    
    .store_we(store_we),
    .store_address(store_addr),
    .store_data(store_data),
    .store_ready(store_ready),
    .busy_store(busy_store),
    
    .load_we(load_we),
    .load_address(load_addr),
    .load_data(load_data),
    .busy_load(busy_load),
    .valid(valid),
    
    .store_buffer_address(store_buffer_address),
    .store_buffer_data(store_buffer_data),
    .store_buffer_write_en(store_buffer_write_en),
    .store_buffer_full(store_buffer_full),
    .store_buffer_empty(store_buffer_empty),
    
    .store_buffer_read_data(store_buffer_read_data),
    .store_buffer_read_valid(store_buffer_read_valid)
);

store u_store (
    .clk(clk),
    .rst_n(rst_n),
    .set_busy(set_busy),
    .store_addr(store_addr),
    .store_data(store_data),
    .store_done(store_done),
    .busy(busy_store)
);

load u_load (
    .clk(clk),
    .rst_n(rst_n),
    .set_busy(set_busy),
    .load_addr(load_addr),
    .data_ready(data_ready),
    .load_data(load_data),
    .valid(valid),
    .busy(busy_load)
);

memory_access_controller u_memory_access_controller (
    .clk(clk),
    .reset(rst_n),
    .tlb_hit(tlb_hit),
    .virtual_address(virtual_address),
    .page_table_access(page_table_access),
    .virtual_page_number(virtual_page_number),
    .page_table_frame(page_table_frame),
    .page_table_ready(page_table_ready),
    .tlb_we(tlb_we),
    .tlb_virtual_page(tlb_virtual_page),
    .tlb_physical_page(tlb_physical_page)
);

TLB u_TLB (
    .clk(clk),
    .reset(rst_n),
    .we(tlb_we),
    .virtual_page_number(virtual_page_number),
    .physical_page_number(physical_page_number),
    .dirty_in(dirty_in),
    .virtual_address(virtual_address),
    .tlb_hit(tlb_hit),
    .physical_address(physical_address)
);

store_buffer u_store_buffer (
    .clk(clk),
    .reset(reset),
    .store_we(store_buffer_write_en),
    .store_address(store_buffer_address),
    .store_data(store_buffer_data),
    .mem_ready(mem_ready),
    .mem_address(mem_address),
    .mem_data(mem_data),
    .mem_write_en(mem_write_en),
    .full(store_buffer_full),
    .empty(store_buffer_empty)
);


assign instA = (hit0 ? selected_data0 : memory_data0);
assign instB = (hit1 ? selected_data1 : memory_data1);
// assign load_addr  
assign store_addr = completed_inst_0[32:1];
assign store_data = completed_inst_0[64:33];

endmodule
