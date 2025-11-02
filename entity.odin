package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math"

Entity :: struct {
    pos: rl.Vector2,
    oldPos: rl.Vector2,
    spritePlayer: SpritePlayer,
    active: bool,
    z: f32,
}

createEntity :: proc(atlas: ^Atlas, pos: rl.Vector2) -> Entity {
    return Entity{
         spritePlayer = createSpritePlayer(atlas),
         pos = pos,
         oldPos = pos,
         active = true,
    }
}

updateEntity :: proc(e: ^Entity, dt: f32) {
    if !e.active do return
    updateSpritePlayer(&e.spritePlayer, dt)
}

disableEntity :: proc(e: ^Entity) {
    e.active = false
}

//TODO alpha/bend factor?
// drawEntity :: proc(e: ^Entity) {
//     if !e.active do return
//     drawSpritePlayer(&e.spritePlayer, e.pos)
// }

drawEntityToFrame :: proc(rf: ^RenderFrame, e: ^Entity) {
    if !e.active do return
    drawSpritePlayerToFrame(rf, &e.spritePlayer, e.pos, e.z)
}
