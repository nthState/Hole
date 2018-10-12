//
//  ImageConverter.swift
//  HoleFramework
//
//  Created by Chris Davis on 12/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import Foundation
import CoreImage

class ImageConverter {
    
    class func convertImageTo2DPixelArray(cgImage: CGImage) -> ([[Float]], Int, Int) {
        
        let width = cgImage.width
        let height = cgImage.height
        
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let totalBytes = height * bytesPerRow
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        var intensities = [UInt8](repeating: 0, count: totalBytes)
        
        let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
        contextRef?.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
        
        var pixelArray: [[Float]] = Array(repeating: Array(repeating: 0, count: width), count: height)
        for row in 0..<height {
            for col in 0..<width {
                pixelArray[row][col] = Float(intensities[(row * bytesPerRow) + col]) / 255.0
            }
        }
        
        return (pixelArray, width, height)
    }
    
}
