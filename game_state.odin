package main

import "core:mem"
import "core:fmt"
import rl "vendor:raylib"

MAX_ENTITIES :: 1024

GameState :: struct {
    entityArena: mem.Arena,
    enemies: [MAX_ENTITIES]^Entity, 
    hero: ^Hero,
    // other entities, like pickups, bullets etc.
    entityCount: i32,
}

initGame :: proc() -> GameState {
    state: GameState

    arenaBacking := make([]byte, mem.Megabyte)
    mem.arena_init(&state.entityArena, arenaBacking)

    state.entityCount = 0

    return state
}

clearEntities :: proc(state: ^GameState) {
    mem.arena_free_all(&state.entityArena)
    state.entityCount = 0
}

spawnHero :: proc(state: ^GameState, atlas: ^Atlas, pos: rl.Vector2) -> ^Hero {
    if state.entityCount >= MAX_ENTITIES {
        fmt.println("MAX_ENTITIES - hero not spawned")
        return nil
    }
    
    arenaAlloc := mem.arena_allocator(&state.entityArena)
    
    entity := new(Entity, arenaAlloc)
    entity^ = createEntity(atlas, pos)
    
    hero := new(Hero, arenaAlloc)
    hero.entity = entity
    hero.direction = rl.Vector2{0, 0}
    
    state.enemies[state.entityCount] = entity
    state.entityCount += 1
    
    state.hero = hero
    
    return hero
}

spawnEntity :: proc(state: ^GameState, atlas: ^Atlas, pos: rl.Vector2) -> ^Entity {
    if state.entityCount >= MAX_ENTITIES {
        fmt.println("MAX_ENTITIES - entity not spawned")
        return nil
    }

    arenaAlloc := mem.arena_allocator(&state.entityArena)
    entity := new(Entity, arenaAlloc)
    entity^ = createEntity(atlas, pos)

    state.enemies[state.entityCount] = entity
    state.entityCount += 1

    return entity
}

updatePlayerInput :: proc(gameState: ^GameState, inputs: ^Inputs) {
    direction: rl.Vector2

    if inputs.right.active do direction.x += 1
    if inputs.left.active do direction.x -= 1
    if inputs.up.active do direction.y -= 1
    if inputs.down.active do direction.y += 1

    if direction.x != 0 || direction.y != 0 {
        direction = rl.Vector2Normalize(direction)
    } 

    gameState.hero.direction = direction

    if inputs.actionA.pressed {
        //action like shoot etc.
    }
}

updateEntities :: proc(state: ^GameState, dt: f32) {
    if state.hero != nil {
        updateHero(state.hero, dt)
    }

    for i in 0..<state.entityCount {
        entity := state.enemies[i]
        updateEntity(entity, dt)
    }
}

// drawEntities :: proc(state: ^GameState) {
//     drawEntity(state.hero)
//     for i in 0..<state.entityCount {
//         drawEntity(state.enemies[i])
//     }
// }

drawEntitiesToFrame :: proc(rf: ^RenderFrame, state: ^GameState) {
    if state.hero != nil {
        drawEntityToFrame(rf, state.hero.entity)
    }
    
    for i in 0..<state.entityCount {
        drawEntityToFrame(rf, state.enemies[i])
    }
}


