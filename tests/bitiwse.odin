package tests

import "core:testing"

import chip8 "../src/chip8"


@(test)
get_left_most_nibble_test :: proc(t: ^testing.T) {
	test_cases := []struct {
		opcode, expected: u16,
	} {
		{0x1234, 0x1},
		{0x2345, 0x2},
		{0x3456, 0x3},
		{0x4567, 0x4},
		{0x5678, 0x5},
		{0x6789, 0x6},
		{0x789A, 0x7},
		{0x89AB, 0x8},
		{0x9ABC, 0x9},
		{0xABCD, 0xA},
		{0xBCDE, 0xB},
		{0xCDEF, 0xC},
		{0xDEFF, 0xD},
		{0xEFFF, 0xE},
		{0xFFFF, 0xF},
	}

	for test_case in test_cases {
		result := chip8.get_left_most_nibble(test_case.opcode)
		testing.expect_value(t, result, test_case.expected)
	}
}

@(test)
get_last_three_nibbles_test :: proc(t: ^testing.T) {
	result := chip8.get_last_three_nibbles(0x1234)
	testing.expect_value(t, result, 0x234)
}
