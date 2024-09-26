package tests

import chip8 "../src/chip8"
import "core:testing"

@(test)
decode_opcode_1NNN :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	chip8.decode_opcode(&interpreter, 0x1234)
	testing.expect(t, interpreter.pc == 0x234)
}
