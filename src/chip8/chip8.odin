package chip8


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
	left_most_nibble := get_left_most_nibble(opcode)

	// Decode
	decode_opcode(interpreter, opcode)

}

decode_opcode :: proc(interpreter: ^Interpreter, opcode: u16) {
	left_most_nibble := get_left_most_nibble(opcode)
	nn := get_last_two_nibbles(opcode)
	nnn := get_last_three_nibbles(opcode)

	switch left_most_nibble {
	case 0x0:
	case 0x1:
		interpreter.pc = nnn
		break
	case 0x2:
		interpreter.stack[interpreter.sp] = interpreter.pc
		interpreter.sp += 1
		interpreter.pc = nnn
		break
	case 0x3:
	case 0x4:
	case 0x5:
	case 0x6:
	case 0x7:
	case 0x8:
	case 0x9:
	case 0xA:
	case 0xB:
	case 0xC:
	case 0xD:
	case 0xE:
	case 0xF:
	}
}
