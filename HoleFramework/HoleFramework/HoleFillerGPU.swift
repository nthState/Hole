//
//  HoleFillerGPU.swift
//  HoleFramework
//
//  Created by Chris Davis on 13/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import Foundation
import Metal
import MetalKit

/**
 A 2D point with a value, sent to the Metal compute function
 */
public struct PointWithValue2D {
    let x: uint!
    let y: uint!
    let value: Float!
    
    public init(_ x: uint, _ y: uint, _ value: Float) {
        self.x = x
        self.y = y
        self.value = value
    }
}

public class HoleFillerGPU : HoleFillerProtocol {
    
    public var z: Float = 1.12                              // Weighting function pow()
    public var e: Float = 0.0001                            // Epsilon, a small value
    public var image: [[Float]]!                            // 2D Array of the image data
    public private(set) var boundaryPoints: [PointWithValue2D] = []  // Points that make the boundary
    public private(set) var missingPixels: [Point2D] = []   // Missing pixel locations
    
    var device: MTLDevice!
    var defaultLibrary: MTLLibrary!
    var commandQueue: MTLCommandQueue!
    var findEdgesFunction:MTLFunction?                      // Edges function
    var findEdgesPipeline: MTLComputePipelineState!
    var fillHoleFunction:MTLFunction?                       // Fill hole function
    var fillHolePipeline: MTLComputePipelineState!
    var threadsPerThreadgroup:MTLSize!
    var threadgroupsPerGrid: MTLSize!
    
    public var rows: Int {
        return image.count
    }
    public var cols: Int {
        return image[0].count
    }
    
    // MARK:- Constructor
    
    required public init(image: [[Float]]) {
        self.image = image
        
        configureMetal()
    }
    
    func configureMetal() {
        device = MTLCreateSystemDefaultDevice()
        defaultLibrary = device!.makeDefaultLibrary()!
        commandQueue = device!.makeCommandQueue()
        
        findEdgesFunction = defaultLibrary.makeFunction(name: "findEdges")
        do {
            findEdgesPipeline = try device!.makeComputePipelineState(function: findEdgesFunction!)
        }
        catch {
            fatalError("Unable to create pipeline state")
        }
        
        fillHoleFunction = defaultLibrary.makeFunction(name: "fillHole")
        do {
            fillHolePipeline = try device!.makeComputePipelineState(function: fillHoleFunction!)
        }
        catch {
            fatalError("Unable to create pipeline state")
        }
        
    }
    
    /**
     Send image data as 1D array to compute,
     Work on 3x3 chunks
    */
    public func findHole() {

        threadsPerThreadgroup = MTLSizeMake(3, 3, 1);
        threadgroupsPerGrid = MTLSizeMake(cols / threadsPerThreadgroup.width,
                                   rows / threadsPerThreadgroup.height,
                                   1);
        
        let image1D: [Float] = image.flatMap { $0 }
        let length = image1D.count * MemoryLayout<Float>.stride
        let inBuffer = device.makeBuffer(bytes: image1D, length: length, options: [])
        let outBuffer = device.makeBuffer(length: length, options: MTLResourceOptions.storageModeManaged)
        
        let width: [Int] = [self.cols]
        let bufferWidth = device.makeBuffer(bytes: width, length: MemoryLayout<Int>.stride, options: [])
        
        let height: [Int] = [self.rows]
        let bufferHeight = device.makeBuffer(bytes: height, length: MemoryLayout<Int>.stride, options: [])
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(findEdgesPipeline)
        commandEncoder.setBuffer(inBuffer, offset: 0, index: 0)
        commandEncoder.setBuffer(outBuffer, offset: 0, index: 1)
        commandEncoder.setBuffer(bufferWidth, offset: 0, index: 2)
        commandEncoder.setBuffer(bufferHeight, offset: 0, index: 3)
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder.endEncoding()
        commandBuffer.commit();
        commandBuffer.waitUntilCompleted()
        
        let computeOutputs = outBuffer!.contents().bindMemory(to: Float.self, capacity: length)
        
        boundaryPoints = []
        missingPixels = []
        
        // Scan results into boundaries, and missing pixels
        let start = CFAbsoluteTimeGetCurrent()
        for i in 0..<(self.cols*self.rows) {
            
            let x = i % self.cols
            let y = i / self.cols
            
            if computeOutputs[i] == 1 {
                let value = image1D[i]
                boundaryPoints.append(PointWithValue2D(uint(x),uint(y),value))
                assert(value != -1)
            }
            if image1D[i] == -1 {
                missingPixels.append(Point2D(x,y))
            }
        }
        let duration = CFAbsoluteTimeGetCurrent()-start
        DLog("GPU Loop Duration: \(duration)")
        
        DLog("GPU Boundary count: \(boundaryPoints.count)")
        DLog("GPU Missing pixel count: \(missingPixels.count)")
        
    }
    
    public func fillHole() {
    
        let pts: [PointWithValue2D] = boundaryPoints
        let boundaryLength = boundaryPoints.count * MemoryLayout<PointWithValue2D>.stride
        let boundaryBuffer = device.makeBuffer(bytes: pts, length: boundaryLength, options: [])

        let image1D: [Float] = image.flatMap { $0 }
        let length = image1D.count * MemoryLayout<Float>.stride
        let inBuffer = device.makeBuffer(bytes: image1D, length: length, options: [])
        let outBuffer = device.makeBuffer(length: length, options: MTLResourceOptions.storageModeManaged)
        
        let width: [Int] = [self.cols]
        let bufferWidth = device.makeBuffer(bytes: width, length: MemoryLayout<Int>.stride, options: [])
        
        let boundaryCount: [Int] = [boundaryPoints.count]
        let bufferBoundaryCount = device.makeBuffer(bytes: boundaryCount, length: MemoryLayout<Int>.stride, options: [])
        
        let zArray: [Float] = [z]
        let bufferZ = device.makeBuffer(bytes: zArray, length: MemoryLayout<Float>.stride, options: [])
        
        let eArray: [Float] = [e]
        let bufferE = device.makeBuffer(bytes: eArray, length: MemoryLayout<Float>.stride, options: [])
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(fillHolePipeline)
        commandEncoder.setBuffer(boundaryBuffer, offset: 0, index: 0)
        commandEncoder.setBuffer(inBuffer, offset: 0, index: 1)
        commandEncoder.setBuffer(outBuffer, offset: 0, index: 2)
        commandEncoder.setBuffer(bufferWidth, offset: 0, index: 3)
        commandEncoder.setBuffer(bufferBoundaryCount, offset: 0, index: 4)
        commandEncoder.setBuffer(bufferZ, offset: 0, index: 5)
        commandEncoder.setBuffer(bufferE, offset: 0, index: 6)
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder.endEncoding()
        commandBuffer.commit();
        commandBuffer.waitUntilCompleted()
        
        let computeOutputs = outBuffer!.contents().bindMemory(to: Float.self, capacity: length)
        
        DLog("\(computeOutputs[0]) \(computeOutputs[1])")
        DLog("\(computeOutputs[3]) \(computeOutputs[4])")

        for i in 0..<(self.cols*self.rows) {
            
            let x = i % (self.cols)
            let y = i / (self.cols)
            
            if computeOutputs[i] != 0 {
                image[y][x] = computeOutputs[i]
            }
        }
    }
    
}

extension HoleFillerGPU {
    
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
