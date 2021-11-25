`ifndef _RCA_
`define _RCA_


/*
//----------------------Quartus Version----------------------------
module rippleCarryAdder #(parameter bitsizeRCA = 32)
   (input [bitsizeRCA-1:0] a, 
	input [bitsizeRCA-1:0] b, 
	output reg [bitsizeRCA-1:0] s, 
	input cin, 
	output reg cout, 
	input clk);

	reg [bitsizeRCA-1:0] a_reg;
	reg [bitsizeRCA-1:0] b_reg;
	wire [bitsizeRCA-1:0] s_reg;
	reg cin_reg;
	reg cout_reg;

	initial begin
		//$display("This is where all the regs are initialized to zero %0d", $time); //for debugging
		a_reg <= 0;
		b_reg <= 0;
		cin_reg <= 0;
	end

	always @(posedge clk)
		begin
			//$display("This is where all the regs are given its values %0d", $time); //for debugging
			a_reg <= a;
			b_reg <= b;
			s <= s_reg;
			cin_reg <= cin;
			cout <= cout_reg;
		end
	
	wire [bitsizeRCA:0] carry;
	assign carry[0] = cin_reg;
	
	genvar i;
	

	generate
		for (i = 0; i < bitsizeRCA; i = i + 1) begin : RCA
			fulladder fa(a_reg[i],b_reg[i],s_reg[i],carry[i],carry[i+1]);
		end
	endgenerate 

	always@(*)
		begin
		//$display("this is where cout is assigned %0d", $time); for debugging
		cout_reg = carry[bitsizeRCA];
		end
endmodule

//-------------------full adder 1bit--------------------
module fulladder(input a, input b, output s, input cin, output cout);
	assign s = a^b^cin;
	assign cout = ((a^b)&cin) | (a&b);
endmodule
*/
//------------------------------------------------------------------------------------
//--------------------------Testbench Version----------------------------------------

module rippleCarryAdder #(parameter bitsizeRCA = 32)
   (input [bitsizeRCA-1:0] a, 
	input [bitsizeRCA-1:0] b, 
	output [bitsizeRCA-1:0] s, 
	input cin, 
	output cout, 
	input clk);

	wire [bitsizeRCA:0] carry;
	assign carry[0] = cin;
	
	genvar i;
	

	generate
		for (i = 0; i < bitsizeRCA; i = i + 1) begin : RCA
			fulladder fa(a[i],b[i],s[i],carry[i],carry[i+1]);
		end
	endgenerate 

	assign cout_reg = carry[bitsizeRCA];

endmodule

//-------------------full adder 1bit--------------------
module fulladder(input a, input b, output s, input cin, output cout);
	assign s = a^b^cin;
	assign cout = ((a^b)&cin) | (a&b);
endmodule



`endif 
