module mux4 (
	input wire a,
	input wire b,
	input wire c,
	input wire d,
	input wire[1:0] select,
	output reg out
);
	always @(a, b, c, d, select) begin
		case (select)
			2'b00: out <= a;
			2'b01: out <= b;
			2'b10: out <= c;
			2'b11: out <= d;
			default: out <= 1'bz;
		endcase
	end
endmodule
