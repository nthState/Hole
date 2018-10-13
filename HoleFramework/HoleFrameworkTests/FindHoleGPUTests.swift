//
//  FindHoleGPUTests.swift
//  HoleFrameworkTests
//
//  Created by Chris Davis on 13/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import XCTest
@testable import HoleFramework

class FindHoleGPUTests: XCTestCase {
    
    func test_square_boundary_found() {
        
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
        
        let holeFiller = HoleFillerGPU(image: imageData)
        
        // Act
        holeFiller.findHole()
        
        
    }
}
