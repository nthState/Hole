//
//  Types.swift
//  HoleFramework
//
//  Created by Chris Davis on 14/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import Foundation

/**
 Integer based 2D Point
 */
public struct Point2D {
    let x: Int!
    let y: Int!
    
    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

/**
 Integer based with/height
 */
public typealias Size2D = (width: Int, height: Int)

/**
 Parameters used when using either App or Command line.
 */
public struct HoleParameters {
    public var inputImage: String!
    public var outputImage: String!
    public var processingType: String!
    public var z:Float!
    public var e:Float!
    public var holeAt: Point2D!
    public var holeSize: Size2D!
    
    public init() {}
}
