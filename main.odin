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

    // fmt.println(heroAtlas)
    totalGroups = getTotalGroups(&heroAtlas)


    pos: rl.Vector2 = {100,100}


    inputs: Inputs 
    gameState := initGame()
    defer clearEntities(&gameState)
    hero := spawnEntity(&gameState, &heroAtlas, rl.Vector2{200, 0})
    spawnEntity(&gameState, &heroAtlas, rl.Vector2{300, 0})

    for !rl.WindowShouldClose() {
        dt: f32 = rl.GetFrameTime()
        dx, dy: f32 = 0.0, 0.0

        updateInputs(&inputs)
        updateHero(hero, &inputs, dt)
        updateEntities(&gameState, dt)

        rl.BeginDrawing()
        rl.ClearBackground(rl.GRAY)

        rl.DrawTextureEx(heroAtlas.texture, pos, 0.0, 1.0, rl.WHITE);
        drawEntities(&gameState)
        rl.EndDrawing()
    }

    rl.CloseWindow()
}


updateHero :: proc(e: ^Entity, inputs: ^Inputs, dt: f32) {
    if inputs.actionA.pressed {
        groupIndex = (groupIndex + 1) % totalGroups
        changeSprite(&e.spritePlayer, groupIndex)
    }
}

