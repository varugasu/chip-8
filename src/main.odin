package main

import fmt "core:fmt"
import os "core:os"
import rl "vendor:raylib"

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
