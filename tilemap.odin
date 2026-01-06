package main

import rl "vendor:raylib"
import "core:fmt"
import "core:encoding/json"
import "core:os"
import "core:strings"

Tilemap :: struct {
    texture: rl.Texture,
    width: int,
    height: int,
    layers: []Layer,  
    tileheight: int,
    tilewidth: int,
    collisionLayer: ^Layer,
}

Layer :: struct {
    data: []int,  
    height: int,
    width: int,
    id: int,
    visible: bool,
    x: int,
    y: int,
    name: string,  
}

Tiled :: struct {
    width: int,
    height: int,
    tileheight: int,
    tilewidth: int,
    layers: []struct {
        data: []int,
        height: int,
        width: int,
        id: int,
        visible: bool,
        x: int,
        y: int,
        name: string,
    },
}

loadTilemap :: proc(mapName: string, tilesetName: string) -> (Tilemap, bool) {
    tilemap: Tilemap
    tiled: Tiled
    
    jsonPath := fmt.tprintf("%s%s", RESOURCES_PATH, mapName)
    data, ok := os.read_entire_file_from_filename(jsonPath)
    if !ok {
        fmt.eprintfln("Unable to read tilemap file: %s", jsonPath)
        return {}, false
    }
    defer delete(data) 
    
    err := json.unmarshal(data, &tiled)
    if err != nil {
        fmt.eprintfln("JSON unmarshal failed: %v", err)
        return {}, false
    }


    imgPath := fmt.tprintf("%s%s", RESOURCES_PATH, tilesetName)
    cStrPath := strings.unsafe_string_to_cstring(imgPath)
    fmt.printfln("loading tileset image from: '%s'", cStrPath)
    image := rl.LoadImage(cStrPath)
    defer rl.UnloadImage(image)
    tilemap.texture = rl.LoadTextureFromImage(image)
    tilemap.width = tiled.width
    tilemap.height = tiled.height
    tilemap.tileheight = tiled.tileheight
    tilemap.tilewidth = tiled.tilewidth
    tilemap.layers = make([]Layer, len(tiled.layers))

    for tiledLayer, i in tiled.layers {
        layer := &tilemap.layers[i]
        
        layer.height = tiledLayer.height
        layer.width = tiledLayer.width
        layer.id = tiledLayer.id
        layer.visible = tiledLayer.visible
        layer.x = tiledLayer.x
        layer.y = tiledLayer.y
        
        layer.name = strings.clone(tiledLayer.name)
        
        layer.data = make([]int, len(tiledLayer.data))
        copy(layer.data, tiledLayer.data)

        if layer.name == "collision" {
            tilemap.collisionLayer = layer
        }
    }

    return tilemap, true
}

destroyTilemap :: proc(tilemap: ^Tilemap) {
    rl.UnloadTexture(tilemap.texture)
    
    for layer in tilemap.layers {
        delete(layer.name)
        delete(layer.data)
    }
    
    delete(tilemap.layers)
}

drawTilemap :: proc(tilemap: ^Tilemap, camera: rl.Camera2D) {
    if tilemap.texture.id == 0 do return

    screen_width := f32(rl.GetScreenWidth())
    screen_height := f32(rl.GetScreenHeight())
    
    top_left := rl.GetScreenToWorld2D({0, 0}, camera)
    bottom_right := rl.GetScreenToWorld2D({screen_width, screen_height}, camera)
    
    padding := 1
    start_x := max(0, int(top_left.x / f32(tilemap.tilewidth)) - padding)
    start_y := max(0, int(top_left.y / f32(tilemap.tileheight)) - padding)
    end_x := min(tilemap.width, int(bottom_right.x / f32(tilemap.tilewidth)) + 1 + padding)
    end_y := min(tilemap.height, int(bottom_right.y / f32(tilemap.tileheight)) + 1 + padding)
    
    tiles_per_row := tilemap.texture.width / i32(tilemap.tilewidth)

    for layer in tilemap.layers {
        if !layer.visible do continue
        if layer.name == "collision" do continue
        
        for y in start_y..<end_y {
            for x in start_x..<end_x {
                index := y * layer.width + x
                if index < 0 || index >= len(layer.data) do continue

                tile_id := layer.data[index]
                if tile_id == 0 do continue  // Empty tile

                tile_index := tile_id - 1
                src_x := tile_index % int(tiles_per_row)
                src_y := tile_index / int(tiles_per_row)
                src := rl.Rectangle{
                    x = f32(src_x * tilemap.tilewidth),
                    y = f32(src_y * tilemap.tileheight),
                    width = f32(tilemap.tilewidth),
                    height = f32(tilemap.tileheight),
                }

                dest := rl.Rectangle{
                    x = f32(x * tilemap.tilewidth + layer.x),
                    y = f32(y * tilemap.tileheight + layer.y),
                    width = f32(tilemap.tilewidth),
                    height = f32(tilemap.tileheight),
                }

                rl.DrawTexturePro(
                    tilemap.texture,
                    src,
                    dest,
                    {0, 0},
                    0,
                    rl.WHITE
                )
            }
        }
    }
}

isTileCollision :: proc(tilemap: ^Tilemap, tileX, tileY: int) -> bool {
    if tilemap.collisionLayer == nil do return false
    
    if tileX < 0 || tileX >= tilemap.collisionLayer.width do return true
    if tileY < 0 || tileY >= tilemap.collisionLayer.height do return true
    
    index := tileY * tilemap.collisionLayer.width + tileX
    if index < 0 || index >= len(tilemap.collisionLayer.data) do return true
    
    // Non-zero tile ID means collision
    return tilemap.collisionLayer.data[index] != 0
}

checkTilemapCollision :: proc(tilemap: ^Tilemap, rect: rl.Rectangle) -> bool {
    left := int(rect.x / f32(tilemap.tilewidth))
    right := int((rect.x + rect.width - 1) / f32(tilemap.tilewidth))
    top := int(rect.y / f32(tilemap.tileheight))
    bottom := int((rect.y + rect.height - 1) / f32(tilemap.tileheight))
    
    for y in top..=bottom {
        for x in left..=right {
            if isTileCollision(tilemap, x, y) {
                return true
            }
        }
    }
    
    return false
}

getTileColliders :: proc(tilemap: ^Tilemap, actor: rl.Rectangle, allocator := context.temp_allocator) -> [dynamic]rl.Rectangle {
    colliders := make([dynamic]rl.Rectangle, allocator)
    
    left := int(actor.x / f32(tilemap.tilewidth)) - 1
    right := int((actor.x + actor.width - 1) / f32(tilemap.tilewidth)) + 1
    top := int(actor.y / f32(tilemap.tileheight)) - 1
    bottom := int((actor.y + actor.height - 1) / f32(tilemap.tileheight)) + 1
    
    for y in top..=bottom {
        for x in left..=right {
            if isTileCollision(tilemap, x, y) {
                tileRect := rl.Rectangle{
                    x = f32(x * tilemap.tilewidth),
                    y = f32(y * tilemap.tileheight),
                    width = f32(tilemap.tilewidth),
                    height = f32(tilemap.tileheight),
                }
                append(&colliders, tileRect)
            }
        }
    }
    
    return colliders
}

resolveMapCollisions :: proc(tilemap: ^Tilemap, actor: ^rl.Rectangle) -> rl.Vector2 {
    colliders := getTileColliders(tilemap, actor^)
    defer delete(colliders)

    
    if len(colliders) == 0 do return rl.Vector2{0,0}

    correction := rl.Vector2{actor.x, actor.y}
    
    // Run multiple iterations to handle corners and tight passages
    for iter in 0..<3 {
        // Find the collision with the largest overlap area
        mostOverlap := SignedRect{0, 0, 0, 0}
        maxArea := f32(0)
        
        for collider in colliders {
            overlap := signedCollisionRect(collider, actor^)
            area := abs(overlap.width * overlap.height)
            
            if area > maxArea {
                maxArea = area
                mostOverlap = overlap
            }
        }
        
        // No overlaps found
        if maxArea == 0 do break
        
        // Resolve along the smallest axis
        if abs(mostOverlap.width) < abs(mostOverlap.height) {
            actor.x += mostOverlap.width
            // fmt.printfln("actorX += %v", mostOverlap.width)
        } else {
            actor.y += mostOverlap.height
        }
    }

    correction.x -= actor.x
    correction.y -= actor.y

    return correction
}
