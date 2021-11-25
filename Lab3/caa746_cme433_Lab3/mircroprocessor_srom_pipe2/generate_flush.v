module generate_flush(
	input jump,
	input jump_nz,
	input dont_jump,
	output reg flush
);

	always@(jump || jump_nz)
		if (jump || (jump_nz && !dont_jump))
			flush = 1'b1;
		else
			flush = 1'b0;
	


endmodule

