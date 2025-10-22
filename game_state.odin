package main

import "core:mem"
import rl "vendor:raylib"

MAX_ENTITIES :: 1024

GameState :: struct {
    entityArena: mem.Arena,
    entities: [MAX_ENTITIES]^Entity, 
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

spawnEntity :: proc(state: ^GameState, atlas: ^Atlas, pos: rl.Vector2) -> ^Entity {
    if state.entityCount >= MAX_ENTITIES {
        // Optional: log warning, or handle gracefully
        return nil
    }

    arenaAlloc := mem.arena_allocator(&state.entityArena)
    entity := new(Entity, arenaAlloc)
    entity^ = createEntity(atlas, pos)

    state.entities[state.entityCount] = entity
    state.entityCount += 1

    return entity
}

updateEntities :: proc(state: ^GameState, dt: f32) {
    for i in 0..<state.entityCount {
        updateEntity(state.entities[i], dt)
    }
}

drawEntities :: proc(state: ^GameState) {
    for i in 0..<state.entityCount {
        drawEntity(state.entities[i])
    }
}
