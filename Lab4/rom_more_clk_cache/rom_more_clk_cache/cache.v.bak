module cache(
		input clk,
		input [7:0] data,
		input [4:0] rdoffset,
		input [4:0] wroffset,
		input wren,
		output reg [7:0] q,
		output wire [255:0] read_q_tmp
);

wire [31:0] byteena_a;
wire [255:0] q_tmp;
integer temp; 

always @(wroffset)
	temp <= wroffset;


assign byteena_a = byteena_a | (temp);
assign read_q_tmp = q_tmp;

always@(*)
	begin
		case(rdoffset)
			5'd0: 	q = q_tmp[7:0];
			5'd1: 	q = q_tmp[15:8];
			5'd2: 	q = q_tmp[23:16];
			5'd3:		q = q_tmp[31:24];
			5'd4:		q = q_tmp[39:32];
			5'd5:		q = q_tmp[47:40];
			5'd6:		q = q_tmp[55:48];
			5'd7:		q = q_tmp[63:56];
			5'd8: 	q = q_tmp[71:64];
			5'd9:		q = q_tmp[79:72];
			5'd10:	q = q_tmp[87:80];
			5'd11:	q = q_tmp[95:88];
			5'd12:	q = q_tmp[103:96];
			5'd13:	q = q_tmp[111:104];
			5'd14:	q = q_tmp[119:112];
			5'd15:	q = q_tmp[127:120];
			5'd16:	q <= q_tmp[135:128];
			5'd17:	q <= q_tmp[143:136];
			5'd18:	q <= q_tmp[151:144];
			5'd19:	q <= q_tmp[159:152];
			5'd20:	q <= q_tmp[167:160];
			5'd21:	q <= q_tmp[175:168];
			5'd22:	q <= q_tmp[183:176];
			5'd23:	q <= q_tmp[191:184];
			5'd24:	q <= q_tmp[199:192];
			5'd25:	q <= q_tmp[207:200];
			5'd26:	q <= q_tmp[215:208];
			5'd27:	q <= q_tmp[223:216];
			5'd28:	q <= q_tmp[231:224];
			5'd29:	q <= q_tmp[239:232];
			5'd30:	q <= q_tmp[247:240];
			5'd31:	q <= q_tmp[255:248];
			default: q = 8'd0;
		endcase
	end


ram r(
	.byteena_a(byteena_a),
	.clock(~clk),
	.data({32{data}}),
	.rdaddress(1'b0),
	.wraddress(1'b0),
	.wren(wren),
	.q(q_tmp)
);



endmodule

