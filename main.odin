package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math"

main :: proc() {
    screenWidth: i32 = 1280
    screenHeight: i32 = 720
    rl.InitWindow(screenWidth, screenHeight, "Game")
    // rl.SetExitKey(cast(rl.KeyboardKey)0)

    speed: f32 = 200.0
    heroAtlas, ok := loadAtlas("hero");
    if (!ok) {
        rl.CloseWindow();
        return;
    }
    defer destroyAtlas(&heroAtlas)

    fmt.println(heroAtlas)

    pos: rl.Vector2 = {0,0}

    for !rl.WindowShouldClose() {
        // dt: f32 = rl.GetFrameTime()
        dx, dy: f32 = 0.0, 0.0

        if rl.IsKeyDown(.D) { dx += 1 }
        if rl.IsKeyDown(.A) { dx -= 1 }
        if rl.IsKeyDown(.W) { dy -= 1 }
        if rl.IsKeyDown(.S) { dy += 1 }

        if dx != 0 && dy != 0 {
            len: f32 = math.sqrt_f32(dx*dx + dy*dy)
            dx /= len
            dy /= len
        }

        // movement_x := dx * speed * dt
        // movement_y := dy * speed * dt


        rl.BeginDrawing()
        rl.ClearBackground(rl.GRAY)

        rl.DrawTextureEx(heroAtlas.texture, pos, 0.0, 1.0, rl.WHITE);
        rl.EndDrawing()
    }

    rl.CloseWindow()
}

