package main

import fmt "core:fmt"
import os "core:os"
import rl "vendor:raylib"

import chip8 "chip8"

validate_args :: proc() {
	if len(os.args) < 2 {
		fmt.println("[!] Usage: chip8 <rom>")
		os.exit(1)
	} else if len(os.args) > 2 {
		fmt.println("[!] Warning: More than one ROM provided, ignoring extra")
	}
}

load_rom :: proc(chip8: ^chip8.Interpreter) {
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

	interpreter := chip8.new_interpreter()

	load_rom(&interpreter)

	rl.InitWindow(chip8.GRAPHICS_WIDTH * 16, chip8.GRAPHICS_HEIGHT * 16, "Chip8")
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()

		for i in 0 ..< 16 {
			chip8.emulate_cycle(&interpreter)
		}
		chip8.draw(&interpreter)

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
