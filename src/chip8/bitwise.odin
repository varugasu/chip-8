package chip8

get_left_most_nibble :: proc(opcode: u16) -> u16 {
	return opcode >> 12
}

get_second_nibble :: proc(opcode: u16) -> u16 {
	return (opcode >> 8) & 0x0F
}

get_third_nibble :: proc(opcode: u16) -> u16 {
	return (opcode >> 4) & 0x0F
}

get_last_two_nibbles :: proc(opcode: u16) -> u16 {
	return opcode & 0x00FF
}

get_last_three_nibbles :: proc(opcode: u16) -> u16 {
	return opcode & 0x0FFF
}
