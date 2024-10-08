run:
	odin run ./src -out:chip-8

build:
	odin build ./src -out:chip-8

test-file: build
	./chip-8 ./roms/test_opcode.ch8

test:
	odin test ./tests -out:test-chip-8
	@rm test-chip-8
