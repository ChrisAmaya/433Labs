`timescale 1us /1ns

module cache_tb();

	//----------------inputs------------------------------ 
	reg clk;
	reg [7:0] data;
	reg [4:0] rdoffset;
	reg [4:0] wroffset;
	reg wren;

	//----------------outputs----------------------------- 
	wire [7:0] q;

	//-------------Instantiate----------------------------
	cache c(
		.clk(clk),
		.data(data),
		.rdoffset(rdoffset),
		.wroffset(wroffset),
		.wren(wren),
		.q(q)	
	);

	//------------------Initialization------------------
	initial #1000 $stop;

	initial begin
		clk = 1'b0;
		wren = 1'b1;
		data = 8'd0;
		rdoffset = 5'd0;
		wroffset = 5'd0;
	end

	//---------------Clock definition-------------------
	always #0.5 clk = ~clk;

	//---------------Wren definition-------------------
	always #900 wren = ~wren;

	//----------------data definition------------------
	always@(posedge clk)
		data = data + 8'd1;

	//------------------rdoffset-----------------------
	always@(posedge clk)
		begin
			rdoffset = rdoffset + 5'd1;
			wroffset = wroffset + 5'd1;
		end

	

endmodule
