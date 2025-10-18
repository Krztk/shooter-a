package main

import rl "vendor:raylib"
import "core:fmt"

ALARM :: 0.15

SpritePlayer :: struct {
    atlas: ^Atlas,
    currentGroup: ^SpriteGroup,
    rect: rl.Rectangle,
    frames: int,
    frameIndex: int,
    alarm: f32
}

createSpritePlayer :: proc(atlas: ^Atlas) -> SpritePlayer {
    return SpritePlayer{
        atlas = atlas,
        currentGroup = &atlas.groups[0],
        rect = getRaylibRect(&atlas.groups[0], 0),
        frames = len(atlas.groups[0].positions),
        frameIndex = 0,
        alarm = ALARM
    }
}


updateSpritePlayer :: proc(p: ^SpritePlayer, dt: f32) {
    if p.frames == 1 do return

    if p.alarm <= 0.0 {
        p.frameIndex = (p.frameIndex + 1) % p.frames
        p.rect = getRaylibRect(p.currentGroup, p.frameIndex)
        p.alarm = ALARM
    } else {
        p.alarm -= dt
    }
}

drawSpritePlayer :: proc(p: ^SpritePlayer, pos: rl.Vector2) {
    rl.DrawTextureRec(p.atlas.texture, p.rect, pos, rl.WHITE)  
}

getRaylibRect :: proc(sg: ^SpriteGroup, frameIndex: int) -> rl.Rectangle {
    pos := sg.positions[frameIndex]
    return rl.Rectangle{f32(pos.x), f32(pos.y), f32(sg.frameWidth), f32(sg.frameHeight)}
}
