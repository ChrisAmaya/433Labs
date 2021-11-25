module microprocessor(
//General Output Wires
output wire [3:0] o_reg,

//General input wires
input clk,
input reset,
input wire [3:0] i_pins,

//integrating wires
output wire zero_flag,
//output wire [7:0] pm_address,
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

output wire [7:0] rom_address,
output wire [4:0] wroffset,
output wire [4:0] rdoffset,
output wire wren,
output wire [7:0] cache_out,


//------------Debugging------------
output wire hold_on,
output wire start_hold,
output wire end_hold,
output wire hold_out,
output wire hold,
output wire [2:0] hold_count,
output wire sync_reset_1,
output wire reset_1shot
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
reg sync_reset;

always@(posedge clk)
	sync_reset <= reset;


cache_multi c(
	.clk(clk),
	.data(pm_data),
	.rdline(rdline),
	.rdoffset(rdoffset),
	.wrline(wrline),
	.wroffset(wroffset),
	.wren(wren),
	.q(cache_out)
);

data_memory data_mem(
	.address(i),
	.data(data_bus),
	.clock(~clk),
	.wren(reg_enables[7]),
	.q(dm)
);


program_memory prog_memory(
	.address(rom_address),
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
	 .from_PS(from_PS),
	 .pc(pc),
	 .hold_out(hold_out),

	 .cache_wroffset(wroffset),
	 .cache_rdoffset(rdoffset),
	 .cache_wrline(cache_wrline),
	 .cache_rdline(cache_rdline),
	 .cache_wren(wren),
	 .rom_address(rom_address),

	 .start_hold(start_hold),
	 .end_hold(end_hold),
	 .hold(hold),
	 .hold_count(hold_count),
	 .sync_reset_1(sync_reset_1),
	 .reset_1shot(show_reset_1shot)
	 );

instruction_decoder inst_decoder(
	  .clk(clk),
	  .sync_reset(sync_reset),
	  .next_instr(cache_out),
	  .hold_out(hold_out),
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
	  .NOPDF(NOPDF)

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
