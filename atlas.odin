package main

import rl "vendor:raylib"
import "core:fmt"
import "core:encoding/json"
import "core:os"
import "core:strings"

RESOURCES_PATH :: "resources/"

Vector2I :: struct {
    x: int,
    y: int
}

SpriteGroup :: struct {
    name: string,
    frameWidth: int,
    frameHeight: int,
    positions: [dynamic]Vector2I,
    rects: [dynamic]rl.Rectangle,  // computed, not in the json
}

AtlasMeta :: struct {
    file: string,
    groups: [dynamic]SpriteGroup,
}

Atlas :: struct {
    using meta: AtlasMeta,
    texture: rl.Texture
}

destroyAtlas :: proc(atlas: ^Atlas) {
    rl.UnloadTexture(atlas.texture)
    delete(atlas.file)
    for &sg in atlas.groups {
        delete(sg.name)
        delete(sg.positions)
        delete(sg.rects)
    }
    delete(atlas.groups)
}

loadAtlas :: proc(name: string) -> (Atlas, bool) {
    atlas: Atlas
    
    jsonPath := fmt.tprintf("%s%s.json", RESOURCES_PATH, name)
    data, ok := os.read_entire_file_from_filename(jsonPath)
    if !ok {
        fmt.eprintfln("Unable to read file: %s", jsonPath)
        return atlas, false
    }
    defer delete(data)
    
    err := json.unmarshal(data, &atlas.meta)
    if err != nil {
        fmt.eprintfln("JSON unmarshal failed: %v", err)
        return atlas, false
    }

    // Compute rectangles for each group
    for &sg in atlas.groups {
        sg.rects = make([dynamic]rl.Rectangle, len(sg.positions))
        for pos, i in sg.positions {
            sg.rects[i] = rl.Rectangle{
                f32(pos.x),
                f32(pos.y),
                f32(sg.frameWidth),
                f32(sg.frameHeight)
            }
        }
    }
    
    imgPath := fmt.tprintf("%s%s", RESOURCES_PATH, atlas.file)
    cStrPath := strings.unsafe_string_to_cstring(imgPath)
    fmt.printfln("loading img from: '%s'", cStrPath)
    image := rl.LoadImage(cStrPath)
    defer rl.UnloadImage(image)
    atlas.texture = rl.LoadTextureFromImage(image)
    
    return atlas, true
}

