package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math"

Hero :: struct {
    using entity: ^Entity,
    direction: rl.Vector2,
}

HERO_SPEED :: 200

updateHero :: proc(hero: ^Hero, dt: f32) {
    hero.oldPos = hero.pos

    hero.pos += hero.direction * HERO_SPEED * dt
    updateEntity(hero, dt)
}

