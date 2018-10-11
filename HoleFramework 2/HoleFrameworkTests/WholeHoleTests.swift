//
//  HoleFrameworkTests.swift
//  HoleFrameworkTests
//
//  Created by Chris Davis on 10/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import XCTest
@testable import HoleFramework

class WholeHoleTests : XCTestCase {

    func test_whole_image_is_a_hole() {
        
        // Arrange
        let imageData: [[Float]] = [
            [-1,-1,-1,-1,-1,-1,-1,-1],
            [-1,-1,-1,-1,-1,-1,-1,-1],
            [-1,-1,-1,-1,-1,-1,-1,-1],
            [-1,-1,-1,-1,-1,-1,-1,-1],
            [-1,-1,-1,-1,-1,-1,-1,-1],
            [-1,-1,-1,-1,-1,-1,-1,-1],
            [-1,-1,-1,-1,-1,-1,-1,-1],
            [-1,-1,-1,-1,-1,-1,-1,-1]
        ]
        
        let holeFiller = HoleFiller(image: imageData)
        
        // Act
        holeFiller.findHole()
        
        // Assert
        let expectedData: [[Float]] = [
            [2,2,2,2,2,2,2,2],
            [2,2,2,2,2,2,2,2],
            [2,2,2,2,2,2,2,2],
            [2,2,2,2,2,2,2,2],
            [2,2,2,2,2,2,2,2],
            [2,2,2,2,2,2,2,2],
            [2,2,2,2,2,2,2,2],
            [2,2,2,2,2,2,2,2]
        ]
        XCTAssertEqual(holeFiller.image, expectedData, "Data should match")
    }

}
