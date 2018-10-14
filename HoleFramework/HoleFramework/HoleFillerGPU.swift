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

public class HoleFillerGPU {
    
    public var z: Float = 1.12                              // Weighting function pow()
    public var e: Float = 0.0001                            // Epsilon, a small value
    
    public var image: [[Float]]!                            // 2D Array of the image data
    public private(set) var boundaryPoints: [PointWithValue2D] = []  // Points that make the boundary
    public private(set) var missingPixels: [Point2D] = []   // Missing pixel locations
    
    
    var device: MTLDevice!                                  // Metal device, the GPU
    var defaultLibrary: MTLLibrary!
    var commandQueue: MTLCommandQueue!
    var findEdgesFunction:MTLFunction?
    var findEdgesPipeline: MTLComputePipelineState!
    var fillHoleFunction:MTLFunction?
    var fillHolePipeline: MTLComputePipelineState!
    var threadsPerThreadgroup:MTLSize!                      /// Threading
    var threadgroupsPerGrid: MTLSize!                       /// Thread Groups
    
    public var rows: Int {
        return image.count
    }
    public var cols: Int {
        return image[0].count
    }
    
    // MARK:- Constructor
    
    public init(image: [[Float]]) {
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
    
    public func findHole() {
        
//        let w = findEdgesPipeline.threadExecutionWidth
//        let h = findEdgesPipeline.maxTotalThreadsPerThreadgroup / w
//        threadsPerThreadgroup = MTLSizeMake(w, h, 1)
//
//        let widthInThreadgroups = (cols + threadsPerThreadgroup.width - 1) / threadsPerThreadgroup.width
//        let heightInThreadgroups = (rows + threadsPerThreadgroup.height - 1) / threadsPerThreadgroup.height
//        threadgroupsPerGrid = MTLSizeMake(widthInThreadgroups, heightInThreadgroups, 1)
        
        
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
                //image[y][x] = -1
                missingPixels.append(Point2D(x,y))
            }
        }
        let duration = CFAbsoluteTimeGetCurrent()-start
        DLog("Loop Duration: \(duration)")
        
        DLog("Boundary count: \(boundaryPoints.count)")
        DLog("Missing pixel count: \(missingPixels.count)")
        
    }
    
    public func fillHole() {
        
    
        
//        threadsPerThreadgroup = MTLSizeMake(1, 1, 1);
//        threadgroupsPerGrid = MTLSizeMake(cols / threadsPerThreadgroup.width,
//                                          rows / threadsPerThreadgroup.height,
//                                          1);
        
        var pts: [PointWithValue2D] = boundaryPoints
        let boundaryLength = boundaryPoints.count * MemoryLayout<PointWithValue2D>.stride
        let boundaryBuffer = device.makeBuffer(bytes: pts, length: boundaryLength, options: [])
        
//        let test = boundaryBuffer!.contents().bindMemory(to: PointWithValue2D.self, capacity: boundaryPoints.count)
//
//        withUnsafePointer(to: &pts) { print($0) }
//        print(boundaryBuffer?.contents())
//
//        withUnsafePointer(to: &test[0]) {
//            print(" str value has address: \($0)")
//        }
//        withUnsafePointer(to: &test[1]) {
//            print(" str value has address: \($0)")
//        }
        
        var missing: [uint2] = missingPixels.compactMap({ uint2(UInt32($0.x), UInt32($0.y)) })
        let missingLength = missingPixels.count * MemoryLayout<uint2>.stride
        let missingBuffer = device.makeBuffer(bytes: missing, length: missingLength, options: [])
        
        let image1D: [Float] = image.flatMap { $0 }
        let length = image1D.count * MemoryLayout<Float>.stride
        let inBuffer = device.makeBuffer(bytes: image1D, length: length, options: [])
        let outBuffer = device.makeBuffer(length: length, options: MTLResourceOptions.storageModeManaged)
        
        let width: [Int] = [self.cols]
        let bufferWidth = device.makeBuffer(bytes: width, length: MemoryLayout<Int>.stride, options: [])
        
        let height: [Int] = [self.rows]
        let bufferHeight = device.makeBuffer(bytes: height, length: MemoryLayout<Int>.stride, options: [])
        
        let missingPixelCount: [Int] = [missingPixels.count]
        let bufferMissingPixelCount = device.makeBuffer(bytes: missingPixelCount, length: MemoryLayout<Int>.stride, options: [])
        
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
        //commandEncoder.setBuffer(missingBuffer, offset: 0, index: 1)
        commandEncoder.setBuffer(inBuffer, offset: 0, index: 2)
        commandEncoder.setBuffer(outBuffer, offset: 0, index: 3)
        commandEncoder.setBuffer(bufferWidth, offset: 0, index: 4)
        commandEncoder.setBuffer(bufferHeight, offset: 0, index: 5)
        commandEncoder.setBuffer(bufferMissingPixelCount, offset: 0, index: 6)
        commandEncoder.setBuffer(bufferBoundaryCount, offset: 0, index: 7)
        commandEncoder.setBuffer(bufferZ, offset: 0, index: 8)
        commandEncoder.setBuffer(bufferE, offset: 0, index: 9)
        
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
