//
//  GenerationTests.swift
//  HoleFrameworkTests
//
//  Created by Chris Davis on 12/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import XCTest
@testable import HoleFramework

class GenerationTests : XCTestCase {
    
    func test_use_real_image() {
        
        // Arrange
        
        let bundle = Bundle(for: ProcessTests.self)
        let url = bundle.url(forResource: "eggs", withExtension: "png")!
        
        let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)!
        
        let (imageData, width, height) = ImageConverter.convertImageTo2DPixelArray(cgImage: cgImage)
        
        let holeFiller = HoleFiller(image: imageData)
        
        // Create a hole in the image data
        holeFiller.createSquareHole(at: Point2D(1, 1), width: 2, height: 2)
        
        let debug = holeFiller.printImageArray()
        print(debug)
        
        // Act
        holeFiller.findHole()
        holeFiller.fillMissingPixels()
        
        let x = ImageConverter.convert2DPixelArrayToImage(array2D: holeFiller.image, width: width, height: height)
        
        // Assert
        XCTAssertEqual(holeFiller.boundaryPixelCount, 12)
    }
    
}
