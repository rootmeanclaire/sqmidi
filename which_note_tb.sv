`timescale 1ns / 1ps

// Note detector testbench
module which_note_tb #(
	parameter F_CLK = 12_000_000
);
	// Test Variables
	integer suite = 0;
	integer test = 0;

	// Geneate log file
	initial begin
		$dumpfile("which_note_tb.vcd");
		$dumpvars(0);
	end

	reg clk;
	reg reset;
	reg audio;
	wire[6:0] midi;
	reg[6:0] expected_midi;
	wire note_on;
	reg expected_note_on;

	which_note #(
		.F_CLK(F_CLK)
	) uut (
		.clk(clk),
		.reset(reset),
		.audio(audio),
		.midi(midi),
		.note_on(note_on)
	);

	initial begin
		clk = 0;
		audio = 0;
		forever begin
			clk = ~clk;
			#(1s / F_CLK / 2);
		end
	end

	initial begin
		suite++;
		test++;
		$write("=== TEST SUITE %0d: SINGLE NOTE ===\n", suite);
		$write("\tTest %0d.%0d: No Input...", suite, test);
		expected_midi = 'x;
		expected_note_on = 0;
		#10;
		if (note_on === expected_note_on) begin
			$write("Passed!\n");
		end else begin
			$write("Failed! (Expected note_on=%0d, Got %0d)\n", expected_note_on, note_on);
		end

		test++;
		$write("\tTest %0d.%0d: A440...", suite, test);
		expected_midi = 69;
		expected_note_on = 1;
		#10;
		// TODO: Oscillator
		if (midi === expected_midi) begin
			$write("Passed!\n");
		end else begin
			$write("Failed! (Expected midi=0x%0h, Got 0x%0h)\n", expected_midi, midi);
		end
		if (note_on === expected_note_on) begin
			$write("Passed!\n");
		end else begin
			$write("Failed! (Expected note_on=%0d, Got %0d)\n", expected_note_on, note_on);
		end

		$finish();
	end
endmodule