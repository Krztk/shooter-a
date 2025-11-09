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
    
    // Store old position before updating
    e.oldPos = e.pos
    
    updateSpritePlayer(&e.spritePlayer, dt)
}

disableEntity :: proc(e: ^Entity) {
    e.active = false
}

drawEntityToFrame :: proc(rf: ^RenderFrame, e: ^Entity, blendFactor: f32) {
    if !e.active do return
    
    // Interpolate position for smooth rendering
    interpPos := rl.Vector2{
        e.oldPos.x + (e.pos.x - e.oldPos.x) * blendFactor,
        e.oldPos.y + (e.pos.y - e.oldPos.y) * blendFactor,
    }
    
    drawSpritePlayerToFrame(rf, &e.spritePlayer, interpPos, e.z)
}
