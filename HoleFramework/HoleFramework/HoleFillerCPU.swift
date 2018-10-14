//
//  HoleFillerCPU.swift
//  HoleFramework
//
//  Created by Chris Davis on 10/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import Foundation

public class HoleFillerCPU : HoleFillerProtocol {
    
    public var z: Float = 1.12                              // Weighting function pow()
    public var e: Float = 0.0001                            // Epsilon, a small value
    public var image: [[Float]]!                            // 2D Array of the image data
    public private(set) var visited: [[Float]]!             // Have we visited this point before?
    public private(set) var boundary: [[Float]]!            // The boundary
    public private(set) var boundaryPoints: [Point2D] = []  // Points that make the boundary
    public private(set) var missingPixels: [Point2D] = []   // Missing pixel locations
    
    public var rows: Int {
        return image.count
    }
    public var cols: Int {
        return image[0].count
    }
    
    // MARK:- Constructor
    
    required public init(image: [[Float]]) {
        self.image = image
        
        self.visited = Array(repeating: Array(repeating: 0, count: image[0].count), count: image.count)
        self.boundary = Array(repeating: Array(repeating: 0, count: image[0].count), count: image.count)
    }
    
    // MARK:- main method to call
    
    public func findHole() {
        walkToFindEdges()
    }
    
    // MARK:- Grid Helpers
    
    func isInBounds(point: Point2D) -> Bool {
        let inHorizontalBounds = point.x > -1 && point.x < image[0].count - 1
        let inVerticalBounds = point.y > -1 && point.y < image.count - 1
        return inHorizontalBounds && inVerticalBounds
    }
    
    func valueForPixel(_ point: Point2D) -> Float {
         if isInBounds(point: point) == false {
            return 0
        }
        return image[point.y][point.x]
    }
    
    // MARK:- Find the edges
    
    /**
     Find the edges of the hole
    */
    func walkToFindEdges() {
        
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
                
                let contains = [topLeft, top, topRight, left, right, bottomLeft, bottom, bottomRight].contains(-1)
                if contains && pixel != -1 {
                    boundary[row][col] = 1
                    boundaryPoints.append(Point2D(row, col))
                }
                if pixel == -1 {
                    missingPixels.append(Point2D(row, col))
                }
                
            }
        }
        
        DLog("CPU Boundary count: \(boundaryPoints.count)")
        DLog("CPU Missing pixel count: \(missingPixels.count)")
    }
    
    /**
     For every missing pixel, calculate a new pixel color
    */
    public func fillHole() {
        
        for i in missingPixels {
            let newValue = newPixel(missingPixel: i)
            image[i.x][i.y] = newValue
            
            assert(newValue != -1, "New value should have changed")
        }
    }
    
    /**
     For each missing pixel, calculate the new color
    */
    func newPixel(missingPixel: Point2D) -> Float {
        
        var dividends: Float = 0
        var divisors: Float = 0
        for i in boundaryPoints {

            let weight = weighting(boundaryPixel: i, missingPixel: missingPixel)
            dividends += weight * image[i.x][i.y]
            divisors += weight

        }
        let quotient = dividends / divisors

        return quotient
    }

    /**
     Weighting function
     Uses the distance between a boundary pixel and a missing pixel.
     
     _____1_____
     ||x−yi||z +ε
     */
    func weighting(boundaryPixel: Point2D, missingPixel: Point2D) -> Float {
        
        let xDistance = Float(missingPixel.x - boundaryPixel.x)
        let yDistance = Float(missingPixel.y - boundaryPixel.y)
        
        let distance = sqrt(xDistance*xDistance + yDistance*yDistance)

        return 1 / (pow(distance, z) + e)
    }
    
}

extension HoleFillerCPU {
    
    /**
     Helper function to help debug image data
     Prints image data as a 2D Array which we can copy/paste
     back into code
    */
    func printImageArray() -> String {
        var outer: [String] = []
        for row in 0..<rows {
            var inner: [String] = []
            for col in 0..<cols {
                let value = image[row][col]
                inner.append(String(format: "%.2f", value))
            }
            outer.append("[\(inner.joined(separator: ","))],\n")
        }
        return "[\(outer.joined(separator: ""))]"
    }
    
}

extension HoleFillerCPU {
    
    /**
     Create a hole in the image by setting a rectangluar area pixel
     values to -1
    */
    public func createSquareHole(at: Point2D, size: Size2D) {
        
        for row in (at.y)..<size.height+(at.y) {
            for col in (at.x)..<size.width+(at.x) {
                image[row][col] = -1
            }
        }
    }
    
}
