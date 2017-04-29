//
//  MetalView.swift
//  MetalTryout
//
//  Created by Apollo Zhu on 4/27/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

//  Tutorial: http://metalkit.org/2016/01/25/using-metalkit-part-3.html

import Cocoa
import MetalKit

extension MTLClearColor {
    static let gray = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
}

/// Each vertex
struct Vertex {
    /// The location of the vertex
    var position: vector_float4
    /// The color of the vertex
    var color: vector_float4
}

class MetalView: MTKView {

    required init(coder: NSCoder) {
        super.init(coder: coder)
        device = MTLCreateSystemDefaultDevice()
    }

    lazy var cmdQueue: MTLCommandQueue = self.device!.makeCommandQueue()

    /// Buffer of vertices for shaders.
    lazy var vertexBuffer: MTLBuffer = {
        let vertexData: [Vertex] = [
            // red bottom left
            Vertex(position: [-1.0, -1.0, 0.0, 1.0], color: [1, 0, 0, 1]),
            // green bottom right
            Vertex(position: [ 1.0, -1.0, 0.0, 1.0], color: [0, 1, 0, 1]),
            // blue top center
            Vertex(position: [ 0.0,  1.0, 0.0, 1.0], color: [0, 0, 1, 1])
        ]
        let length = vertexData.count * MemoryLayout<Vertex>.size
        return self.device!.makeBuffer(bytes: vertexData, length: length)
    }()

    /// Instructions for the rendering pipeline.
    lazy var renderPipelineState: MTLRenderPipelineState = {
        let library = self.device!.newDefaultLibrary()!
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "vertex_function")
        descriptor.fragmentFunction = library.makeFunction(name: "fragment_function")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        return try! self.device!.makeRenderPipelineState(descriptor: descriptor)
    }()


    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if let drawable = currentDrawable,
            let descriptor = currentRenderPassDescriptor {
            // We are not just clearing everytime, so keep with default
            descriptor.colorAttachments[0].clearColor = .gray
            let cmdBuffer = cmdQueue.makeCommandBuffer()
            let encoder = cmdBuffer.makeRenderCommandEncoder(descriptor: descriptor)

            encoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
            encoder.setRenderPipelineState(renderPipelineState)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

            encoder.endEncoding()
            cmdBuffer.present(drawable)
            cmdBuffer.commit()
        }
    }
    
}
