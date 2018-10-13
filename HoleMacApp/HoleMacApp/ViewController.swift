//
//  ViewController.swift
//  HoleMacApp
//
//  Created by Chris Davis on 13/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import Cocoa
import HoleFramework

class ViewController: NSViewController {

    @IBOutlet weak var originalImageView: NSImageView!
    @IBOutlet weak var processedImageView: NSImageView!
    
    @IBOutlet weak var filePathTextField: NSTextField!
    @IBOutlet weak var errorTextField: NSTextField!
    
    @IBOutlet weak var holeAtXTextField: NSTextField!
    @IBOutlet weak var holeAtYTextField: NSTextField!
    @IBOutlet weak var holeSizeWidthTextField: NSTextField!
    @IBOutlet weak var holeSizeHeightTextField: NSTextField!
    
    @IBOutlet weak var zTextField: NSTextField!
    @IBOutlet weak var eTextField: NSTextField!
    
    var parameters = HoleParameters()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let bundle = Bundle.main
        parameters.inputImage = bundle.path(forResource: "defaultImage", ofType: "png")
        filePathTextField.stringValue = parameters.inputImage
        loadOriginal()
    }
    
    func loadOriginal() {
        originalImageView.image = NSImage(contentsOfFile: parameters.inputImage)
    }

    /**
     Run HoleFiller
    */
    @IBAction func onGoPress(sender: NSButton) {
        
        log("Processing image, please wait")
        
        parameters.holeAt = Point2D(Int(holeAtXTextField.stringValue)!, Int(holeAtYTextField.stringValue)!)
        parameters.holeSize = Size2D(Int(holeSizeWidthTextField.stringValue)!, Int(holeSizeHeightTextField.stringValue)!)
        parameters.z = Float(zTextField.stringValue)
        parameters.e = Float(eTextField.stringValue)
        
        DispatchQueue.global(qos: .background).async {
            self.processImage()
        }
    }
    
    func processImage() {
        
        guard let cgImage = ImageConverter.pathToCGImage(path: parameters.inputImage) else {
            return log("Couldn't load/find \(String(describing: parameters.inputImage))")
        }
        
        let (imageData, width, height) = ImageConverter.convertImageTo2DPixelArray(cgImage: cgImage)
        
        let holeFiller = HoleFiller(image: imageData)
        holeFiller.z = parameters.z
        holeFiller.e = parameters.e
        
        holeFiller.createSquareHole(at: parameters.holeAt, size: parameters.holeSize)
        
        holeFiller.findHole()
        
        holeFiller.fillHole()
        
        let outputCGImage = ImageConverter.convert2DPixelArrayToImage(array2D: holeFiller.image, width: width, height: height)
        
        guard let newImage = outputCGImage else {
            return log("Image could not be created")
        }
        
        DispatchQueue.main.async {
            self.processedImageView.image = NSImage(cgImage: newImage, size: NSSize(width: width, height: height))
            self.clearLog()
        }
    }
    
    func clearLog() {
        errorTextField.stringValue = ""
    }
    
    func log(_ str: String) {
        errorTextField.stringValue = str
    }

}

extension ViewController : NSOpenSavePanelDelegate {
    
    @IBAction func onChangeImages(sender: NSButton) {
        
        let openPanel = NSOpenPanel()
        openPanel.delegate = self
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.title = "Open"
        openPanel.begin { (response) in
            if response == NSApplication.ModalResponse.OK {
                
                guard let path =  openPanel.url?.path else { return }
                self.parameters.inputImage = path
                self.filePathTextField.stringValue = path
                self.loadOriginal()
            }
        }
        
    }
    
}
