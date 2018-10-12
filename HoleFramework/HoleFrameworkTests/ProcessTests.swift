//
//  ProcessTests.swift
//  HoleFrameworkTests
//
//  Created by Chris Davis on 12/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import XCTest
@testable import HoleFramework

class ProcessTests : XCTestCase {
    
    func test_use_real_image() {
        
        // Arrange
        
        let bundle = Bundle(for: ProcessTests.self)
        let url = bundle.url(forResource: "eggs", withExtension: "png")!

        let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)!
       
        let (imageData, _, _) = ImageConverter.convertImageTo2DPixelArray(cgImage: cgImage)
        
        let holeFiller = HoleFiller(image: imageData)
        
        // Create a hole in the image data
        holeFiller.createSquareHole(at: Point2D(1, 1), width: 2, height: 2)
        
        let debug = holeFiller.printImageArray()
        print(debug)
        
        // Act
        holeFiller.findHole()
        
        // Assert
        XCTAssertEqual(holeFiller.boundaryPixelCount, 12)
    }
    
    func test_use_long_real_image() {
        
        // Arrange
        
        let bundle = Bundle(for: ProcessTests.self)
        let url = bundle.url(forResource: "halfEggs", withExtension: "png")!
        
        let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)!
        
        let (imageData, _, _) = ImageConverter.convertImageTo2DPixelArray(cgImage: cgImage)
        
        let holeFiller = HoleFiller(image: imageData)
        
        // Create a hole in the image data
        holeFiller.createSquareHole(at: Point2D(1, 1), width: 2, height: 2)
        
        let debug = holeFiller.printImageArray()
        print(debug)
        
        // Act
        holeFiller.findHole()
        
        // Assert
        XCTAssertEqual(holeFiller.boundaryPixelCount, 12)
    }
    
}

