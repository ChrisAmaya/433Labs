module instruction_decoder(
input clk,
input sync_reset,
input [7:0] next_instr, 
input hold_out,
output reg jmp,
output reg jump_nz,
output reg [7:0] ir,
output wire [3:0] ir_nibble,
output reg i_sel,
output reg x_sel,
output reg y_sel,
output reg [3:0] source_sel,
output reg [8:0] reg_en,
output wire [7:0] from_ID,
output reg NOPC8, 
output reg NOPCF, 
output reg NOPD8, 
output reg NOPDF
);

assign from_ID = 8'H00; 
//assign from_ID = reg_en[7:0];


assign ir_nibble = ir[3:0];		
	
//------------------instruction register------------------------------------------------
always @(posedge clk)
	begin
		if(hold_out)
			ir <= 8'hC8;
		else
			ir <= next_instr;
	end
	
//---------------register_enable for x0------------------------------------------------
always @(*) 
	
	if (sync_reset == 1'b1) 
		reg_en[0] = 1'b1;
	else if ((ir[7] == 1'b0) && (ir[6:4] == 3'd0)) //load x0
		reg_en[0] = 1'b1; 
	else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'd0)) //move x0
		reg_en[0] = 1'b1;
	else 
		reg_en[0] = 1'b0; 
		
//------------- register_enable bit x1 --------------------------------------------------
always @(*) 
	
	if (sync_reset == 1'b1) 
		reg_en[1] = 1'b1;
	else if ((ir[7] == 1'b0) && (ir[6:4] == 3'd1)) //load x1
		reg_en[1] = 1'b1;
	else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'd1)) //move x1
		reg_en[1] = 1'b1;
	else 
		reg_en[1] = 1'b0;
	
//------------- register_enable bit y0 ---------------------------------------------------
always @(*)
	
	if (sync_reset == 1'b1) 
		reg_en[2] = 1'b1;
	else if ((ir[7] == 1'b0) && (ir[6:4] == 3'd2)) //load y0
		reg_en[2] = 1'b1;
	else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'd2)) //move y0
		reg_en[2] = 1'b1;
	else 
		reg_en[2] = 1'b0;
		
//------------- register_enable bit y1 ----------------------------------------------------
always @(*)
	
	if (sync_reset == 1'b1) 
		reg_en[3] = 1'b1;
	else if ((ir[7] == 1'b0) && (ir[6:4] == 3'd3)) //load y1
		reg_en[3] = 1'b1;
	else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'd3)) //move y1
		reg_en[3] = 1'b1;
	else 
		reg_en[3] = 1'b0;

//------------- register_enable bit o_reg --------------------------------------------------
always @(*)
	
	if (sync_reset == 1'b1)
		reg_en[8] = 1'b1;
	else if ((ir[7] == 1'b0) && (ir[6:4] == 3'd4)) //load o_reg
		reg_en[8] = 1'b1;
	else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'd4)) //move o_reg
		reg_en[8] = 1'b1;
	else 
		reg_en[8] = 1'b0;
//------------- register_enable bit r ------------------------------------------------------
always @(*)
	
	if (sync_reset == 1'b1) 
		reg_en[4] = 1'b1;
	else if (ir[7:5] == 3'b110) // ALU function
		reg_en[4] = 1'b1;
	else
		reg_en[4] = 1'b0; 

//------------- register_enable bit m -------------------------------------------------------
always @(*)
	
	if (sync_reset == 1'b1)  
		reg_en[5] = 1'b1;
	else if ((ir[7] == 1'b0) && (ir[6:4] == 3'd5)) //load m
		reg_en[5] = 1'b1;
	else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'd5)) // move m
		reg_en[5] = 1'b1;
	else
		reg_en[5] = 1'b0; 	
	
//------------- register_enable bit i -------------------------------------------------------
always @(*)
	
	if (sync_reset == 1'b1)
		reg_en[6] = 1'b1;
	else if (((ir[7] == 1'b0) && (ir[6:4] == 3'd6)) || ((ir[7] == 1'b0) && (ir[6:4] == 3'd7)))
		reg_en[6] = 1'b1;
	else if (((ir[7:6] == 2'b10) && (ir[5:3] == 3'd6)) || ((ir[7:6] == 2'b10) && (ir[2:0] == 3'd7)) || ((ir[7:6] == 2'b10) && (ir[5:3] == 3'd7)))
		reg_en[6] = 1'b1;
	else
		reg_en[6] = 1'b0;	
		
//------------- register_enable bit dm -------------------------------------------------------
always @(*)

	if (sync_reset == 1'b1) 
		reg_en[7] = 1'b1;
	else if ((ir[7] == 1'b0) && (ir[6:4] == 3'd7)) // load dm
		reg_en[7] = 1'b1;
	else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'd7)) // move dm
		reg_en[7] = 1'b1;
	else
		reg_en[7] = 1'b0; 
		
		
// -------------source selects---------------------------------------------------------------
always @(*)
	if (sync_reset == 1'b1)  // sync_reset case
		source_sel = 4'd10;	
	else if (ir[7] == 1'b0) // load case
		source_sel = 4'd8;
	else if ((ir[7:6] == 2'b10) && (ir[5:3] == ir[2:0]) && (ir[5:3] != 3'd4)) 	// move i_pins to reg
		source_sel = 4'd9; 		
	else if ((ir[7:6] == 2'b10) && (ir[5:3] == ir[2:0]) && (ir[5:3] == 3'd4)) // move r to o_reg
		source_sel = 4'd4; 			
	else if (ir[7:6] == 2'b10) 	// move case
		source_sel = {1'b0, ir[2:0]};
	else 
		source_sel = 4'd10; // should never reach this 

//---------------------i select---------------------------------------------------------------
always @(*)

	if ((sync_reset == 1'b1) | (ir[7:4] == 4'b0110) | (ir[7:3] == 5'b10110 ))
		i_sel = 1'b0;
	else
		i_sel = 1'b1;

//--------------------y select-----------------------------------------------------------------
always @(*)

	if (sync_reset == 1'b1)		
		y_sel = 1'b0;
	else 
		y_sel = ir[3];

//--------------------X select----------------------------------------------------------------
always @(*)

	if (sync_reset == 1'b1)		
		x_sel = 1'b0;
	else 
		x_sel = ir[4];
	
//-----------------conditional Jump------------------------------------------------------------
always @(*)
	if (sync_reset == 1'b1)
		jump_nz = 1'b0;
	else if (ir[7:4] == 4'b1111)
		jump_nz = 1'b1;
	else
		jump_nz = 1'b0;
		
//----------------unconditional Jump----------------------------------------------------------
always @(*)
	if (sync_reset == 1'b1)		
		jmp = 1'b0;
	else if (ir[7:4] == 4'b1110)
		jmp = 1'b1;
	else
		jmp = 1'b0;
		
//-----------------No opps----------------------------------------------------------
always @(*)
if (ir == 8'hC8)
	NOPC8 = 1'b1;
else
	NOPC8 = 1'b0;
	
always @(*)
if (ir == 8'hCF)
	NOPCF = 1'b1;
else
	NOPCF = 1'b0;
	
always @(*)
if (ir == 8'hD8)
	NOPD8 = 1'b1;
else
	NOPD8 = 1'b0;
	
always @(*)
if (ir == 8'hDF)
	NOPDF = 1'b1;
else
	NOPDF = 1'b0;
	
	

endmodule 