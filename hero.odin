package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math"

Hero :: struct {
    using entity: ^Entity,
    direction: rl.Vector2,
    velocity: rl.Vector2,
}

HERO_SPEED :: 200
HERO_ACC :: 600
HERO_GRAVITY :: 400
HERO_JUMP :: 500
GROUND_DAMPING :: 0.8
AIR_DAMPING :: 0.95

updateHero :: proc(hero: ^Hero, tilemap: ^Tilemap, dt: f32) {
    hero.oldPos = hero.pos
    
    hero.velocity.x += hero.direction.x * HERO_ACC * dt

    colliderBelow := rl.Rectangle{hero.pos.x, hero.pos.y + 1, hero.size.y, hero.size.y}
    onGround := checkTilemapCollision(tilemap, colliderBelow)

    if (!onGround) {
        hero.velocity.y += HERO_GRAVITY * dt
    }

    hero.velocity.x = clamp(hero.velocity.x, -HERO_SPEED, HERO_SPEED)
    hero.velocity.y = min(hero.velocity.y, 800)

    if (hero.direction.y == -1 && onGround) {
        hero.velocity.y = -HERO_JUMP;
    }

    damping :f32 = GROUND_DAMPING if onGround else AIR_DAMPING
    if hero.direction.x == 0 {
        hero.velocity.x *= damping
        
        // Stop if very slow (prevents floating point drift)
        if abs(hero.velocity.x) < 1.0 {
            hero.velocity.x = 0
        }
    }

    hero.pos.x += hero.velocity.x * dt
    hero.pos.y += hero.velocity.y * dt
    
    actorRect := rl.Rectangle{
        x = hero.pos.x,
        y = hero.pos.y,
        width = hero.size.x,
        height = hero.size.y,
    }
    
    // fmt.printfln("hero pos before resolve %v", hero.pos)
    correction := resolveMapCollisions(tilemap, &actorRect)

    if (correction.y != 0) {
        hero.velocity.y = 0
    }

    if (correction.x != 0) {
        hero.velocity.x = 0
    }
    
    
    hero.pos.x = actorRect.x
    hero.pos.y = actorRect.y

    // fmt.printfln("correction %v, pos: %v", correction, hero.pos)

    updateEntity(hero, dt)
}

