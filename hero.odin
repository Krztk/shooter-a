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
    
    newPosX := hero.pos + rl.Vector2{hero.direction.x * HERO_SPEED * dt, 0}
    rectX := rl.Rectangle{
        x = newPosX.x - hero.size.x / 2,
        y = hero.pos.y - hero.size.y / 2,
        width = hero.size.x,
        height = hero.size.y,
    }
    
    if !checkTilemapCollision(tilemap, rectX) {
        hero.pos.x = newPosX.x
    }
    
    newPosY := hero.pos + rl.Vector2{0, hero.direction.y * HERO_SPEED * dt}
    rectY := rl.Rectangle{
        x = hero.pos.x - hero.size.x / 2,
        y = newPosY.y - hero.size.y / 2,
        width = hero.size.x,
        height = hero.size.y,
    }
    
    if !checkTilemapCollision(tilemap, rectY) {
        hero.pos.y = newPosY.y
    }
    
    updateEntity(hero, dt)
}

