package main

import "core:mem"
import "core:fmt"
import rl "vendor:raylib"

MAX_ENTITIES :: 1024
CAMERA_SMOOTHNESS :: 3.0

GameState :: struct {
    entityArena: mem.Arena,
    enemies: [MAX_ENTITIES]^Entity, 
    hero: ^Hero,
    entityCount: i32,
    cameraPos: rl.Vector2,
    oldCameraPos: rl.Vector2,
    tilemap: ^Tilemap,
}

initGame :: proc(tilemap: ^Tilemap) -> GameState {
    state: GameState
    state.tilemap = tilemap

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
        updateHero(state.hero, state.tilemap, dt)
    }

    for i in 0..<state.entityCount {
        entity := state.enemies[i]
        updateEntity(entity, dt)
    }

    state.oldCameraPos = state.cameraPos

    if state.hero != nil {
        targetPos := state.hero.pos
        state.cameraPos = targetPos
        // state.cameraPos.x += (targetPos.x - state.cameraPos.x) * CAMERA_SMOOTHNESS * dt
        // state.cameraPos.y += (targetPos.y - state.cameraPos.y) * CAMERA_SMOOTHNESS * dt
    }
}

drawEntitiesToFrame :: proc(rf: ^RenderFrame, state: ^GameState, blendFactor: f32) {
    if state.hero != nil {
        drawEntityToFrame(rf, state.hero.entity, blendFactor)
    }
    
    for i in 0..<state.entityCount {
        drawEntityToFrame(rf, state.enemies[i], blendFactor)
    }
}
