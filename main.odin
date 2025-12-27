package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math"
import "core:strings"

totalGroups := 0
groupIndex := 0;

main :: proc() {
    screenWidth: i32 = 1280
    screenHeight: i32 = 720
    rl.InitWindow(screenWidth, screenHeight, "Game")

    speed: f32 = 200.0
    heroAtlas, ok := loadAtlas("hero");
    if (!ok) {
        rl.CloseWindow();
        return;
    }
    defer destroyAtlas(&heroAtlas)

    tilemap, tilemapOk := loadTilemap("map_1.tmj", "bg-sprites.png")
    if (!tilemapOk) {
        rl.CloseWindow();
        return;
    }
    defer destroyTilemap(&tilemap)

    totalGroups = getTotalGroups(&heroAtlas)
    pos: rl.Vector2 = {100,100}

    inputs: Inputs 
    gameState := initGame(&tilemap)
    defer clearEntities(&gameState)
    spawnHero(&gameState, &heroAtlas, rl.Vector2{200, 200})
    spawnEntity(&gameState, &heroAtlas, rl.Vector2{300, 200})

    camera := rl.Camera2D{
        target   = rl.Vector2{0, 0},
        offset   = rl.Vector2{f32(screenWidth / 2), f32(screenHeight / 2)},
        rotation = 0.0,
        zoom     = 1.0,
    }

    renderFrame := initRenderFrame()

    FIXED_DT :: 1.0 / 60.0  // 60 updates per second
    accumulator: f32 = 0.0
    maxFrameTime: f32 = 0.25  

    for !rl.WindowShouldClose() {
        frameTime: f32 = rl.GetFrameTime()
        
        if frameTime > maxFrameTime {
            frameTime = maxFrameTime
        }
        
        accumulator += frameTime

        updateInputs(&inputs)

        for accumulator >= FIXED_DT {
            updatePlayerInput(&gameState, &inputs)
            updateEntities(&gameState, FIXED_DT)
            accumulator -= FIXED_DT
        }

        blendFactor: f32 = accumulator / FIXED_DT

        clearRenderFrame(&renderFrame)
        drawEntitiesToFrame(&renderFrame, &gameState, blendFactor)
        
        // interpCameraPos := interpolateVector2(
        //     gameState.oldCameraPos, 
        //     gameState.cameraPos, 
        //     blendFactor
        // )
        
        camera.target.x = math.round_f32(gameState.cameraPos.x)
        camera.target.y = math.round_f32(gameState.cameraPos.y)

        rl.BeginDrawing()
        rl.ClearBackground(rl.GRAY)

        rl.BeginMode2D(camera)
        drawTilemap(&tilemap, camera)
        flushRenderFrame(&renderFrame)
        rl.EndMode2D()

        str := fmt.tprintf("Vector2(%v, %v)", gameState.hero.pos.x, gameState.hero.pos.y)
        text_cstr := strings.clone_to_cstring(str)
        defer delete(text_cstr)
        rl.DrawText(text_cstr, 0, 0, 18, rl.BLACK)

        rl.EndDrawing()
    }

    rl.CloseWindow()
}

interpolateVector2 :: proc(a, b: rl.Vector2, t: f32) -> rl.Vector2 {
    return rl.Vector2{
        a.x + (b.x - a.x) * t,
        a.y + (b.y - a.y) * t,
    }
}
