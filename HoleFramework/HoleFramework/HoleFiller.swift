//
//  HoleFiller.swift
//  HoleFramework
//
//  Created by Chris Davis on 10/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import Foundation

public typealias Point2D = (x:Int, y:Int)

public class HoleFiller {
    
    var image: [[Float]]!
    public var visited: [[Float]]!      // Have we visited this point before?
    var z: Float = 0
    var x: Point2D!                     // Missing pixel location
    var ε: Float = 0.00001              // Epsilon, a small value
    public var animated: Bool = false   // Animate step changes so we can see if it works
    public var boundary: [[Float]]!     // The boundary
    public private(set) var boundaryPixelCount: Int = 0
    public private(set) var pixelCount: Int = 0
    
    public var rows: Int {
        return image.count
    }
    public var cols: Int {
        return image[0].count
    }
    
    // MARK:- Constructor
    
    public init(image: [[Float]]) {
        self.image = image
        
        self.visited = Array(repeating: Array(repeating: 0, count: image[0].count), count: image.count)
        self.boundary = Array(repeating: Array(repeating: 0, count: image[0].count), count: image.count)
    }
    
    // MARK:- main method to call
    
    public func findHole() {
        
        //let start: Point2D = (0,0)
        //walkToFindEdge(from: start)
        walkToFindEdges()
    }
    
    // MARK:- Helpers
    
    func isInBounds(point: Point2D) -> Bool {
        let inHorizontalBounds = point.x > -1 && point.x < image[0].count
        let inVerticalBounds = point.y > -1 && point.y < image.count
        return inHorizontalBounds && inVerticalBounds
    }
    
    func valueForPixel(_ point: Point2D) -> Float {
         if isInBounds(point: point) == false {
            return 0
        }
        return image[point.y][point.x]
    }
    
    // MARK:- Recursive algorithm
    
    func walkToFindEdges() {
        
        pixelCount = 0
        boundaryPixelCount = 0
        self.boundary = Array(repeating: Array(repeating: 0, count: image[0].count), count: image.count)
        
        for row in 0..<rows {
            for col in 0..<cols {
                
                
                let bottomLeft = valueForPixel(Point2D(col - 1, row + 1))
                let bottom = valueForPixel(Point2D(col, row + 1))
                let bottomRight = valueForPixel(Point2D(col + 1, row + 1))
                
                let left = valueForPixel(Point2D(col - 1, row))
                let pixel = image[row][col]
                let right = valueForPixel(Point2D(col + 1, row))
                
                let topLeft = valueForPixel(Point2D(col - 1, row - 1))
                let top = valueForPixel(Point2D(col, row - 1))
                let topRight = valueForPixel(Point2D(col + 1, row - 1))
                
                let sum = topLeft + top + topRight + left + right + bottomLeft + bottom + bottomRight
                if sum < 0 && pixel != -1 {
                    boundary[row][col] = 1
                    boundaryPixelCount += 1
                }
                if pixel == -1 {
                    pixelCount += 1
                }
                
            }
        }
        
        DLog("Boundary count: \(boundaryPixelCount)")
        DLog("Missing pixel count: \(pixelCount)")
        
    }
    
    func walkToFindEdge(from: Point2D) {
        
        DLog(from)

        if isInBounds(point: from) == false {
            return
        }

        if animated {
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        let pixel = image[from.y][from.x]
        
        // Have we visited
        if visited[from.y][from.x] > 0 {
            return
        }
        visited[from.y][from.x] = 1
        
        if pixel == -1 {
            return
        }
        
        
        let topLeft = valueForPixel(Point2D(from.y - 1, from.x + 1))
        let top = valueForPixel(Point2D(from.y, from.x + 1))
        let topRight = valueForPixel(Point2D(from.y + 1, from.x + 1))
        let left = valueForPixel(Point2D(from.y - 1, from.x))
        // pixel itself
        let right = valueForPixel(Point2D(from.y + 1, from.x))
        let bottomLeft = valueForPixel(Point2D(from.y - 1, from.x - 1))
        let bottom = valueForPixel(Point2D(from.y, from.x - 1))
        let bottomRight = valueForPixel(Point2D(from.y + 1, from.x - 1))
        
        let sum = topLeft + top + topRight + left + right + bottomLeft + bottom + bottomRight
        if sum < 0 {
            boundary[from.y][from.x] = 1
        }
        
        let north = Point2D(from.y, from.x + 1)
        let south = Point2D(from.y, from.x - 1)
        let east = Point2D(from.y + 1, from.x)
        let west = Point2D(from.y - 1, from.x)
        
        walkToFindEdge(from: north)
        walkToFindEdge(from: south)
        walkToFindEdge(from: east)
        walkToFindEdge(from: west)
    }
    
//    func walkAlongEdge(from: Point2D) {
//
//        if isInBounds(point: from) == false {
//            return
//        }
//
//        // Have we visited
//        if visited[from.x][from.y] > 0 {
//            return
//        }
//        visited[from.x][from.y] = 1
//
//        let pixel = image[from.x][from.y]
//
//
//
//
//
//        let topLeft = image[from.x - 1][from.y + 1]
//        let topRight = image[from.x + 1][from.y + 1]
//        let bottomLeft = image[from.x - 1][from.y - 1]
//        let bottomRight = image[from.x + 1][from.y - 1]
//
//        let isEdge = [topLeft, topRight, bottomLeft, bottomRight].contains(0)
//
//        // We have found an edge pixel
//        if isEdge {
//            boundary[from.x][from.y] = 1
//        }
//
//    }
    
}
