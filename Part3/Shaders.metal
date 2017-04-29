//
//  Shaders.metal
//  MetalTryout
//
//  Created by Apollo Zhu on 4/28/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// Syntax: [[<#built-in input/output variable#>]]

struct Vertex {
    // Using built-in position
    float4 position [[position]];
    float4 color;
};

vertex // Specify it is a vertex shader
Vertex vertex_function // Vertex function rarely runs
(constant // (Memory) address space
 Vertex *vertices // List of vertices
 [[buffer(0)]], // Using the buffer of the first device

 uint vid [[vertex_id]] // Identifier for identifying vertex
 ) {
    return vertices[vid];
}

fragment float4 fragment_function // Fragment function runs frequently
(Vertex vert
 [[stage_in]] // Pre-fragment input
 ) {
    return vert.color; // Use the desired color for vertex
}

/* Next:
 # Rasterization
 Interpolating each pixel is average color of its neighbors.

 ```
             Blue
     Magenta       Cyan
 Red        Yellow      Green
 ```
 */
