//
//  Shaders.metal
//  Part5
//
//  Created by Apollo Zhu on 1/28/19.
//  Copyright © 2019 WWITDC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    float4x4 modelMatrix;
};

vertex Vertex vertex_function(constant Vertex *vertices [[buffer(0)]],
                              constant Uniforms &uniforms [[buffer(1)]],
                              uint vid [[vertex_id]]) {
    float4x4 matrix = uniforms.modelMatrix;
    Vertex in = vertices[vid];
    Vertex out;
    out.position = matrix * in.position;
    out.color = in.color;
    return out;
}

fragment float4 fragment_function(Vertex vert [[stage_in]]) {
    return vert.color;
}
