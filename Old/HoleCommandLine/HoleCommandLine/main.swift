//
//  main.swift
//  HoleCommandLine
//
//  Created by Chris Davis on 13/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import Foundation
import HoleFrameworkMacOS

func main() {
    
    let arguments = CommandLine.arguments
    let c = CommandLine.argc
    if arguments.count == 1 {
        showHelp()
    }
    
    let argument = arguments[0]
    let x = argument.substring(from: argument.index(argument.startIndex, offsetBy: 1))
    
    
}

func showHelp() {
    log("Help:")
    log("--image Path to an image")
    log("--z power")
    log("--e epslion")
    log("--hole Rectangle co-ordinates")
    log("")
    log("Example:")
    log("HoleCommandLine --image MyGreyScaleImage.png --z 1.12 --e 0.01 --hole 30 30 100 100")
}

func log(_ str: String) {
    print(str)
}

main()

