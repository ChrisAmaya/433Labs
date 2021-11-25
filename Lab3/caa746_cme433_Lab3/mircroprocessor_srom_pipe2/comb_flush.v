module comb_flush(
	input flush,
	input [7:0] in,
	output reg [7:0] out
);

	always@(in)
		begin
			if(flush)
				out <= 8'HC8;
			else
				out <= in;
		end


endmodule

