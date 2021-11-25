`timescale 1ns/1ps

module parity_conventional_tb();

reg [6:0] D;
wire F;

initial 
#150 $stop;

initial 
D = 7'b0000001;

always begin
	#10 D = D + 1;
end

parity_conventional p_c_1(
			.D(D),
			.F(F)
			);
endmodule  