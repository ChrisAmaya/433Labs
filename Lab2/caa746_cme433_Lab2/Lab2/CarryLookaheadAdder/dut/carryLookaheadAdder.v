`ifndef _CLA_
`define _CLA_


//-----------------------Testbench Verison------------------
module carryLookaheadAdder #(parameter bitsizeRCA = 32)
   (input [bitsizeRCA-1:0] a, 
	input [bitsizeRCA-1:0] b, 
	output [bitsizeRCA:0] s, 
	input cin, 
	output cout, 
	output [bitsizeRCA-1:0] G,
	output [bitsizeRCA-1:0] P,
	input clk);

	wire [bitsizeRCA:0] carry;
	wire [bitsizeRCA:0] sum;
	//----------------FullAdder Logic----------------------
	genvar i;
	generate
		for (i = 0; i < bitsizeRCA; i = i + 1) begin : CLA1
			fulladder fa(
				.a(a[i]),
				.b(b[i]),
				.s(sum[i]),
				.cin(carry[i]),
				.cout()
				);
		end
	endgenerate 
	
	//------------Generate/Propagate/Carry------------------
	genvar j;
	generate 
		for (j = 0; j < bitsizeRCA; j = j + 1) begin : CLA2
			assign G[j] = a[j] & b[j];
			assign P[j] = a[j] | b[j];
			assign carry[j+1] = G[j] | (P[j] & carry[j]); 
		end
	endgenerate
	
	//------------------assignments---------------------
	assign carry[0] = cin;
	assign s = {carry[bitsizeRCA], sum};

endmodule

/*
//----------------------Quartus Version------------------------------
module carryLookaheadAdder #(parameter bitsizeRCA = 32)
   (input [bitsizeRCA-1:0] a, 
	input [bitsizeRCA-1:0] b, 
	output [bitsizeRCA:0] s, 
	input cin, 
	output reg cout, 
	output reg [bitsizeRCA-1:0] G,
	output reg [bitsizeRCA-1:0] P,
	input clk);


	//----------------variable declarations---------------
	reg [bitsizeRCA-1:0] a_reg;
	reg [bitsizeRCA-1:0] b_reg;
	wire [bitsizeRCA-1:0] s_reg;
	reg cin_reg;
	reg cout_reg;
	wire [bitsizeRCA-1:0] G_reg;
	wire [bitsizeRCA-1:0] P_reg;
	
	wire [bitsizeRCA:0] carry;

	
	//-------------initialization------------------
	initial begin
		//$display("This is where all the regs are initialized to zero %0d", $time); // for debugging
		a_reg <= 0;
		b_reg <= 0;
		cin_reg <= 0;
	end
	//-------------Register Delcaration-------------
	always @(posedge clk)
		begin
			//$display("This is where all the regs are given its values %0d", $time); // for debugging
			a_reg <= a;
			b_reg <= b;
			//s <= s_reg;
			cin_reg <= cin;
			cout <= cout_reg;
			G <= G_reg;
			P <= P_reg;
		end
	//----------------FullAdder Logic----------------------
	genvar i;
	generate
		for (i = 0; i < bitsizeRCA; i = i + 1) begin : CLA1
			fulladder fa(
				.a(a_reg[i]),
				.b(b_reg[i]),
				.s(s_reg[i]),
				.cin(carry[i]),
				.cout()
				);
		end
	endgenerate 
	//------------Generate/Propagate/Carry------------------
	genvar j;
	generate 
		for (j = 0; j < bitsizeRCA; j = j + 1) begin : CLA2
			assign G_reg[j] = a_reg[j] & b_reg[j];
			assign P_reg[j] = a_reg[j] | b_reg[j];
			assign carry[j+1] = G_reg[j] | (P_reg[j] & carry[j]); 
		end
	endgenerate
	//------------------assignments---------------------
	assign carry[0] = cin_reg;
	assign s = {carry[bitsizeRCA], s_reg};

endmodule

*/
//-------------------full adder 1bit--------------------
module fulladder(input a, input b, output s, input cin, output cout);
	assign s = a^b^cin;
	assign cout = ((a^b)&cin) | (a&b);
endmodule

`endif 
