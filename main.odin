package main

import rl "vendor:raylib"

GRAPHICS_WIDTH :: 64
GRAPHICS_HEIGHT :: 32

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

main :: proc() {
	rl.InitWindow(GRAPHICS_WIDTH * 16, GRAPHICS_HEIGHT * 16, "Chip8")
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
