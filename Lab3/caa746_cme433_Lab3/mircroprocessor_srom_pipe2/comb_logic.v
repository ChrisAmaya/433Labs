module comb_logic(input [7:0] info_In, output reg [7:0] info_Out);
	integer counter;
	
	always@(info_In)
		begin
		counter = 0;

		while (counter < 1000)
			begin
			counter = counter + 8'd1;
			end
		
		info_Out <= info_In;
	
		end
		
endmodule
