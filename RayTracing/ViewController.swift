//
//  ViewController.swift
//  RayTracing
//
//  Created by Apollo Zhu on 1/29/19.
//  Copyright © 2019 WWITDC. All rights reserved.
//

// Tutorial:
// http://metalkit.org/2016/03/21/ray-tracing-in-a-swift-playground.html
// http://metalkit.org/2016/03/28/ray-tracing-in-a-swift-playground-part-2.html

import Cocoa
import simd

// MARK: - Scene

let world: Targets = {
    var world = Targets()
    world.append(Sphere(center: Vector3(0, -100.5, -1), radius: 100))
    world.append(Sphere(center: Vector3(0, 0, -1), radius: 0.5))
    return world
}()

struct Sphere: Target {
    let center: Vector3
    let radius: Float
    
    func willBeHit(byRay ray: Ray, between tMin: Float, and tMax: Float) -> HitTestResut {
        let diff = ray.origin - center
        let a = dot(ray.direction, ray.direction)
        let b = 2 * dot(diff, ray.direction)
        let c = dot(diff, diff) - radius * radius
        let delta = b * b - 4 * a * c
        guard delta > 0 else { return .failure }
        var t = (-b - sqrt(delta)) / (2 * a)
        if t < tMin { t = (-b + sqrt(delta)) / (2 * a) }
        guard tMin < t && t < tMax else { return .failure }
        let p = ray[t]
        return .success(t: t, p: p, normal: (p - center) / Vector3(radius))
    }
}

enum HitTestResut {
    case success(t: Float, p: Vector3, normal: Vector3)
    case failure
}

protocol Target {
    func willBeHit(byRay ray: Ray, between tMin: Float, and tMax: Float) -> HitTestResut
}

typealias Targets = [Target]

extension Array: Target where Element == Target {
    func willBeHit(byRay ray: Ray, between tMin: Float, and tMax: Float) -> HitTestResut {
        for element in reversed() {
            let result = element.willBeHit(byRay: ray, between: tMin, and: tMax)
            if case .success = result { return result }
        }
        return .failure
    }
}

// MARK: - Coloring

let backgroundColor = Vector3(0.5, 0.7, 1)

extension Ray {
    func color(_ object: Target)-> Vector3 {
        switch object.willBeHit(byRay: self, between: 0.01, and: .infinity) {
        case let .success(_, p, normal):
            // MARK: Colored
            // return 0.5 * (normal + .one)
            // MARK: White Texture
            let target = p + normal + .randomWithInUnitSphere()
            return 0.5 * Ray(origin: p, direction: target - p).color(object)
        case .failure:
            let unitDirection = direction.unitVector
            let t = 0.5 * (unitDirection.y + 1)
            return (1 - t) * .one + t * backgroundColor
        }
    }
}

func colorForPixel(atI i: Float, j: Float, width: Float, height: Float) -> Pixel {
    var color = Vector3()
    let sampleCount = 10
    for _ in 0..<sampleCount {
        let dX = (i + .random()) / width
        let dY = (j + .random()) / height
        let ray = Camera.ray(dX: dX, dY: dY)
        color += ray.color(world)
    }
    color /= Vector3(Float(sampleCount))
    return Pixel(
        r: UInt8(color.x * 255),
        g: UInt8(color.y * 255),
        b: UInt8(color.z * 255)
    )
}

let a = 4 as Float
let b = 2 as Float

enum Camera {
    static let start = Vector3(-a/2, b/2, -1)
    static let vX = Vector3(a, 0, 0)
    static let vY = Vector3(0, -b, 0)
    static let origin = Vector3.zero
    static func ray(dX: Float, dY: Float) -> Ray {
        return Ray(origin: origin, direction: start + dX * vX + dY * vY)
    }
}

// MARK: - Foundamentals

struct Pixel {
    let r: UInt8
    let g: UInt8
    let b: UInt8
    let a: UInt8 = 255
}

extension Float {
    static func random() -> Float {
        return random(in: 0...1)
    }
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
    static func random() -> Vector3 {
        return Vector3(.random(), .random(), .random())
    }
    static func randomWithInUnitSphere() -> Vector3 {
        var result: Vector3
        repeat {
            result = 2 * .random() - .one
        } while dot(result, result) >= 1
        return result
    }
}

struct Ray {
    let origin: Vector3
    let direction: Vector3
    
    subscript(_ t: Float) -> Vector3 {
        return origin + t * direction
    }
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
