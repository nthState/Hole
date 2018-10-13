//
//  GameScene.swift
//  HoleApp
//
//  Created by Chris Davis on 11/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import SpriteKit
import GameplayKit
import HoleFramework

class GameScene: SKScene {
    
    let pixelSize: CGSize = CGSize(width: 32, height: 32)
    var cam: SKCameraNode!
    weak var holeFiller: HoleFiller?
    var pixelContainer: SKNode!
    
    override func didMove(to view: SKView) {
       
        setupCamera()

        
    }
    
    /**
     Configure a camera so that if the image size increases, we can easily zoom
    */
    func setupCamera() {
//        cam = SKCameraNode()
//        self.camera = cam
//        self.addChild(cam!)
    }
    
    /**
     Build grid
    */
    func buildGrid() {
        
        pixelContainer = SKNode()
        self.addChild(pixelContainer)
        
        for row in 0..<holeFiller!.rows {
            for col in 0..<holeFiller!.cols {
                
                let pixelNode: SKSpriteNode = SKSpriteNode(texture: nil, color: .red, size: pixelSize)
                pixelNode.position = CGPoint(x: CGFloat(col) * pixelSize.width, y: CGFloat(row) * pixelSize.height)
                pixelNode.name = String((row * holeFiller!.cols) + col)
                pixelContainer.addChild(pixelNode)
                
            }
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        for row in 0..<holeFiller!.rows {
            for col in 0..<holeFiller!.cols {
                let nodeName = String((row * holeFiller!.cols) + col)
                let pixelNode = self.pixelContainer.childNode(withName: nodeName) as! SKSpriteNode
                
                var color: SKColor = .red
                if holeFiller!.boundary[col][row] > 0 {
                    color = .blue
                } else {
                    color = holeFiller!.visited[col][row] > 0 ? SKColor.yellow : SKColor.red
                }
                
                pixelNode.color = color
            }
        }
    }
    
    
}
