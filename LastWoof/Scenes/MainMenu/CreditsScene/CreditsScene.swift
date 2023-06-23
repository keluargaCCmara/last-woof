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
    private var credit: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.white
        guard let backgroundNode = childNode(withName: "background") as? SKSpriteNode else {
            fatalError("Background node not found in .sks file")
        }
        self.background = backgroundNode
        self.background?.zPosition = -1
        self.background?.alpha = 0
        self.background?.position = CGPoint(x: 0, y: 0)
        self.background?.size = CGSize(width: (scene?.size.width)!, height: (scene?.size.height)!)
        
        guard let creditNode = childNode(withName: "credit") as? SKSpriteNode else {
            fatalError("Credit node not found in .sks file")
        }
        self.credit = creditNode
        self.credit?.zPosition = 1
        let waitAction = SKAction.wait(forDuration: 0.5)
        let fadeInAction = SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        let backgroundSequence = SKAction.sequence([waitAction, fadeInAction])
        self.background?.run(backgroundSequence)
        
        let moveAction = SKAction.moveTo(y: 110, duration: 10)
        let creditSequence = SKAction.sequence([waitAction, moveAction])
        self.credit?.run(creditSequence)
        
//        let waitTillEnd = SKAction.wait(forDuration: 11)
//        let smokeMove = SKAction.moveTo(x: frame.midX, duration: 2.5)
//        let smokeParticleSequence = SKAction.sequence([waitTillEnd,smokeMove])
//        let smokeParticleRight = SKEmitterNode(fileNamed: "HomeSmoke")!
//        smokeParticleRight.position = CGPoint(x: frame.minX-1300, y: frame.midY)
//        smokeParticleRight.zPosition = 99
//        smokeParticleRight.run(smokeParticleSequence)
//        addChild(smokeParticleRight)
//
//        let smokeParticleLeft = SKEmitterNode(fileNamed: "HomeSmoke")!
//        smokeParticleLeft.position = CGPoint(x: frame.maxX+1300, y: frame.midY)
//        smokeParticleLeft.zPosition = 99
//        smokeParticleLeft.run(smokeParticleSequence)
//        addChild(smokeParticleLeft)
    }
}
