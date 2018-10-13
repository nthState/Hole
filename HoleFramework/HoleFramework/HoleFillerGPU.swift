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

public class HoleFillerGPU {
    
    public var z: Float = 1.12                              // Weighting function pow()
    public var e: Float = 0.0001                            // Epsilon, a small value
    
    public var image: [[Float]]!                            // 2D Array of the image data
    
    
    var device: MTLDevice!                                  // Metal device, the GPU
    var defaultLibrary: MTLLibrary!
    var commandQueue: MTLCommandQueue!
    var findEdgesFunction:MTLFunction?
    var findEdgesPipeline: MTLComputePipelineState!
    /// Threading
    var threadsPerThreadgroup:MTLSize!
    /// Thread Groups
    var threadgroupsPerGrid: MTLSize!
    
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
        var length = image1D.count * MemoryLayout< Float >.size
        let inBuffer = device.makeBuffer(bytes: image1D, length: length, options: [])
        let outBuffer = device.makeBuffer(length: length, options: MTLResourceOptions.storageModeManaged)
        
        let width: [Int] = [self.cols]
        let bufferWidth = device.makeBuffer(bytes: width, length: MemoryLayout<Int>.size, options: [])
        
        let height: [Int] = [self.rows]
        let bufferHeight = device.makeBuffer(bytes: height, length: MemoryLayout<Int>.size, options: [])
        
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
        
        let computeOutputs = unsafeBitCast(outBuffer!.contents(), to: UnsafeMutablePointer<Float>.self)
        
        var x = outBuffer!.length
        x += 1
        
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
