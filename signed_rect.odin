package main

import rl "vendor:raylib"

SignedRect :: struct {
    x, y: f32,
    width, height: f32, // Can be negative to indicate direction
}

signedCollisionRect :: proc(a, b: rl.Rectangle) -> SignedRect {
    // Determine which rect is further left/top and set sign accordingly
    left, widthSign := a.x > b.x ? a.x : b.x, a.x > b.x ? f32(-1) : f32(1)
    right := min(a.x + a.width, b.x + b.width)
    
    top, heightSign := a.y > b.y ? a.y : b.y, a.y > b.y ? f32(-1) : f32(1)
    bottom := min(a.y + a.height, b.y + b.height)
    
    // Check if rectangles actually overlap
    if left < right && top < bottom {
        return SignedRect{
            x = left,
            y = top,
            width = (right - left) * widthSign,
            height = (bottom - top) * heightSign,
        }
    }
    
    // No collision
    return SignedRect{0, 0, 0, 0}
}
