module program_sequencer(
	input clk, 
	input sync_reset,
	input [3:0] jmp_addr,
	input jmp,
	input jmp_nz,
	input dont_jmp,
	output reg [7:0] pm_addr,
	output wire [7:0] from_PS,
	output reg [7:0] pc
);
	
assign from_PS = 8'H00;
//assign from_PS = pc;

	
	
always @ (*)
	if (sync_reset == 1'b1)
		pm_addr = 8'H00;
	else if ((jmp == 1'b1) || ((jmp_nz == 1'b1) && (dont_jmp == 1'b0)))
		pm_addr = {jmp_addr, 4'H0};
	else
		pm_addr = pc + 8'H01;
		
		
always @ (posedge clk)
	pc <= pm_addr; 



endmodule 
