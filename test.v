`timescale 1ns / 1ps

module main(
	input wire clk,
	output reg led
);
	reg [24:0] divider;
	
	always @(posedge clk) begin
		divider = divider + 1;
	end
	always @(posedge divider[24]) begin
		led = !led;
	end
endmodule
