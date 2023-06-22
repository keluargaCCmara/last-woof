//
//  CreditsScene.swift
//  Last Woof
//
//  Created by Angelica Patricia on 22/06/23.
//

import SpriteKit
import GameplayKit

class CreditsScene: SKScene {
    private var background: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = SKColor.white
        
        guard let backgroundNode = childNode(withName: "background") as? SKSpriteNode else {
            fatalError("Background node not found in .sks file")
        }
        self.background = backgroundNode
        self.background?.zPosition = -1
        self.background?.alpha = 0
        
        
        let waitAction = SKAction.wait(forDuration: 0.5)
           let fadeInAction = SKAction.fadeAlpha(to: 1.0, duration: 1.0)
           let sequence = SKAction.sequence([waitAction, fadeInAction])
           self.background?.run(sequence)
    }
}
