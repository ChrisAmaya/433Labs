module program_sequencer(
	input clk, 
	input sync_reset,
	input [3:0] jmp_addr,
	input jmp,
	input jmp_nz,
	input dont_jmp,
	output reg [7:0] pm_addr,
	output wire [7:0] from_PS,
	output reg [7:0] pc,
	output wire hold_out
);

reg start_hold;
integer hold_count;
reg end_hold;
reg hold;


//----------------------------Start_Hold Logic-------------------------------
always@(pc || pm_addr)
	if ((pc[7:5] == 3'b000) && (pm_addr[7:5] == 3'b000)) //when they are the same but all zeros so it would fail the logic check
		start_hold <= 0;
	else if ((pc[7:5] & pm_addr[7:5])) //when they are the same, set low
		start_hold <= 0;
	else
		begin
		start_hold <= 1; //they must be different 
		end
		
//-------------------------------Hold Logic----------------------------------
always@(*)
	if (sync_reset | end_hold)
		hold <= 0;
	else if (start_hold)
		hold <= 1;
	else 
		hold <= hold;


//-----------------------------Hold_count Logic----------------------------
always@(posedge clk)
	begin
		if (sync_reset)
			hold_count <= 0;
		else if(hold)
			hold_count <= hold_count + 1;
		else
			hold_count <= hold_count;
	end

//-------------------------------end_hold Logic----------------------------
always@(*)
	begin
		if(hold && (hold_count > 31))  
			begin
			end_hold <= 1'b1;
			end
		else 
			end_hold <= 1'b0;
	end

//----------------------------Hold_out Logic------------------------------------
assign hold_out = ((start_hold | hold) & !(end_hold));
	
assign from_PS = 8'H00;
//assign from_PS = pc;

	
	
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
