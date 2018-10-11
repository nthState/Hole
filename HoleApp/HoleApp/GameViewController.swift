//
//  GameViewController.swift
//  HoleApp
//
//  Created by Chris Davis on 11/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import HoleFramework

class GameViewController: UIViewController {
    
    @IBOutlet weak var skView: SKView!
    var scene: GameScene!
    var holeFiller: HoleFiller!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildHoleFiller()
        
        scene = GameScene(fileNamed: "GameScene")
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
        
        
        scene.holeFiller = holeFiller
        scene.buildGrid()
        
        
    }

    func buildHoleFiller() {
        
        // Arrange
        let imageData: [[Float]] = [
            [ 0, 0, 0, 0, 0, 0, 0, 0],
            [ 0, 0,-1,-1,-1, 0, 0, 0],
            [ 0, 0,-1,-1,-1,-1, 0, 0],
            [ 0, 0,-1,-1,-1,-1,-1, 0],
            [ 0, 0, 0,-1,-1,-1,-1, 0],
            [ 0, 0, 0, 0, 0,-1, 0, 0],
            [ 0, 0, 0, 0, 0, 0, 0, 0],
            [ 0, 0, 0, 0, 0, 0, 0, 0]
        ]
        
        holeFiller = HoleFiller(image: imageData)

    }
}

extension GameViewController {
    
    @IBAction func onStart(sender: UIButton) {
        DispatchQueue.global(qos: .background).async {
            self.holeFiller.findHole()
        }
    }
    
}
