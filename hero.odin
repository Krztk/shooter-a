package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math"

Hero :: struct {
    using entity: ^Entity,
    direction: rl.Vector2,
}

HERO_SPEED :: 200

updateHero :: proc(hero: ^Hero, tilemap: ^Tilemap, dt: f32) {
    hero.oldPos = hero.pos
    
    hero.pos.x += hero.direction.x * HERO_SPEED * dt
    hero.pos.y += hero.direction.y * HERO_SPEED * dt
    
    actorRect := rl.Rectangle{
        x = hero.pos.x,
        y = hero.pos.y,
        width = hero.size.x,
        height = hero.size.y,
    }
    
    resolveMapCollisions(tilemap, &actorRect)
    
    hero.pos.x = actorRect.x
    hero.pos.y = actorRect.y
    
    updateEntity(hero, dt)
}

