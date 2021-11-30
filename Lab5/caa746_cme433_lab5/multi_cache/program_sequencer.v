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

	output reg [2:0] cache_wroffset,
	output reg [2:0] cache_rdoffset,
	output reg [1:0] cache_wrline,
	output reg [1:0] cache_rdline,
	output reg cache_wren,
	output reg [7:0] rom_address,

	output reg start_hold,
	output reg end_hold,
	output reg hold,
	output reg [2:0] hold_count,
	output reg sync_reset_1,
	output reg reset_1shot,
	
	output reg [7:0] show_pm_addr
);
reg [2:0] tagID [3:0]; //an array of 4 3-bit tagID's
reg valid [3:0]; //an array of 4 1-bit valid bits
reg [7:0] pm_addr;
//------------------------------Assignments---------------------------------
assign from_PS = 8'H00;

always@(posedge clk) begin
 show_pm_addr <= pm_addr;
end
//assign from_PS = pc;

//---------------------------Sync_reset_1 Logic-----------------------------
always@(posedge clk)
	sync_reset_1 <= sync_reset;

//---------------------------reset_1shot Logic------------------------------
always@(posedge clk) begin
	if (sync_reset && !sync_reset_1)
		reset_1shot <= 1'b1;
	else
		reset_1shot <= 1'b0;
end

//------------------------------TagID logic---------------------------------
integer i;

always @(start_hold & end_hold) begin
	if (reset_1shot) begin
		for (i = 0; i < 4; i = i + 1) begin
			tagID[i] <= 3'd0;
		end
	end else if (start_hold) begin
		tagID[pm_addr[4:3]] <= pm_addr[7:5];
	end else begin
		for (i = 0; i < 4; i = i + 1) begin
			tagID[i] <= tagID[i];
		end
	end

end

//----------------------------Valid Logic-----------------------------------
integer ii;

always @(posedge start_hold & end_hold) begin
	if (reset_1shot) begin
		for (ii = 0; ii < 4; ii = ii + 1) begin
			valid[ii] <= 1'd0;
		end
	end else if (end_hold) begin
			valid[pm_addr[4:3]] <= 1'b1;
	end else begin
		for (ii = 0; ii < 4; ii = ii + 1) begin
			valid[ii] <= valid[ii];
		end
	end

end

//-----------------------------Cache Logic----------------------------------
always@(posedge clk) begin
	 cache_wroffset <= hold_count;
	 cache_rdoffset <= pm_addr[2:0];
	 cache_wrline <= pc[4:3];
	 cache_rdline <= pm_addr[4:3];
	 cache_wren <= hold;
end

//----------------------------Start_Hold Logic-------------------------------
always@(posedge clk) begin
	if (reset_1shot)
		start_hold <= 1'b1;
	else if (tagID[pm_addr[4:3]] != pm_addr[7:5])
		start_hold <= 1'b1;
	else if (valid[pm_addr[4:3]] == 1'b0)
		start_hold <= 1'b1;
	else
		start_hold <= 1'b0;
end


//-------------------------------Hold Logic----------------------------------
always@(posedge clk) begin
	if (end_hold)
		hold <= 0;
	else if (start_hold)
		hold <= 1;
	else
		hold <= hold;
end


//-----------------------------Hold_count Logic----------------------------
always@(posedge clk) begin
	if (reset_1shot)
		hold_count <= 3'd0;
	else if(hold)
		hold_count <= hold_count + 3'd1;
	else
		hold_count <= 3'd0;
end

//-------------------------------end_hold Logic----------------------------
always@(posedge clk) begin
	if((hold_count == 3'd7) && (hold == 1'b1))
		end_hold <= 1'b1;
	else
		end_hold <= 1'b0;
end

//----------------------------Hold_out Logic------------------------------------
assign hold_out = ((start_hold | hold) & !(end_hold));

//----------------------------ROM Address Logic---------------------------------
always@(*) begin
	if(reset_1shot)
		rom_address = 8'd0;
	else if (start_hold)
		rom_address = {pm_addr[7:3], 3'd0};
	else if (sync_reset)
		rom_address = {5'd0, hold_count + 3'd1};
	else
		rom_address = {tagID[pc[4:3]], pc[4:3], hold_count + 3'd1};
end
//----------------------------PM Address Logic----------------------------------
always @ (*) begin
	if (sync_reset == 1'b1)
		pm_addr = 8'H00;
	else if (hold) 
		pm_addr <= pm_addr;
	else if ((jmp == 1'b1) || ((jmp_nz == 1'b1) && (dont_jmp == 1'b0)))
		pm_addr = {jmp_addr, 4'H0};
	else
		pm_addr = pc + 8'H01;
end

always @(posedge clk)
	pc <= pm_addr;


endmodule
