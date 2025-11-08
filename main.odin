package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math"


totalGroups := 0
groupIndex := 0;

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

    totalGroups = getTotalGroups(&heroAtlas)
    pos: rl.Vector2 = {100,100}

    inputs: Inputs 
    gameState := initGame()
    defer clearEntities(&gameState)
    spawnHero(&gameState, &heroAtlas, rl.Vector2{200, 0})
    spawnEntity(&gameState, &heroAtlas, rl.Vector2{300, 0})

    camera := rl.Camera2D{
        target   = rl.Vector2{0, 0},
        offset   = rl.Vector2{f32(screenWidth / 2), f32(screenHeight / 2)},
        rotation = 0.0,
        zoom     = 1.0,
    }

    renderFrame := initRenderFrame()

    for !rl.WindowShouldClose() {
        dt: f32 = rl.GetFrameTime()

        updateInputs(&inputs)
        updatePlayerInput(&gameState, &inputs)
        updateEntities(&gameState, dt)

        clearRenderFrame(&renderFrame)
        drawEntitiesToFrame(&renderFrame, &gameState)
        
        // sortRenderCommands(&renderFrame)

        // Sync rendering camera with game camera
        camera.target.x = math.round_f32(gameState.cameraPos.x)
        camera.target.y = math.round_f32(gameState.cameraPos.y)

        rl.BeginDrawing()
        rl.ClearBackground(rl.GRAY)

        rl.BeginMode2D(camera)
        flushRenderFrame(&renderFrame)
        rl.EndMode2D()

        rl.EndDrawing()
    }

    rl.CloseWindow()
}
