package chip8

import "core:math/rand"
import rl "vendor:raylib"

GRAPHICS_WIDTH :: 64
GRAPHICS_HEIGHT :: 32

//odinfmt: disable
fonts := []u8 {
    0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
    0x20, 0x60, 0x20, 0x20, 0x70, // 1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
    0x90, 0x90, 0xF0, 0x10, 0x10, // 4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
    0xF0, 0x10, 0x20, 0x40, 0x40, // 7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
    0xF0, 0x90, 0xF0, 0x90, 0x90, // A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
    0xF0, 0x80, 0x80, 0x80, 0xF0, // C
    0xE0, 0x90, 0x90, 0x90, 0xE0, // D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
    0xF0, 0x80, 0xF0, 0x80, 0x80, // F
}
//odinfmt: enable


Interpreter :: struct {
	opcode:      u16, // current opcode
	memory:      [4096]u8, // memory
	V:           [16]u8, // registers
	I:           u16, // index register
	pc:          u16, // program counter
	gfx:         [GRAPHICS_WIDTH * GRAPHICS_HEIGHT]u8,
	delay_timer: u8,
	sound_timer: u8,
	stack:       [16]u16,
	sp:          u16,
	key:         [16]u8, // keypad input
}

new_interpreter :: proc() -> Interpreter {
	memory := [4096]u8{}
	for i in 0 ..< len(fonts) {
		memory[i] = fonts[i]
	}
	return Interpreter{pc = 0x200, opcode = 0, I = 0, sp = 0, memory = memory}
}

emulate_cycle :: proc(interpreter: ^Interpreter) {
	// Fetch
	// opcode are 2 bytes
	opcode := u16(interpreter.memory[interpreter.pc]) << 8 | u16(interpreter.memory[interpreter.pc + 1])
	interpreter.pc += 2

	// Decode
	decode_opcode(interpreter, opcode)
}

decode_opcode :: proc(interpreter: ^Interpreter, opcode: u16) {
	left_most_nibble := get_left_most_nibble(opcode)
	X := get_second_nibble(opcode)
	Y := get_third_nibble(opcode)
	NN := get_last_two_nibbles(opcode)
	NNN := get_last_three_nibbles(opcode)
	fourth_nibble := NN & 0x0F


	switch left_most_nibble {
	case 0x0:
		switch opcode {
		case 0x00E0:
			interpreter.gfx = [GRAPHICS_WIDTH * GRAPHICS_HEIGHT]u8{}
		case 0x00EE:
			// usually used to return from a subroutine that was called with 0x2NNN
			interpreter.sp -= 1
			interpreter.pc = interpreter.stack[interpreter.sp]
		}
	case 0x1:
		interpreter.pc = NNN
		break
	case 0x2:
		interpreter.stack[interpreter.sp] = interpreter.pc
		interpreter.sp += 1
		interpreter.pc = NNN
		break
	case 0x3:
		if u16(interpreter.V[X]) == NN {
			interpreter.pc += 2
		}
		break
	case 0x4:
		if u16(interpreter.V[X]) != NN {
			interpreter.pc += 2
		}
		break
	case 0x5:
		if interpreter.V[X] == interpreter.V[Y] {
			interpreter.pc += 2
		}
		break
	case 0x6:
		interpreter.V[X] = u8(NN)
		break
	case 0x7:
		interpreter.V[X] += u8(NN)
		break
	case 0x8:
		switch fourth_nibble {
		case 0x0:
			interpreter.V[X] = interpreter.V[Y]
		case 0x1:
			interpreter.V[X] = interpreter.V[X] | interpreter.V[Y]
		case 0x2:
			interpreter.V[X] = interpreter.V[X] & interpreter.V[Y]
		case 0x3:
			interpreter.V[X] ~= interpreter.V[Y]
		case 0x4:
			interpreter.V[X] += interpreter.V[Y]
			if interpreter.V[X] < interpreter.V[Y] {
				interpreter.V[0xF] = 0x01
			} else {
				interpreter.V[0xF] = 0x00
			}
		case 0x5:
			if interpreter.V[X] < interpreter.V[Y] {
				interpreter.V[0xF] = 0x00
			} else {
				interpreter.V[0xF] = 0x01
			}
			interpreter.V[X] -= interpreter.V[Y]
		case 0x6:
			interpreter.V[X] = interpreter.V[Y] >> 1
			interpreter.V[0xF] = interpreter.V[Y] & 0x01
		case 0x7:
			if interpreter.V[X] > interpreter.V[Y] {
				interpreter.V[0xF] = 0x00
			} else {
				interpreter.V[0xF] = 0x01
			}
			interpreter.V[X] = interpreter.V[Y] - interpreter.V[X]
		case 0xE:
			interpreter.V[X] = interpreter.V[Y] << 1
			interpreter.V[0xF] = interpreter.V[Y] >> 7
		}
	case 0x9:
		if interpreter.V[X] != interpreter.V[Y] {
			interpreter.pc += 2
		}
		break
	case 0xA:
		interpreter.I = NNN
		break
	case 0xB:
		interpreter.pc = u16(interpreter.V[0]) + NNN
	case 0xC:
		interpreter.V[X] = u8(rand.int_max(255)) & u8(NN)
	case 0xD:
		interpreter.V[0xF] = 0
		// sprites are N bytes tall and 8 pixels wide
		x := interpreter.V[X] % GRAPHICS_WIDTH
		y := interpreter.V[Y] % GRAPHICS_HEIGHT
		N := fourth_nibble
		for row in 0 ..< N {
			pixel_y := (y + u8(row)) % GRAPHICS_HEIGHT
			sprite_byte := interpreter.memory[interpreter.I + u16(row)]
			for col in 0 ..< 8 {
				pixel_x := (x + u8(col)) % GRAPHICS_WIDTH
				// we must cast to u16 to avoid overflow
				pixel_index := u16(pixel_y) * GRAPHICS_WIDTH + u16(pixel_x)
				pixel := (sprite_byte >> (7 - u8(col))) & 0x1
				if pixel == 1 && interpreter.gfx[pixel_index] == 1 {
					interpreter.V[0xF] = 1
				}
				interpreter.gfx[pixel_index] ~= pixel
			}
		}
	case 0xE:
	case 0xF:
	}
}

draw :: proc(interpreter: ^Interpreter) {
	rl.ClearBackground(rl.BLACK)

	for i in 0 ..< GRAPHICS_WIDTH * GRAPHICS_HEIGHT {
		if interpreter.gfx[i] == 1 {
			x := i % GRAPHICS_WIDTH
			y := i / GRAPHICS_WIDTH
			rl.DrawRectangle(i32(x * 16), i32(y * 16), 16, 16, rl.WHITE)
		}
	}
}
