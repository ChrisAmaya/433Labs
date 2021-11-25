`ifndef _DUT_T_
`define _DUT_T_

module dut_top #(parameter bitsizeDUTtop = 32)(interface i_intf);


	rippleCarryAdder #(.bitsizeRCA(bitsizeDUTtop)) dut(
		.clk(i_intf.clk),
		.a(i_intf.a),
		.b(i_intf.b),
		.s(i_intf.s),
		.cin(i_intf.cin),
		.cout(i_intf.cout)
		);

endmodule

`endif
