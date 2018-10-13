//
//  Logger.swift
//  HoleFramework
//
//  Created by Chris Davis on 11/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import Foundation

/**
 prints to the console, if in DEBUG mode
 */
public func DLog(_ message:Any)
{
    #if DEBUG
    print(message)
    #endif
}
