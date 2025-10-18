package main

import rl "vendor:raylib"
import "core:fmt"

ALARM :: 0.15

SpritePlayer :: struct {
    atlas: ^Atlas,
    currentGroup: ^SpriteGroup,
    frames: int,
    frameIndex: int,
    alarm: f32
}

createSpritePlayer :: proc(atlas: ^Atlas) -> SpritePlayer {
    return SpritePlayer{
        atlas = atlas,
        currentGroup = &atlas.groups[0],
        frames = len(atlas.groups[0].positions),
        frameIndex = 0,
        alarm = ALARM
    }
}

updateSpritePlayer :: proc(p: ^SpritePlayer, dt: f32) {
    if p.frames == 1 do return
    p.alarm -= dt 
    
    if p.alarm <= 0.0 {
        p.frameIndex = (p.frameIndex + 1) % p.frames
        p.alarm = ALARM
    }
}

drawSpritePlayer :: proc(p: ^SpritePlayer, pos: rl.Vector2) {
    rect := p.currentGroup.rects[p.frameIndex]
    rl.DrawTextureRec(p.atlas.texture, rect, pos, rl.WHITE)  
}
