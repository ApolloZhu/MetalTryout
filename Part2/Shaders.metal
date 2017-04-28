//
//  Shaders.metal
//  MetalTryout
//
//  Created by Apollo Zhu on 4/28/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
};

vertex Vertex vertex_function(constant Vertex *vertices [[buffer(0)]], uint vid [[vertex_id]]) {
    return vertices[vid];
}

fragment float4 fragment_function(Vertex vert [[stage_in]]) {
    return float4(0.7, 1, 1, 1);
}
