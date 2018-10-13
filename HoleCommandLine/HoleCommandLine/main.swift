//
//  main.swift
//  HoleCommandLine
//
//  Created by Chris Davis on 13/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import Foundation
import HoleFramework

func main() {
    
    let arguments = CommandLine.arguments

    if arguments.count == 1 {
        return showHelp()
    }
    
    if arguments.count < 11 {
        log("Not all arguments supplied")
        return showHelp()
    }
    
    var parameters = HoleParameters()
    
    for arg in 1..<arguments.count {
    
        let argument = arguments[arg]
    
        switch argument {
        case "-i":
            parameters.inputImage = arguments[arg + 1]
        case "-z":
            parameters.z = Float(arguments[arg + 1])
        case "-e":
            parameters.e = Float(arguments[arg + 1])
        case "-h":
            let hole = arguments[arg + 1].split(separator: ",")
            parameters.holeAt = Point2D(Int(hole[0])!, Int(hole[1])!)
            parameters.holeSize = Size2D(Int(hole[2])!, Int(hole[3])!)
        case "-o":
            parameters.outputImage = arguments[arg + 1]
        default:
            break
        }

    }
    
    run(with: parameters)
    
}

func run(with parameters: HoleParameters) {
    
    guard let cgImage = ImageConverter.pathToCGImage(path: parameters.inputImage) else {
        return log("Couldn't load/find \(String(describing: parameters.inputImage))")
    }
    
    let (imageData, width, height) = ImageConverter.convertImageTo2DPixelArray(cgImage: cgImage)
    
    let holeFiller = HoleFiller(image: imageData)
    holeFiller.z = parameters.z
    holeFiller.e = parameters.e
    
    // Create a hole
    holeFiller.createSquareHole(at: parameters.holeAt, size: parameters.holeSize)
    
    // Find hole
    holeFiller.findHole()
    
    // Fill hole
    holeFiller.fillHole()
    
    // Output image
    let outputCGImage = ImageConverter.convert2DPixelArrayToImage(array2D: holeFiller.image, width: width, height: height)
    
    guard let newImage = outputCGImage else {
        return log("Image could not be created")
    }
    
    let success = ImageConverter.save(cgImage: newImage, to: parameters.outputImage)
    
    log("Image save to: \(String(describing: parameters.outputImage))? \(success)")
}

func showHelp() {
    log("Help:")
    log("-i, Path to an image")
    log("-z, pow for weighting function")
    log("-e, epslion value, small positive")
    log("-h, Rectangle co-ordinates for a hole, x,y,width,height")
    log("-o, Path to save computed image to")
    log("")
    log("Example:")
    log("HoleCommandLine -i /path/to/MyGreyScaleImage.png -z 1.12 -e 0.0001 -hole 30,30,100,100 -o /path/to/MyNewGreyScaleImage.png")
}

func log(_ str: String) {
    print(str)
}

main()

