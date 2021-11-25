module microprocessor(
//General Output Wires
output wire [3:0] o_reg,

//General input wires
input clk,
input reset,
input wire [3:0] i_pins,

//integrating wires
output wire zero_flag,
output wire [7:0] pm_address,
output wire [7:0] pm_data,
output wire [8:0] reg_enables,

//Computation Unit Specific
output wire [7:0] from_CU,
output wire [3:0] x0,
output wire [3:0] x1,
output wire [3:0] y0,
output wire [3:0] y1,
output wire [3:0] m,
output wire [3:0] r, 
output wire [3:0] i,

//Instruction Decoder specific
output wire [7:0] ir,
output wire [7:0] from_ID,
output wire NOPC8,
output wire NOPCF,
output wire NOPD8,
output wire NOPDF,

//Program sequencer specific
output wire [7:0] pc,
output wire [7:0] from_PS,
output wire [1:0] pc_count,
output wire run,

output reg sync_reset
);

wire jump;
wire conditional_jump;
wire i_mux_select;
wire y_mux_select;
wire x_mux_select;
wire [3:0] LS_nibble_ir;
wire [3:0] source_select;
wire [7:0] dm;
wire [7:0] data_bus;
wire [7:0] cl1_out;
wire [7:0] cl2_out;

always@(posedge clk)
	sync_reset <= reset;


data_memory data_mem(
	.address(i),
	.data(data_bus),
	.clock(~clk),
	.wren(reg_enables[7]),
	.q(dm)
);
	

program_memory prog_memory(
	.address(pm_address),
	.clock(~clk),
	.q(pm_data)
	);
	
program_sequencer prog_sequencer (
	 .clk(clk),
	 .sync_reset(sync_reset),
	 .jmp_addr(LS_nibble_ir), 	
	 .jmp(jump),
	 .jmp_nz(conditional_jump),
	 .dont_jmp(zero_flag),
	 .pm_addr(pm_address),
	 .pc(pc), 					
	 .from_PS(from_PS),
	 .pc_count(pc_count),
	 .run(run)
	 );
	 
instruction_decoder inst_decoder( 
	  .clk(clk), 
	  .sync_reset(sync_reset),
	  .next_instr(pm_data),
	  .jmp(jump),
	  .jump_nz(conditional_jump),
	  .ir(ir), 
	  .ir_nibble(LS_nibble_ir),
	  .i_sel(i_mux_select),
	  .y_sel(y_mux_select),
	  .x_sel(x_mux_select),
	  .source_sel(source_select),
	  .reg_en(reg_enables),
	  .from_ID(from_ID),
	  .NOPC8(NOPC8),
	  .NOPCF(NOPCF),
	  .NOPD8(NOPD8),
	  .NOPDF(NOPDF),
	  .run(run)
	  );
		
computational_unit comp_unit(
	.clk(clk),
	.sync_reset(sync_reset),
	.nibble_ir(LS_nibble_ir),
	.i_sel(i_mux_select),
	.y_sel(y_mux_select),
	.x_sel(x_mux_select),
	.source_sel(source_select),
	.reg_en(reg_enables),
	.dm(dm[3:0]),
	.i_pins(i_pins),
	.i(i),
	.o_reg(o_reg),
	.data_bus(data_bus[3:0]),
	.r_eq_0(zero_flag),
	.from_CU(from_CU),
	.x0(x0),
	.x1(x1),
	.y0(y0),
	.y1(y1),
	.m(m),
	.r(r)
	
	);

endmodule

