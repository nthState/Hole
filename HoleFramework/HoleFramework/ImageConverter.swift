//
//  ImageConverter.swift
//  HoleFramework
//
//  Created by Chris Davis on 12/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import Foundation
import CoreImage

public class ImageConverter {
    
    public class func pathToCGImage(path: String) -> CGImage? {
        let url = URL(fileURLWithPath: path)
        let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }
    
    @discardableResult
    public class func save(cgImage: CGImage, to: String) -> Bool {
        let url = URL(fileURLWithPath: to)
        guard let dst = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, 1, nil) else { return false }
        CGImageDestinationAddImage(dst, cgImage, nil)
        return CGImageDestinationFinalize(dst)
    }
    
    public class func convertImageTo2DPixelArray(cgImage: CGImage) -> ([[Float]], Int, Int) {
        
        let width = cgImage.width
        let height = cgImage.height
        
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let totalBytes = height * bytesPerRow
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        var intensities = [UInt8](repeating: 0, count: totalBytes)
        
        let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
        contextRef?.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
        
        // Convert 1D Array to 2D
        var pixelArray: [[Float]] = Array(repeating: Array(repeating: 0, count: width), count: height)
        for row in 0..<height {
            for col in 0..<width {
                pixelArray[row][col] = Float(intensities[(row * bytesPerRow) + col]) / 255.0
            }
        }
        
        return (pixelArray, width, height)
    }
    
    public class func convert2DPixelArrayToImage(array2D: [[Float]], width: Int, height: Int) -> CGImage? {
        
        let bitsPerComponent = 8
        let bytesPerRow = width * 4
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)!
        let buffer = context.data!
        let pixelBuffer = buffer.bindMemory(to: UInt8.self, capacity: width * height)
        
        for row in 0..<height {
            for col in 0..<width {
                let index = (row * bytesPerRow) + col
                pixelBuffer[index] = UInt8(array2D[row][col] * 255)
            }
        }
        
        return context.makeImage()
    }
    
}
