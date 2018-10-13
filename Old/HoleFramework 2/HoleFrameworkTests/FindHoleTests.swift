//
//  FindHoleTests.swift
//  HoleFrameworkTests
//
//  Created by Chris Davis on 11/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import XCTest
@testable import HoleFramework

class FindHoleTests: XCTestCase {

    func test_whole_image_is_a_hole() {
        
        // Arrange
        let imageData: [[Float]] = [
            [ 0, 0, 0, 0, 0, 0, 0, 0],
            [ 0, 0,-1,-1,-1, 0, 0, 0],
            [ 0, 0,-1,-1,-1, 0, 0, 0],
            [ 0, 0,-1,-1,-1, 0, 0, 0],
            [ 0, 0, 0, 0, 0, 0, 0, 0],
            [ 0, 0, 0, 0, 0, 0, 0, 0],
            [ 0, 0, 0, 0, 0, 0, 0, 0],
            [ 0, 0, 0, 0, 0, 0, 0, 0]
        ]
        
        let holeFiller = HoleFiller(image: imageData)
        
        // Act
        holeFiller.findHole()
        
        // Assert
        let expectedData: [[Float]] = [
            [ 0, 1, 1, 1, 1, 1, 0, 0],
            [ 0, 1, 0, 0, 0, 1, 0, 0],
            [ 0, 1, 0, 0, 0, 1, 0, 0],
            [ 0, 1, 0, 0, 0, 1, 0, 0],
            [ 0, 1, 1, 1, 1, 1, 0, 0],
            [ 0, 0, 0, 0, 0, 0, 0, 0],
            [ 0, 0, 0, 0, 0, 0, 0, 0],
            [ 0, 0, 0, 0, 0, 0, 0, 0]
        ]
        XCTAssertEqual(holeFiller.boundary, expectedData, "Boundary should have been found")
    }

}
