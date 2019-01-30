//
//  ViewController.swift
//  RayTracing
//
//  Created by Apollo Zhu on 1/29/19.
//  Copyright © 2019 WWITDC. All rights reserved.
//

// Tutorial: http://metalkit.org/2016/03/21/ray-tracing-in-a-swift-playground.html

import Cocoa
import simd

// MARK: Coloring

extension Ray {
    subscript(_ t: Float) -> Vector3 {
        return origin + t * direction
    }
    
    func timeHittingSphere(centeredAt center: Vector3, withRadius radius: Float) -> Float {
        let diff = origin - center
        let a = dot(direction, direction)
        let b = 2 * dot(diff, direction)
        let c = dot(diff, diff) - radius * radius
        let delta = b * b - 4 * a * c
        if delta < 0 {
            return -1
        } else {
            return (-b - sqrt(delta)) / (2 * a)
        }
    }
    
    var color: Vector3 {
        let minusZ = Vector3(0, 0, -1)
        var t = timeHittingSphere(centeredAt: minusZ, withRadius: 0.5)
        if t > 0 {
            let norm = (self[t] - minusZ).unitVector
            return 0.5 * (norm + .one)
        } else {
            let unitDirection = direction.unitVector
            t = 0.5 * (unitDirection.y + 1)
            return (1 - t) * .one + t * Vector3(0.5, 0.7, 1)
        }
    }
}

let bottomLeft = Vector3(-2, 1, -1)
let horizontal = Vector3(4, 0, 0)
let vertical = Vector3(0, -2, 0)

func colorForPixel(atI i: Float, j: Float, width: Float, height: Float) -> Pixel {
    let u = i / width
    let v = j / height
    let ray = Ray(origin: .zero, direction: bottomLeft + u * horizontal + v * vertical)
    let color = ray.color
    return Pixel(
        r: UInt8(color.x * 255),
        g: UInt8(color.y * 255),
        b: UInt8(color.z * 255)
    )
}

// MARK: - Foundamentals

struct Pixel {
    let r: UInt8
    let g: UInt8
    let b: UInt8
    let a: UInt8 = 255
}

typealias Vector3 = float3

func dot (_ lhs: Vector3, _ rhs: Vector3) -> Float {
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
}

extension float3 {
    var unitVector: Vector3 {
        let length = sqrt(dot(self, self))
        return Vector3(x / length, y / length, z / length)
    }
    
    static let one = Vector3(1, 1, 1)
    static let zero = Vector3()
}

struct Ray {
    let origin: Vector3
    let direction: Vector3
}

struct Image {
    let width: Int
    let height: Int
    let pixels: [Pixel]
    
    var nsImage: NSImage {
        let bytesPerPixel = MemoryLayout<Pixel>.size
        let ciImage = CIImage(
            bitmapData: Data(bytes: pixels, count: pixels.count * bytesPerPixel),
            bytesPerRow: width * bytesPerPixel,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        let representation = NSCIImageRep(ciImage: ciImage)
        let nsImage = NSImage(size: representation.size)
        nsImage.addRepresentation(representation)
        return nsImage
    }
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        var pixels = [Pixel]()
        pixels.reserveCapacity(width * height)
        let fW = Float(width), fH = Float(height)
        for j in stride(from: 0, to: fH, by: 1) {
            for i in stride(from: 0, to: fW, by: 1) {
                pixels.append(colorForPixel(atI: i, j: j, width: fW, height: fH))
            }
        }
        self.pixels = pixels
    }
}

class ViewController: NSViewController {
    @IBOutlet weak var imageView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = Image(width: 800, height: 400)
        imageView.image = image.nsImage
    }
}
