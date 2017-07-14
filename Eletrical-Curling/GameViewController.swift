//
//  GameViewController.swift
//  Eletrical-Curling
//
//  Created by Mauricio Lorenzetti on 13/07/17.
//  Copyright © 2017 Mauricio Lorenzetti. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = true
            view.showsFields = true
            view.ignoresSiblingOrder = true
            
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                if let hudScene = GameScene(fileNamed:"Hud") {
                    if let hudNode = hudScene.childNode(withName: "hud") {
                        // transporta o hud da Hud.sks para o GameScene.sks
                        hudScene.removeFromParent()
                        hudNode.removeFromParent()
                        
                        scene.addChild(hudNode)
                        
                        hudNode.zPosition = 10
                    }
                }
                
                // Present the scene
                view.presentScene(scene)
            }
            
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
