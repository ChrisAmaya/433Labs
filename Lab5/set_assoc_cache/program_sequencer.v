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
	output reg [0:0] cache_wrline,
	output reg [0:0] cache_rdline,
	output wire cache_rdentry,
	output wire cache_wrentry,
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
reg [4:0] tagID [0:1] [0:1];
reg valid [0:1] [0:1];
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

//--------------------------current entry logic-----------------------------
(* keep *)reg currdentry;

always @ (*) begin
	if(pm_addr[3] == 1'b0) begin
		if (tagID[0][0] == pm_addr[7:4])
			currdentry <= 1'b0;
		else
			currdentry <= 1'b1;
	end else begin
		if (tagID[0][0] == pm_addr[7:4])
			currdentry <= 1'b0;
		else
			currdentry <= 1'b1;
	end
end

//----------------------------last used logic-------------------------------
(* noprune *) reg lastused[0:1];

always @(posedge clk) begin
	if (reset_1shot) begin
		lastused[0] <= 1'b1;
	end else if ((pm_addr[3] == 1'b0) && (hold == 1'b0) && (start_hold == 1'b0)) begin
		lastused[0] <= currdentry;
	end else if ((pm_addr[3] == 1'b0) && (end_hold == 1'b1)) begin
		lastused[0] <= ~lastused[0];
	end else begin
		lastused[0] <= lastused[0];
	end
end

always @(posedge clk) begin
	if (reset_1shot) begin
		lastused[1] <= 1'b1;
	end else if ((pm_addr[3] == 1'b1) && (hold == 1'b0) && (start_hold == 1'b0)) begin
		lastused[1] <= currdentry;
	end else if ((pm_addr[3] == 1'b1) && (end_hold == 1'b1)) begin
		lastused[1] <= ~lastused[1];
	end else begin
		lastused[1] <= lastused[1];
	end
end

//------------------------------TagID logic---------------------------------
always @(posedge clk) begin
	if (reset_1shot) begin
		tagID[0][0] <= 4'd0;
		tagID[0][1] <= 4'd0;
		tagID[1][0] <= 4'd0;
		tagID[1][1] <= 4'd0;
	end else if (start_hold) begin
		tagID[pm_addr[3]][~lastused[pm_addr[3]]] <= pm_addr[7:4];
	end else begin
		tagID[0][0] <= tagID[0][0];
		tagID[0][1] <= tagID[0][1];
		tagID[1][0] <= tagID[1][0];
		tagID[1][1] <= tagID[1][1];
	end

end

//----------------------------Valid Logic-----------------------------------

always @(posedge clk) begin
	if (reset_1shot) begin
		valid[0][0] <= 1'b0;
		valid[0][1] <= 1'b0;
		valid[1][0] <= 1'b0;
		valid[1][1] <= 1'b0;
	end else if (end_hold) begin
		valid[pm_addr[3]][~lastused[pm_addr[3]]] <= 1'b1;
	end else begin
		valid[0][0] <= valid[0][0];
		valid[0][1] <= valid[0][1];
		valid[1][0] <= valid[1][0];
		valid[1][1] <= valid[1][1];
	end

end

//-----------------------------Cache Logic----------------------------------
always@(posedge clk) begin
	 cache_wroffset <= hold_count;
	 cache_rdoffset <= pm_addr[2:0];
	 cache_wrline <= pc[3:3];
	 cache_rdline <= pm_addr[3:3];
	 cache_wren <= hold;
end

assign cache_rdentry = currdentry;
assign cache_wrentry = ~lastused[pm_addr[3]];

//----------------------------Start_Hold Logic-------------------------------
always@(posedge clk) begin
	if (reset_1shot)
		start_hold <= 1'b1;
	else if (tagID[pm_addr[3]][currdentry] != pm_addr[7:4])
		start_hold <= 1'b1;
	else if ((valid[pm_addr[3]][currdentry] == 1'b0) && (hold == 1'b0))
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
		rom_address = {tagID[pc[3]][~lastused[pc[3]]], pc[3], hold_count + 3'd1};
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
