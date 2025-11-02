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

    renderFrame := initRenderFrame()

    for !rl.WindowShouldClose() {
        dt: f32 = rl.GetFrameTime()

        updateInputs(&inputs)
        updatePlayerInput(&gameState, &inputs)
        updateEntities(&gameState, dt)

        clearRenderFrame(&renderFrame)
        drawEntitiesToFrame(&renderFrame, &gameState)
        
        // sortRenderCommands(&renderFrame)

        rl.BeginDrawing()
        rl.ClearBackground(rl.GRAY)
        flushRenderFrame(&renderFrame)
        rl.EndDrawing()
    }

    rl.CloseWindow()
}
