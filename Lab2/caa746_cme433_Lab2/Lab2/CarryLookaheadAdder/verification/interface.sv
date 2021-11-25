`ifndef _INTF_
`define _INTF_

interface intf #(parameter bitsizeIntf = 32)(input logic clk);

	logic [bitsizeIntf-1:0] a;
	logic [bitsizeIntf-1:0] b;
	logic [bitsizeIntf-1:0] s;
	logic [bitsizeIntf-1:0] G;
	logic [bitsizeIntf-1:0] P;
	logic cin;
	logic cout;

	modport dut(
		input a,
		input b,
		output s,
		input cin,
		output cout,
		output G,
		output P,
		input clk
		);

	modport tb(
		output a,
		output b,
		input s,
		output cin,
		input cout,
		input G,
		input P,
		input clk
		);

endinterface

`endif
