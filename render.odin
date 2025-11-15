package main

import rl "vendor:raylib"
import "core:slice"

MAX_RENDER_COMMANDS :: 2048

RenderCommand :: struct {
    texture: rl.Texture2D,
    sourceRect: rl.Rectangle,
    pos: rl.Vector2,
    z: f32,
    tint: rl.Color,
}

DebugCommand :: struct {
    rect: rl.Rectangle,
    color: rl.Color
}

RenderFrame :: struct {
    commands: [MAX_RENDER_COMMANDS]RenderCommand,
    commandCount: int,

    debugCommands: [MAX_RENDER_COMMANDS]DebugCommand,
    debugCommandCount: int,
}

initRenderFrame :: proc() -> RenderFrame {
    return RenderFrame{
        commandCount = 0,
        debugCommandCount = 0,
    }
}

clearRenderFrame :: proc(rf: ^RenderFrame) {
    rf.commandCount = 0
    rf.debugCommandCount = 0
}

pushRenderCommand :: proc(rf: ^RenderFrame, texture: rl.Texture2D, sourceRect: rl.Rectangle, pos: rl.Vector2, z: f32, tint: rl.Color = rl.WHITE) {
    if rf.commandCount >= MAX_RENDER_COMMANDS {
        return
    }
    
    rf.commands[rf.commandCount] = RenderCommand{
        texture = texture,
        sourceRect = sourceRect,
        pos = pos,
        z = z,
        tint = tint,
    }
    rf.commandCount += 1
}

pushDebugRectangle :: proc(rf: ^RenderFrame, rect: rl.Rectangle, color: rl.Color = rl.RED) {
    if rf.debugCommandCount >= MAX_RENDER_COMMANDS {
        return
    }
    
    rf.debugCommands[rf.debugCommandCount] = DebugCommand{
        rect = rect,
        color = color
    }
    rf.debugCommandCount += 1

}

sortRenderCommands :: proc(rf: ^RenderFrame) {
    commands := rf.commands[:rf.commandCount]
    slice.sort_by(commands, proc(a, b: RenderCommand) -> bool {
        return a.z < b.z
    })
}

flushRenderFrame :: proc(rf: ^RenderFrame) {
    for i in 0..<rf.commandCount {
        cmd := rf.commands[i]
        rl.DrawTextureRec(cmd.texture, cmd.sourceRect, cmd.pos, cmd.tint)
    }

    for i in 0..<rf.debugCommandCount {
        cmd := rf.debugCommands[i]
        rl.DrawRectangleRec(cmd.rect, cmd.color)
    }
}
