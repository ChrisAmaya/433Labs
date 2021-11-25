module program_sequencer(
	input clk, 
	input sync_reset,
	input [3:0] jmp_addr,
	input jmp,
	input jmp_nz,
	input dont_jmp,
	output wire [7:0] from_PS,
	output reg [7:0] pc,
	output wire hold_out,
	
	output reg [4:0] cache_wroffset,
	output reg [4:0] cache_rdoffset,
	output reg cache_wren,
	output reg [7:0] rom_address,
	output reg [1:0] pc_count,
	output reg run,
	
	//for debugging
	output reg start_hold,
	output reg end_hold,
	output reg hold,
	output reg [6:0] hold_count,
	output reg sync_reset_1,
	output reg reset_1shot
);

reg [7:0] pm_addr;

//-----------------------------Run Logic----------------------------------
always@(posedge clk)
	if (pc_count == 2'd3)
		run <= 1'b1;
	else
		run <= 1'b0;

//---------------------------pc_count Logic--------------------------------
always@(posedge clk)
	if (reset_1shot)
		pc_count <= 2'd0;
	else if (hold)
		pc_count <= pc_count + 2'd1;
	else
		pc_count <= pc_count;

//-------------------------Debugging Assignments----------------------------
assign from_PS = 8'H00;
//assign from_PS = pc;

//---------------------------Sync_reset_1 Logic-----------------------------
always@(posedge clk)
	sync_reset_1 <= sync_reset;
	
//---------------------------reset_1shot Logic------------------------------
always@(posedge clk)
	if (sync_reset && !sync_reset_1)
		reset_1shot <= 1'b1;
	else
		reset_1shot <= 1'b0;

//-----------------------------Cache Logic----------------------------------
always@(posedge clk)
	begin
		cache_wroffset <= hold_count[6:2];
		cache_rdoffset <= pm_addr[4:0];
		if (hold & run)
			cache_wren <= 1'b1;
		else
			cache_wren <= 1'b0;
		
	end

//----------------------------Start_Hold Logic-------------------------------
always@(posedge clk)
	if (reset_1shot)
		start_hold <= 1'b1;
	else if (pc[7:5] != pm_addr[7:5])
		start_hold <= 1'b1;
	else 
		start_hold <= 1'b0;
	
		
//-------------------------------Hold Logic----------------------------------
always@(posedge clk)
	if (end_hold)
		hold <= 0;
	else if (start_hold)
		hold <= 1;
	else 
		hold <= hold;


//-----------------------------Hold_count Logic----------------------------
always@(posedge clk)
	begin
		if (reset_1shot)
			hold_count <= 7'd0;
		else if(hold)
			hold_count <= hold_count + 7'd1;
		else
			hold_count <= hold_count;
	end

//-------------------------------end_hold Logic----------------------------
always@(posedge clk)
	begin
		if((hold_count == 7'd127) && (hold == 1'b1))
			end_hold <= 1'b1;
		else 
			end_hold <= 1'b0;
	end

//----------------------------Hold_out Logic------------------------------------
assign hold_out = ((start_hold | hold) & !(end_hold));
	
//----------------------------ROM Address Logic---------------------------------
always@(*)
	if(reset_1shot)
		rom_address = 8'd0;
	else if (sync_reset)
		rom_address = {3'd0, hold_count[6:2]};
	else
		rom_address = {pc[7:5], hold_count[6:2]};
	
//----------------------------PM Address Logic----------------------------------
always @ (*)
	if (sync_reset == 1'b1)
		pm_addr = 8'H00;
	else if (hold) //-------------------Holding
		pm_addr <= pm_addr;
	else if ((jmp == 1'b1) || ((jmp_nz == 1'b1) && (dont_jmp == 1'b0)))
		pm_addr = {jmp_addr, 4'H0};
	else
		pm_addr = pc + 8'H01;
		

always @(posedge clk)
	pc <= pm_addr;


endmodule 
