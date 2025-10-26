package main

import rl "vendor:raylib"

Inputs :: struct {
    left: Action,
    right: Action,
    up: Action,
    down: Action,

    actionA: Action,
    actionB: Action,
}

Action :: struct {
    pressed: bool,
    active: bool,
}


updateInputs :: proc(i: ^Inputs) {
    i.right.active = rl.IsKeyDown(.D)
    i.right.pressed = rl.IsKeyPressed(.D)

    i.left.active = rl.IsKeyDown(.A)
    i.left.pressed = rl.IsKeyPressed(.A)

    i.up.active = rl.IsKeyDown(.W)
    i.up.pressed = rl.IsKeyPressed(.W)

    i.down.active = rl.IsKeyDown(.S)
    i.down.pressed = rl.IsKeyPressed(.S)


    i.actionA.active = rl.IsKeyDown(.J)
    i.actionA.pressed = rl.IsKeyPressed(.J)

    i.actionB.active = rl.IsKeyDown(.K)
    i.actionB.pressed = rl.IsKeyPressed(.K)
}

