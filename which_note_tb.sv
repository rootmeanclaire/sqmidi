`timescale 1ns / 10ps

// Note detector testbench
module which_note_tb #(
	parameter F_CLK = 12_000_000
);
	// Test Variables
	integer suite = 0;
	integer test = 0;
	reg[6:0] expected_midi;
	reg expected_note_on;

	// Geneate log file
	initial begin
		$dumpfile("which_note_tb.vcd");
		$dumpvars(0);
	end

	// Testbench I/O
	reg clk = 0;
	reg reset;
	wire audio;
	wire[6:0] midi;
	wire note_on;

	// System Clock
	initial begin
		$write("clock period is %0t\n", 1s / F_CLK / 2);
		forever begin
			clk = ~clk;
			#(1s / F_CLK / 2);
		end
	end

	// Audio Oscillators
	function real midi_to_freq(byte midi);
		return 440 * (2 ** ((midi-69) / 12.0));
	endfunction
	reg audio_a4 = 0;
	initial begin
		$write("A4 period is %0t\n", 1s / 440);
		forever begin
			audio_a4 = ~audio_a4;
			#(1s / 440);
		end
	end
	reg audio_e5 = 0;
	initial begin
		$write("E5 period is %0t\n", 1s / midi_to_freq(76));
		forever begin
			audio_e5 = ~audio_e5;
			#(1s / midi_to_freq(76));
		end
	end
	// Audio Mux
	reg[1:0] tone_select = 0;
	mux4 audio_mux (
		.a(1'b0),
		.b(audio_a4),
		.c(audio_e5),
		.d(audio_a4 | audio_e5),
		.select(tone_select),
		.out(audio)
	);
	
	// UUT
	which_note #(
		.F_CLK(F_CLK)
	) uut (
		.clk(clk),
		.reset(reset),
		.audio(audio),
		.midi(midi),
		.note_on(note_on)
	);

	// Test Body
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
		tone_select = 1;
		#20ms;
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