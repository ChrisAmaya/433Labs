
//---------------------Marco Guards------------------------
`ifndef _TB_TOP_
`define _TB_TOP_
//---------------------Includes-----------------------------
`include "interface.sv"
`include "testbench.sv"


module tbench_top;
	parameter bitsize = 32; //changes the size of the number of bits the adder is	

	//------------Clocking----------
	bit clk;
	always #10 clk=~clk;

	//------------Instances----------
	intf#(.bitsizeIntf(bitsize)) 		i_intf(clk);
	testbench#(.bitsizeTB(bitsize))		test(i_intf.tb);
	dut_top#(.bitsizeDUTtop(bitsize)) 	dut(i_intf.dut);


	//------------Wave Dump----------
	initial begin
		$dumpfile("dump.vcd"); $dumpvars;
	end

endmodule 

`endif
