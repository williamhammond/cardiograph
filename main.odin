package cardiograph

import rl "vendor:raylib"

main :: proc() {
    rl.InitWindow(1280, 720, "Cardiograph")

    for !rl.WindowShouldClose() {
        //Setup
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        // Debug
        rl.DrawFPS(10, rl.GetScreenHeight() - 24)
        rl.DrawText("Cardiograph", rl.GetScreenWidth() / 2, 10, 42, rl.WHITE)

        // Cleanup
        rl.EndDrawing()
    }

    rl.CloseWindow()
}
