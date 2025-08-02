### VARIABLES ###
# Project Basename
PROJ_NAME=test
# Clock Frequency
F_CLK=12000000

# Verilog Source Files
SRC=$(wildcard *.v)
# Lattice Constraint Files
PCF=$(PROJ_NAME).pcf

# Synthesized Files
BLIF=$(PROJ_NAME).blif
# Place and Route Files
ASC=$(PROJ_NAME).asc
# Bitsream Files
BIN=$(PROJ_NAME).bin

# For iCE40-LP1k-CM36
NEXTPNR_FLAGS=-lp1k -package cm36
ARACHNEPNR_FLAGS=-d 1k -P cm36
ICETIME_FLAGS=-d lp1k


### TARGETS ###
.PHONY: flash clean
all: $(BIN)

# Create a testing binary with icarus verilog
$(PROJ_NAME): $(SRC)
	iverilog -o $(PROJ_NAME) $(SRC)

$(BLIF): $(SRC)
	yosys -p "synth_ice40 -blif $(BLIF)" $(SRC)

$(ASC): $(BLIF) $(PCF)
	arachne-pnr $(ARACHNEPNR_FLAGS) -p $(PCF) $(BLIF) -o $(ASC)

# Generate bitstream
$(BIN): $(ASC)
	icepack $(ASC) $(BIN)

# Upload the generated bitsream file to the board
flash: $(BIN)
	icesprog $(BIN)

# Remove all generated files
clean:
	rm -f $(PROJ_NAME) $(BLIF) $(ASC) $(BIN)
