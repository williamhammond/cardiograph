package cardiograph

import rl "vendor:raylib"
import imgui "vendor/odin-imgui"

main :: proc() {
    rl.InitWindow(1280, 720, "Cardiograph")
    defer rl.CloseWindow()

    camera := rl.Camera{}
    camera.position = rl.Vector3 {0.0, 6.0, 12.0}
    camera.target = rl.Vector3 {0.0, 2.0, 0.0}
    camera.up = rl.Vector3 {0.0, 1.0, 0.0}
    camera.fovy = 60
    camera.projection = rl.CameraProjection.PERSPECTIVE

    camera_mode := rl.CameraMode.FIRST_PERSON

    rl.DisableCursor()
    rl.SetTargetFPS(60)

    imgui.CreateContext(nil)
	defer imgui.DestroyContext(nil)

    init()
    defer shutdown()
    build_font_atlas()

    for !rl.WindowShouldClose() {
        // Simulate
        rl.UpdateCamera(&camera, camera_mode)

		process_events()
        new_frame()
		imgui.NewFrame()

        rl.BeginDrawing()
        defer rl.EndDrawing()

        // Render
        rl.ClearBackground(rl.RAYWHITE)
        {
            rl.BeginMode3D(camera)
            defer rl.EndMode3D()
            rl.DrawCube(rl.Vector3{0, 1, 0}, 6, 6, 6, rl.RED)
        }

        // Debug
        rl.DrawFPS(10, rl.GetScreenHeight() - 24)
        rl.DrawText("Cardiograph", rl.GetScreenWidth() / 2, 10, 42, rl.WHITE)

        imgui.ShowDemoWindow(nil)
        imgui.Render()
		render_draw_data(imgui.GetDrawData())
    }
}
