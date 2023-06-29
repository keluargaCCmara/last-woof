//
//  EpilogueScene.swift
//  Last Woof
//
//  Created by Angela Christabel on 20/06/23.
//

import Foundation
import SpriteKit
import GameplayKit

class StoryScene: SKScene {
    var sceneFrames: [SKTexture] = []
    var nFrames: Int = 0
    var sceneName: String = ""
    private var timeRemaining = 12
    
    var epilogueFrame: SKNode!
    
    override func didMove(to view: SKView) {
        for i in 1...nFrames {
            self.sceneFrames.append(SKTexture(imageNamed: "\(sceneName)\(i)"))
        }
        
        let entity = GKEntity()
        
        let vc = VisualComponent(imageName: "\(sceneName)1", size: CGSize(
            width: 1,
            height: 1),
                                 position: CGPoint(x: 0.5, y: 0.5), zPosition: .zero, zRotation: .zero)
        entity.addComponent(vc)
        
        setupAnimation(node: vc.visualNode)
        startTimer()
        
        self.addChild(vc.visualNode)
        
    }
    func startTimer() {
        // Create a timer that fires every second

        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if timeRemaining > 1 {
            print(timeRemaining)
            timeRemaining -= 1
        } else if timeRemaining > 0 {
            print(timeRemaining)
            timeRemaining -= 1
            let smokeParticleRight = SKEmitterNode(fileNamed: "SubHomeSmoke")!
            smokeParticleRight.position = CGPoint(x: frame.minX, y: frame.midY)
            smokeParticleRight.run(SKAction.moveTo(x: frame.midX, duration: 0.5))
            smokeParticleRight.zPosition = 99
            addChild(smokeParticleRight)
            let smokeParticleLeft = SKEmitterNode(fileNamed: "SubHomeSmoke")!
            smokeParticleLeft.position = CGPoint(x: frame.maxX, y: frame.midY)
            smokeParticleLeft.run(SKAction.moveTo(x: frame.midX, duration: 0.5))
            smokeParticleLeft.zPosition = 99
            addChild(smokeParticleLeft)
        } else if timeRemaining == 0 {
            print(timeRemaining)
            timeRemaining = -100
            let transition = SKTransition.fade(with: .white, duration: 0)
            let scene = GameScene(fileNamed: "GameScene")!
            self.view?.presentScene(scene, transition: transition)
        }
    }
    
    func setupAnimation(node: SKSpriteNode) {
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let frames = SKAction.animate(with: sceneFrames, timePerFrame: 3.0)
        
        let seq = SKAction.sequence([fadeIn, SKAction.wait(forDuration:2.0), fadeOut])
        let group = SKAction.group([SKAction.repeat(seq, count: nFrames), frames])
        
        node.run(group)
    }
}
