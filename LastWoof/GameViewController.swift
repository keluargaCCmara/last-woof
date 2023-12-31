//
//  GameViewController.swift
//  test-game
//
//  Created by Winxen Ryandiharvin on 15/06/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let icloud = iCloudAuthController()
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "OpenedBefore")
        
        if let scene = GKScene(fileNamed: "MainMenu") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! MainMenu? {
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
//                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = false
                    view.showsNodeCount = false
                }
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
