package tests

import chip8 "../src/chip8"
import "core:testing"

@(test)
decode_opcode_1NNN :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	chip8.decode_opcode(&interpreter, 0x1234)
	// 0x1NNN means we will jump to address NNN
	testing.expect(t, interpreter.pc == 0x234)
}

@(test)
decode_opcode_2NNN :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	interpreter.pc = 0x100
	chip8.decode_opcode(&interpreter, 0x2555)
	// we push 0x100 to the stack
	testing.expect(t, interpreter.stack[0] == 0x100)
	testing.expect(t, interpreter.sp == 1)
	// 0x2NNN means we will call subroutine at address NNN
	// now pc will start reading from 0x555
	testing.expect(t, interpreter.pc == 0x555)
}
