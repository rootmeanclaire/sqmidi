#!/usr/bin/env python3
import numpy as np
from numpy.typing import NDArray

MIDI_A4 = 0x45
FREQ_A4 = 440

MIDI_MIN = 0x00
MIDI_MAX = 0x7F
MIDI_RANGE = MIDI_MAX - MIDI_MIN

F_CLK = int(12e6)


def midi_to_freq(midi: int) -> float:
	return FREQ_A4 * (2**((midi-MIDI_A4) / 12))

def midi_to_period(midi: int, clk_div: int) -> int:
	return round((F_CLK/clk_div) / midi_to_freq(midi))

def gen_lut(clk_div: int) -> NDArray|None:
	# +1 because range is inclusive
	lut = np.ndarray(shape=(MIDI_RANGE+1, 2), dtype=np.uint32)
	for i in range(0, MIDI_RANGE+1):
		midi = MIDI_MAX-i
		lut[i,0] = midi_to_period(midi, clk_div)
		lut[i,1] = midi
		# If there are overlapping LUT values, fail out
		if i > 0 and lut[i,0] == lut[i-1,0]:
			return None
	return lut

# Find the lowest required clock frequency
# More power efficient
# Should smooth over slight frequency differences
clk_div = 1
lut = gen_lut(clk_div)
while lut is not None:
	clk_div *= 2
	lut = gen_lut(clk_div)
# The while loop goes until a failure occurs, so we have to step back one
clk_div //= 2
# Regenerating is not too much computation and it's more readable than caching
lut = gen_lut(clk_div)

# Print the body of a Verilog case statement
print("/* START LUT */")
for row in lut:
	print(f"{row[0]}: midi <= {row[1]};")
print("/* END LUT */")

print(f"\nUsed clock divider of 1/{clk_div} with {F_CLK/1e6:g} MHz clock")
print(f"\tEffective frequency {F_CLK/clk_div/1e3:g} kHz")
max_period_nodiv = midi_to_period(MIDI_MIN, 1)
max_period = int(lut[-1,0])
tot_bits = max_period_nodiv.bit_length()
sig_bits = max_period.bit_length()
print(f"Need at least {tot_bits} total bits")
print(f"\tSignificant bits are stored in [{tot_bits-1}:{tot_bits-sig_bits+1}]")
print(f"\tLargest divided period is {max_period} = 0x{max_period:x}")
