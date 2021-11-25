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
	output reg [1:0] pc_count,
	output reg run
);
	
//------------------------Run Logic---------------------------------
always@(*)
	if (pc_count == 2'd2)
		run <= 1'b1;
	else
		run <= 1'b0;
	
//----------------------PC_Count Logic------------------------------
always@(posedge clk)
	if (sync_reset)
		pc_count <= 2'd0;
	else 
		pc_count <= pc_count + 2'd1;
	
	
//-------------------PS Output Assignments--------------------------
assign from_PS = 8'H00;
//assign from_PS = pc;

	
//---------------------PM Address Logic-----------------------------
always @ (posedge clk)
	if (sync_reset)
		pm_addr = 8'H00;
	else if (pc_count == 2'd3) //normal operation 
		begin
			if ((jmp == 1'b1) || ((jmp_nz == 1'b1) && (dont_jmp == 1'b0)))
				pm_addr <= {jmp_addr, 4'H0};
			else
				pm_addr <= pc + 8'H01;
		end
	else
		pm_addr = pc; //when pc_count is NOT 3 then pm address is equal to pc
	

//------------------------PC Logic----------------------------------
always @ (posedge clk)
	pc <= pm_addr; 



endmodule 
