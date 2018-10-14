//
//  HoleFiller.swift
//  HoleFramework
//
//  Created by Chris Davis on 14/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import Foundation

public protocol HoleFillerProtocol {
    var z: Float { get set }
    var e: Float { get set }
    var image: [[Float]]! { get set }
    init(image: [[Float]])
    func findHole()
    func fillHole()
    func createSquareHole(at: Point2D, size: Size2D)
}

/**
 Create either the CPU or GPU based implementation
 */
public class HoleFiller {
    
    public class func create(image: [[Float]], processingType: String) -> HoleFillerProtocol {
        switch processingType.lowercased() {
        case "cpu":
            return HoleFillerCPU(image: image)
        case "gpu":
            return HoleFillerGPU(image: image)
        default:
            fatalError("no processing type specified")
        }
    }
}
