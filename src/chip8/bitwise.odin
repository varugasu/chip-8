package chip8

get_left_most_nibble :: proc(opcode: u16) -> u16 {
	return opcode >> 12
}
