//
//  MetalView.swift
//  Part5
//
//  Created by Apollo Zhu on 1/28/19.
//  Copyright © 2019 WWITDC. All rights reserved.

//  Tutorial: http://metalkit.org/2016/02/08/using-metalkit-part-5.html

import Cocoa
import MetalKit
import SceneKit

typealias Matrix4 = CATransform3D

extension CATransform3D {
    static var identity = CATransform3DIdentity
    
    /*
     1 0 0 x
     0 1 0 y
     0 0 1 z
     */
    func translated(toX x: Float, y: Float, z: Float) -> Matrix4 {
        return CATransform3DTranslate(self, CGFloat(x), CGFloat(y), CGFloat(z))
    }
    
    /*
     c, 0, 0, 0
     0, c, 0, 0
     0, 0, c, 0
     0, 0, 0, 1
     */
    func scaled(by scalar: Float) -> Matrix4 {
        let scale = CGFloat(scalar)
        return CATransform3DScale(self, scale, scale, scale)
    }
    
    /// Returns a rotated 4x4 matrix by rotating self around origin along the axis.
    ///
    /// - Parameters:
    ///   - x: radians rotating around x axis.
    ///   - y: radians rotating around y axis.
    ///   - z: radians rotating around z axis.
    /// - Returns: the matrix resulted from rotation.
    ///
    /// Axis and rotation directions:
    /// ```
    ///   ⤾Y
    ///    │
    ///    │
    ///    ┼─── ⟳X
    ///   /
    ///  /
    /// Z⟳
    /// ```
    func rotatedAroundOrigin(byRadianAlongAxisX x: Float, y: Float, z: Float) -> Matrix4 {
        let x = CGFloat(x), y = CGFloat(y), z = CGFloat(z)
        /* Transformation Matrices:
         ## X-axis:
         1  0    0  0
         0 cos -sin 0
         0 sin  cos 0
         0  0    0  1
         
         ## Y-axis:
          cos 0 sin 0
           0  1  0  0
         -sin 0 cos 0
           0  0  0  1
         
         ## Z-axis:
         cos -sin 0 0
         sin  cos 0 0
          0    0  1 0
          0    0  0 1
         */
        return CATransform3DConcat(self, CATransform3DConcat(
            CATransform3DConcat(
                CATransform3D(
                    m11: 1, m12: 0, m13: 0, m14: 0,
                    m21: 0, m22: cos(x), m23: -sin(x), m24: 0,
                    m31: 0, m32: sin(x), m33: cos(x), m34: 0,
                    m41: 0, m42: 0, m43: 0, m44: 1),
                CATransform3D(
                    m11: cos(y), m12: 0, m13: sin(y), m14: 0,
                    m21: 0, m22: 1, m23: 0, m24: 0,
                    m31: -sin(y), m32: 0, m33: cos(y), m34: 0,
                    m41: 0, m42: 0, m43: 0, m44: 1)
            ), CATransform3D(
                m11: cos(z), m12: -sin(z), m13: 0, m14: 0,
                m21: sin(z), m22: cos(z), m23: 0, m24: 0,
                m31: 0, m32: 0, m33: 1, m34: 0,
                m41: 0, m42: 0, m43: 0, m44: 1
        )))
    }
}

struct Vertex {
    var position: vector_float4
    var color: vector_float4
}

class MetalView: MTKView {
    lazy var vertexBuffer: MTLBuffer = {
        let vertexData: [Vertex] = [
            Vertex(position: [-1.0, -1.0, 0.0, 1.0], color: [1, 0, 0, 1]),
            Vertex(position: [ 1.0, -1.0, 0.0, 1.0], color: [0, 1, 0, 1]),
            Vertex(position: [ 0.0,  1.0, 0.0, 1.0], color: [0, 0, 1, 1])
        ]
        let length = vertexData.count * MemoryLayout<Vertex>.size
        return self.device!.makeBuffer(bytes: vertexData, length: length)!
    }()
    
    /// A transformation applied to the entire model
    lazy var uniformBuffer: MTLBuffer = {
        let count = MemoryLayout<Float>.size * 16
        let buffer = device!.makeBuffer(length: count, options: [])!
        let bufferPtr = buffer.contents()
        let transformation = Matrix4.identity
            .translated(toX: 0, y: 0.5, z: 0)
            .scaled(by: 0.25)
            .rotatedAroundOrigin(byRadianAlongAxisX: 0, y: 0, z: -0.1)
        _ = withUnsafePointer(to: float4x4(transformation)) {
            memcpy(bufferPtr, $0, count)
        }
        return buffer
    }()
    
    lazy var renderPipelineState: MTLRenderPipelineState = {
        let library = self.device!.makeDefaultLibrary()!
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "vertex_function")
        descriptor.fragmentFunction = library.makeFunction(name: "fragment_function")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        return try! self.device!.makeRenderPipelineState(descriptor: descriptor)
    }()
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        device = MTLCreateSystemDefaultDevice()
    }
    
    lazy var cmdQ = self.device!.makeCommandQueue()!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let drawable = currentDrawable
            , let descriptor = currentRenderPassDescriptor
            else { return }
        let buffer = cmdQ.makeCommandBuffer()!
        let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor)!
        
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        // MARK: Pass the uniform buffer to vertex shader
        encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        encoder.setRenderPipelineState(renderPipelineState)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        encoder.endEncoding()
        buffer.present(drawable)
        buffer.commit()
    }
}
