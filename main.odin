package main

import fmt "core:fmt"
import os "core:os"
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


Chip8 :: struct {
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

new_chip8 :: proc() -> Chip8 {
	memory := [4096]u8{}
	for i in 0 ..< len(fonts) {
		memory[i] = fonts[i]
	}
	return Chip8{pc = 0x200, opcode = 0, I = 0, sp = 0, memory = memory}
}

validate_args :: proc() {
	if len(os.args) < 2 {
		fmt.println("[!] Usage: chip8 <rom>")
		os.exit(1)
	} else if len(os.args) > 2 {
		fmt.println("[!] Warning: More than one ROM provided, ignoring extra")
	}
}

load_rom :: proc(chip8: ^Chip8) {
	rom, err := os.open(os.args[1], os.O_RDONLY)
	if err != nil {
		fmt.println("[-] Error: Failed to open ROM")
		os.exit(1)
	}
	defer os.close(rom)

	_, err = os.read(rom, chip8.memory[chip8.pc:])
	if err != nil {
		fmt.println("[-] Error: Failed to read ROM")
		os.exit(1)
	}

}

main :: proc() {
	validate_args()

	chip8 := new_chip8()

	load_rom(&chip8)

	rl.InitWindow(GRAPHICS_WIDTH * 16, GRAPHICS_HEIGHT * 16, "Chip8")
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
