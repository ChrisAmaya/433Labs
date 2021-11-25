`ifndef _TB_
`define _TB_


module testbench #(parameter bitsizeTB = 32) (intf i_intf);
	reg [31:0] failedcases, successCases, totalCases;
	reg [bitsizeTB-1:0] delayed_output;

	//----------Class for Randomizer---------
	class Packet #(int N = 32);
		rand bit [N  - 1:0] a_rand;
		rand bit [N  - 1:0] b_rand;
		constraint a_b_max {
			a_rand != b_rand;
		}
	endclass
		

	//-----------Constructor----------------
	Packet #(.N(bitsizeTB)) pkt;

	//------------Initializer----------------
	initial begin
		i_intf.a <= 32'd0;
		i_intf.b <= 32'd0;
		i_intf.cin <= 1'b0;
		failedcases <= 32'd0;
		successCases <= 32'd0;
		totalCases <= 32'd0;
		pkt = new();
		$display("------------------------------------------------");
		$display("[Testbench]: Start of testcase(s) at %0d", $time);
		end

	//-------------Randomizer-----------------
	always@(posedge i_intf.clk)
		begin
		pkt.randomize();
		//$display("Randomized a and b at time %0d", $time); //for debugging
		i_intf.a <= pkt.a_rand;
		i_intf.b <= pkt.b_rand;
		end

	//-----------Checking output---------------
	always@(posedge i_intf.clk)
		begin
		$display("---------");
		$display("%0d + %0d = %0d | Expected: %0d, at time %0d", i_intf.a, i_intf.b, i_intf.s, i_intf.a + i_intf.b,$time); // for debugging
		$display("Generate: %0d, Propagate: %0d", i_intf.G,i_intf.P); 
		if ((i_intf.a + i_intf.b) != i_intf.s)
			failedcases = failedcases + 1;
		else if ((i_intf.a + i_intf.b) == i_intf.s)
			successCases = successCases + 1;
		totalCases = totalCases + 1;
		end

	
	//----------------------Termination Section-----------------------
	initial begin
		#1000000 $finish;
	end

	final begin
		$display("[Testbench]: End of testcases(s) at %0d", $time);
		$display("Failed cases: %0d | Success cases: %0d | Total Cases: %0d", failedcases, successCases, totalCases);
		$display("--------------------------------------------------------");

	end 
	
endmodule

`endif
