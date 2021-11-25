module data_pipe(
	input [7:0] in,
	output reg [7:0] out,
	input clk
);

	always@(posedge clk)
		out <= in;


endmodule
