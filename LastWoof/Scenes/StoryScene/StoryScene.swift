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
    private var timeRemaining: Int = 0
    
    var epilogueFrame: SKNode!
    
    override func didMove(to view: SKView) {
        for i in 1...nFrames {
            self.sceneFrames.append(SKTexture(imageNamed: "\(sceneName)\(i)"))
        }
        
        print(frame.size)
        
        let entity = GKEntity()
        
        let vc = VisualComponent(imageName: "\(sceneName)1", size: CGSize(
            width: 844,
            height: 390),
                                 position: CGPoint(x: frame.midX, y: frame.midY), zPosition: .zero, zRotation: .zero)
        entity.addComponent(vc)
        
        setupAnimation(node: vc.visualNode)
        startTimer()
        

        
        self.addChild(vc.visualNode)
        
    }
    func startTimer() {
        // Create a timer that fires every second

        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        if sceneName == "Prologue" {
                timeRemaining = 67
            } else if sceneName.starts(with: "Chapter1-") {
                timeRemaining = 20
            }
    }
    
    @objc func updateTimer() {
        
        if timeRemaining == 40 {
            let whiteRectangle = SKSpriteNode(color: .white, size: CGSize(width: frame.size.width, height: frame.size.height))
            whiteRectangle.position = CGPoint(x: frame.midX, y: frame.midY)
            whiteRectangle.alpha = 1.0
            whiteRectangle.zPosition = -1
            addChild(whiteRectangle)
            timeRemaining -= 1
        } else if timeRemaining > 2 {
            if sceneName == "Chapter1-" {
                let whiteRectangle = SKSpriteNode(color: .white, size: CGSize(width: frame.size.width, height: frame.size.height))
                whiteRectangle.position = CGPoint(x: frame.midX, y: frame.midY)
                whiteRectangle.alpha = 1.0
                whiteRectangle.zPosition = -1
                addChild(whiteRectangle)
            }
            print(timeRemaining)
            timeRemaining -= 1
        } else if timeRemaining == 2 {
            print(timeRemaining)
            print("smoke")
            print(frame.size)
            timeRemaining -= 1
            let smokeParticleRight = SKEmitterNode(fileNamed: "SubHomeSmoke")!
            smokeParticleRight.position = CGPoint(x: frame.minX, y: frame.midY)
            smokeParticleRight.run(SKAction.moveTo(x: frame.midX, duration: 2))
            smokeParticleRight.zPosition = 99
            addChild(smokeParticleRight)
            
            let smokeParticleLeft = SKEmitterNode(fileNamed: "SubHomeSmoke")!
            smokeParticleLeft.position = CGPoint(x: frame.maxX, y: frame.midY)
            smokeParticleLeft.run(SKAction.moveTo(x: frame.midX, duration: 2))
            smokeParticleLeft.zPosition = 99
            addChild(smokeParticleLeft)
        } else if timeRemaining == 1 {
            timeRemaining -= 1
        } else if timeRemaining == 0 {
            timeRemaining = -100
            print(timeRemaining)
            let scene = GameScene(fileNamed: "GameScene")!
            self.view?.presentScene(scene)
        }
    }
    
    func setupAnimation(node: SKSpriteNode) {
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let frames = SKAction.animate(with: sceneFrames, timePerFrame: 4.0)
        
        let seq = SKAction.sequence([fadeIn, SKAction.wait(forDuration:3.0), fadeOut])
        let group = SKAction.group([SKAction.repeat(seq, count: nFrames), frames])
        
        node.run(group)
    }
}
