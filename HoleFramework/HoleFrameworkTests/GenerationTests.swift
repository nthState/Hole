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
        holeFiller.createSquareHole(at: Point2D(1, 1), size: Size2D(5, 5))
        
        let debug = holeFiller.printImageArray()
        //print(debug)
        
        // Act
        holeFiller.findHole()
        holeFiller.fillHole()
        
        let outputImage = ImageConverter.convert2DPixelArrayToImage(array2D: holeFiller.image, width: width, height: height)
        
        // Assert
        //XCTAssertEqual(holeFiller.boundaryPixelCount, 12)
    }
    
    func test_use_real_image2() {
        
        // Arrange
        
        let bundle = Bundle(for: ProcessTests.self)
        let url = bundle.url(forResource: "grey1", withExtension: "png")!
        
        let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)!
        
        let (imageData, width, height) = ImageConverter.convertImageTo2DPixelArray(cgImage: cgImage)
        
        let holeFiller = HoleFiller(image: imageData)
        
        // Create a hole in the image data
        holeFiller.createSquareHole(at: Point2D(100, 100), size: Size2D(50,50))
        
        let debug = holeFiller.printImageArray()
        //print(debug)
        
        // Act
        holeFiller.findHole()
        holeFiller.fillHole()
        
        let outputImage = ImageConverter.convert2DPixelArrayToImage(array2D: holeFiller.image, width: width, height: height)
        
        // Assert
        //XCTAssertEqual(holeFiller.boundaryPixelCount, 12)
    }
    
    func test_use_real_image3() {
        
        // Arrange
        
        let bundle = Bundle(for: ProcessTests.self)
        let url = bundle.url(forResource: "grey1", withExtension: "png")!
        
        let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)!
        
        let (imageData, width, height) = ImageConverter.convertImageTo2DPixelArray(cgImage: cgImage)
        
        let holeFiller = HoleFiller(image: imageData)
        
        // Create a hole in the image data
        holeFiller.createSquareHole(at: Point2D(300, 300), size: Size2D(100, 100))
        
        let debug = holeFiller.printImageArray()
        //print(debug)
        
        // Act
        holeFiller.findHole()
        holeFiller.fillHole()
        
        let outputImage = ImageConverter.convert2DPixelArrayToImage(array2D: holeFiller.image, width: width, height: height)
        
        // Assert
        //XCTAssertEqual(holeFiller.boundaryPixelCount, 12)
    }
    
    func test_use_real_image4() {
        
        // Arrange
        
        let bundle = Bundle(for: ProcessTests.self)
        let url = bundle.url(forResource: "grey2", withExtension: "png")!
        
        let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)!
        
        let (imageData, width, height) = ImageConverter.convertImageTo2DPixelArray(cgImage: cgImage)
        
        let holeFiller = HoleFiller(image: imageData)
        
        // Create a hole in the image data
        holeFiller.createSquareHole(at: Point2D(260, 260), size: Size2D(100, 100))
        
        let debug = holeFiller.printImageArray()
        //print(debug)
        
        // Act
        holeFiller.findHole()
        holeFiller.fillHole()
        
        let outputImage = ImageConverter.convert2DPixelArrayToImage(array2D: holeFiller.image, width: width, height: height)
        
        // Assert
        //XCTAssertEqual(holeFiller.boundaryPixelCount, 12)
    }
    
    func test_use_real_image5() {
        
        // Arrange
        
        let bundle = Bundle(for: ProcessTests.self)
        let url = bundle.url(forResource: "grey3", withExtension: "png")!
        
        let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)!
        
        let (imageData, width, height) = ImageConverter.convertImageTo2DPixelArray(cgImage: cgImage)
        
        let holeFiller = HoleFiller(image: imageData)
//        holeFiller.z = 1.12
//        holeFiller.e = 0.01
        holeFiller.z = 2.42
        holeFiller.e = 0.0001
        
        // Create a hole in the image data
        holeFiller.createSquareHole(at: Point2D(260, 160), size: Size2D(100, 100))
        
        let debug = holeFiller.printImageArray()
        //print(debug)
        
        // Act
        holeFiller.findHole()
        holeFiller.fillHole()
        
        let outputImage = ImageConverter.convert2DPixelArrayToImage(array2D: holeFiller.image, width: width, height: height)
        
        // Assert
        //XCTAssertEqual(holeFiller.boundaryPixelCount, 12)
    }
    
}
