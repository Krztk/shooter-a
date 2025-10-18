package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math"

Entity :: struct {
    pos: rl.Vector2,
    oldPos: rl.Vector2,
    spritePlayer: SpritePlayer
}

createEntity :: proc(atlas: ^Atlas) -> Entity {
    return Entity{
         spritePlayer = createSpritePlayer(atlas),
    }
}

updateEntity :: proc(e: ^Entity, dt: f32) {
    updateSpritePlayer(&e.spritePlayer, dt)
}

//TODO alpha/bend factor?
drawEntity :: proc(e: ^Entity) {
    drawSpritePlayer(&e.spritePlayer, e.pos)
}
