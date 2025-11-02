package main

import rl "vendor:raylib"


Tilemap :: struct {
    texture: rl.Texture,
    width: int,
    height: int,
    layers: []Layer,
    tileheight: int,
    tilewidth: int,
}

Layer :: struct {
    data: []int,
    height: int,
    width: int,
    id: int,
    visible: bool,
    x: int,
    y: int,
}

// drawTileMap :: proc(tilemap: ^Tilemap, camera: rl.Camera2D) {
//     startX := max(0, int(camera.target.x) / tilemap.tileSize)
//     startY := max(0, int(camera.target.y) / tilemap.tileSize)
//     endX := min(tilemap.width, startX + screenWidth/tilemap.tileSize + 1)
//     endY := min(tilemap.height, startY + screenHeight/tilemap.tileSize + 1)
// }
