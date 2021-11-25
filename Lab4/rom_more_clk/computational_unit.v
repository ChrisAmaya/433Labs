module computational_unit(
input  wire       clk,           
input  wire       sync_reset,    
									 
input  wire [3:0] nibble_ir,     // 4 bits, input
input  wire       i_sel,         // 1 bit, input
input  wire       y_sel,         // 1 bit, input
input  wire       x_sel,         // 1 bit, input
input  wire [3:0] source_sel,    // 4 bits, input
input  wire [8:0] reg_en,        // 9 bits, input
input  wire [3:0] dm,            // 4 bits, input
input  wire [3:0] i_pins,        // 4 bits, input 
									 
output reg  [3:0] i,             // 4 bits, output  
output reg  [3:0] o_reg,         // 4 bits, output  
output reg  [3:0] data_bus,      // 4 bits, output
output reg       r_eq_0,        // 1 bit, output


output wire [7:0] from_CU,
output reg  [3:0] x0,
output reg  [3:0] x1,
output reg  [3:0] y0,
output reg  [3:0] y1,
output reg  [3:0] m,
output reg  [3:0] r
);


reg [3:0] y;
reg [3:0] x;
reg [3:0] alu_out;
reg [7:0] alu_out_temp;


assign from_CU = 8'H00;
// assign from_CU = {x1, x0};


//---------------loading data_bus--------------------

always @(*)
	if (source_sel == 4'd0) 
		data_bus = x0;
	else if (source_sel == 4'd1)
		data_bus = x1;
	else if (source_sel == 4'd2)
		data_bus = y0;
	else if (source_sel == 4'd3)
		data_bus = y1;
	else if (source_sel == 4'd4)
		data_bus = r;
	else if (source_sel == 4'd5)
		data_bus = m;
	else if (source_sel == 4'd6)
		data_bus = i;
	else if (source_sel == 4'd7)
		data_bus = dm;
	else if (source_sel == 4'd8)
		data_bus = nibble_ir; 
	else if (source_sel == 4'd9)
		data_bus = i_pins;
	else
		data_bus = 4'd0;
		
//--------------register x0--------------------

always @(posedge clk)
	if (reg_en[0] == 1'b1) 
		x0 <= data_bus; 
		
	 
//--------------register x1--------------------

always @(posedge clk)
	if (reg_en[1] == 1'b1)
		x1 <= data_bus;

		
//--------------register y0--------------------

always @(posedge clk)
	if (reg_en[2] == 1'b1) 
		y0 <= data_bus; 
			
//--------------register y1--------------------

always @(posedge clk)
	if (reg_en[3] == 1'b1)
		y1 <= data_bus;
		
	
//--------------register m--------------------	
always @(posedge clk)
	if (reg_en[5] == 1'b1)
		m <= data_bus;	

//--------------register i--------------------
always @(posedge clk)
	if ((reg_en[6] == 1'b1) && (i_sel == 1'b1)) //increment 
		i <= i + m;
	else if ((reg_en[6] == 1'b1) && (i_sel == 1'b0))
		i <= data_bus;
	else 
		i <= i;

//--------------register o_reg--------------------
always @(posedge clk)
	if (reg_en[8] == 1'b1)
		o_reg <= data_bus;
				
		
//--------------y select for ALU--------------------
		
always @(*)
	if (y_sel == 1'b0)
		y = y0;
	else 
		y = y1;
		
//--------------x select for ALU--------------------
		
always @(*)
	if (x_sel == 1'b0)
		x = x0;
	else 
		x = x1;
//-----------------------------------------------
//-----------------ALU BLOCK--------------------- 
//-----------------------------------------------
		


//---------------alu_out------------------------
always @(*)
		if (sync_reset == 1'b1)
			alu_out = 4'H0;
		else if ((nibble_ir[3] == 1'b0) && (nibble_ir[2:0] == 3'b000))
			alu_out = -x; 
		else if (nibble_ir[2:0] == 3'b001)
			alu_out = x - y;
		else if (nibble_ir[2:0] == 3'b010)
			alu_out = x + y;
		else if (nibble_ir[2:0] == 3'b101)
			alu_out = x ^ y;
		else if (nibble_ir[2:0] == 3'b110)
			alu_out = x & y;
		else if ((nibble_ir[3] == 1'b0) && (nibble_ir[2:0] == 3'b111))
			alu_out = ~x;
		else 
			alu_out = r;

always @(*)
	if ((nibble_ir[2:0] == 3'b011) | (nibble_ir[2:0] == 3'b100))
			alu_out_temp <= x * y;
			
//---------------register zero_flag---------------------
always @(posedge clk)
	if (sync_reset == 1'b1)
		r_eq_0 <= 1'b1;
	else if ((reg_en[4] == 1'b1) && (alu_out == 4'H0))
		r_eq_0 <= 1'b1;
	else if ((reg_en[4] == 1'b1) && (alu_out != 4'H0))
		r_eq_0 <= 1'b0;
	else 
		r_eq_0 <= r_eq_0;

//---------------register r----------------------------
always @(posedge clk)
	if ((reg_en[4] == 1'b1) && (nibble_ir[2:0] == 3'b011))// special case when alu_out_temp is used as output
		r <= alu_out_temp[7:4];
	else if ((reg_en[4] == 1'b1) && (nibble_ir[2:0] == 3'b100))// special case when alu_out_temp is used as output
		r <= alu_out_temp[3:0];
	else if (reg_en[4] == 1'b1)
		r <= alu_out; 
	else
		r <= r;
		
endmodule
