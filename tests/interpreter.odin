package tests

import chip8 "../src/chip8"
import "core:fmt"
import "core:math/rand"
import "core:testing"

@(test)
decode_opcode_00E0 :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	for i in 1 ..< len(interpreter.gfx) {
		interpreter.gfx[i] = 1
	}
	chip8.decode_opcode(&interpreter, 0x00E0)
	for i in 0 ..< len(interpreter.gfx) {
		if !testing.expect(t, interpreter.gfx[i] == 0) {
			break
		}
	}
}

@(test)
decode_opcode_00EE :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	interpreter.pc = 0x200
	interpreter.stack[0] = 0x100
	interpreter.sp = 1
	chip8.decode_opcode(&interpreter, 0x00EE)
	testing.expect(t, interpreter.pc == 0x100)
	testing.expect(t, interpreter.sp == 0)
}

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
	interpreter.pc = 0x200
	chip8.decode_opcode(&interpreter, 0x2555)
	// we push 0x200 to the stack
	testing.expect(t, interpreter.stack[0] == 0x200)
	testing.expect(t, interpreter.sp == 1)
	// 0x2NNN means we will call subroutine at address NNN
	// now pc will start reading from 0x555
	testing.expect(t, interpreter.pc == 0x555)
}

@(test)
decode_opcode_3XNN_skip :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	interpreter.pc = 0x200
	interpreter.V[0x5] = 0x55
	chip8.decode_opcode(&interpreter, 0x3555)
	// 0x3XNN means we will skip the next instruction if VX == NN
	// 5 == 5, so we will skip the next instruction
	testing.expect(t, interpreter.pc == 0x202)
}

@(test)
decode_opcode_3XNN_no_skip :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	interpreter.pc = 0x200
	interpreter.V[0x5] = 0x25
	chip8.decode_opcode(&interpreter, 0x3555)
	testing.expect(t, interpreter.pc == 0x200)
}

@(test)
decode_opcode_4XNN_skip :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	interpreter.pc = 0x200
	interpreter.V[0x5] = 0x25
	chip8.decode_opcode(&interpreter, 0x4555)
	testing.expect(t, interpreter.pc == 0x202)
}

@(test)
decode_opcode_4XNN_no_skip :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	interpreter.pc = 0x200
	interpreter.V[0x5] = 0x55
	chip8.decode_opcode(&interpreter, 0x4555)
	testing.expect(t, interpreter.pc == 0x200)
}

@(test)
decode_opcode_5XY0_skip :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	interpreter.pc = 0x200
	interpreter.V[0x5] = 0x55
	interpreter.V[0x6] = 0x55
	chip8.decode_opcode(&interpreter, 0x5560)
	testing.expect(t, interpreter.pc == 0x202)
}

@(test)
decode_opcode_5XY0_no_skip :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	interpreter.pc = 0x200
	interpreter.V[0x5] = 0x55
	interpreter.V[0x6] = 0x25
	chip8.decode_opcode(&interpreter, 0x5560)
	testing.expect(t, interpreter.pc == 0x200)
}

@(test)
decode_opcode_6XNN :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	interpreter.V[0x5] = 0xFF
	chip8.decode_opcode(&interpreter, 0x6555)
	testing.expect(t, interpreter.V[0x5] == 0x55)
}

@(test)
decode_opcode_7XNN :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	interpreter.V[0x5] = 0x50
	chip8.decode_opcode(&interpreter, 0x7555)
	testing.expect(t, interpreter.V[0x5] == 0xA5)
}

@(test)
decode_opcode_8XY0 :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	interpreter.V[0x5] = 0x50
	interpreter.V[0x6] = 0x60
	chip8.decode_opcode(&interpreter, 0x8560)
	testing.expect(t, interpreter.V[0x5] == 0x60)
}

@(test)
decode_opcode_8XY1 :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	interpreter.V[0x5] = 0x50
	interpreter.V[0x6] = 0x60
	chip8.decode_opcode(&interpreter, 0x8561)
	testing.expect(t, interpreter.V[0x5] == 0x70)
}

@(test)
decode_opcode_9XY0_skip :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	interpreter.pc = 0x200
	interpreter.V[0x5] = 0x50
	interpreter.V[0x6] = 0x20
	chip8.decode_opcode(&interpreter, 0x9560)
	// Skip if VX != VY
	testing.expect(t, interpreter.pc == 0x202)
}

@(test)
decode_opcode_9XY0_no_skip :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	interpreter.pc = 0x200
	interpreter.V[0x5] = 0x50
	interpreter.V[0x6] = 0x50
	chip8.decode_opcode(&interpreter, 0x9560)
	testing.expect(t, interpreter.pc == 0x200)
}

@(test)
decode_opcode_ANNN :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	chip8.decode_opcode(&interpreter, 0xA555)
	testing.expect(t, interpreter.I == 0x555)
}

@(test)
decode_opcode_BNNN :: proc(t: ^testing.T) {
	interpreter := chip8.new_interpreter()
	interpreter.V[0] = 0x50
	chip8.decode_opcode(&interpreter, 0xB555)
	testing.expect(t, interpreter.pc == 0x5A5)
}

@(test)
decode_opcode_CXNN :: proc(t: ^testing.T) {
	rand.reset(42)
	interpreter := chip8.new_interpreter()
	chip8.decode_opcode(&interpreter, 0xC555)
	testing.expect(t, interpreter.V[0x5] == 0x44)
}
