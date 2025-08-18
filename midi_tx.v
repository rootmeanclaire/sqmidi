module midi_tx #(
	// Zero-indexed channel to send MIDI output on
	// Must be 0 <= channel <= 15
	parameter MIDI_CHANNEL = 0;
	// Send "note on" messages with velocity zero instead of "note off" messages
	// This sacrifices note off velocity for bandwidth efficiency
	parameter VEL_0_OFF = 0;
) (
	input wire[6:0] note,
	input wire audio_note_on,
	input wire clk,
	output wire tx
);
	// 3 bytes are required to send a MIDI note message
	// Status, pitch, velocity
	// Status can be omitted if identical to the last MIDI message sent
	reg[1:0] msg_index = 0;
	// Triggers for MIDI "note on" and "note off" messages
	reg midi_note_on;
	reg midi_note_off;
	uart #(.BAUD(31250)) phy (
		.enable(1'b1),
		.clk(clk),
		.tx_input(note),
		.new_data(midi_note_on | midi_note_off),
		.tx_wire(tx),
		.ready(~busy) // TODO implement buffer
	);
endmodule
