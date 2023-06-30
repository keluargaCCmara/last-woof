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
    private var timerLabel: SKLabelNode?
    private var timeRemaining = 10.5 // Initial time in seconds
    private var timer: Timer?


    
    override func didMove(to view: SKView) {
        AudioManager.shared.playAudio(fileName: "BGM For Menu", isBGM: true)
        self.backgroundColor = SKColor.white
        guard let backgroundNode = childNode(withName: "background") as? SKSpriteNode else {
            fatalError("Background node not found in .sks file")
        }
        
        print(frame.size)
        
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
    
        startTimer()
    }
    
    func startTimer() {
        // Create a timer that fires every second
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {

        if timeRemaining > 3 {
            timeRemaining -= 1
        } else if timeRemaining >= 2.5 {
            // Time's up, stop the timer
            timeRemaining -= 1
            print(timeRemaining)
            let smokeParticleRight = SKEmitterNode(fileNamed: "SubHomeSmoke")!
            smokeParticleRight.position = CGPoint(x: frame.minX, y: frame.midY)
            smokeParticleRight.run(SKAction.moveTo(x: frame.midX, duration: 1.5))
            smokeParticleRight.zPosition = 99
            addChild(smokeParticleRight)
            
            let smokeParticleLeft = SKEmitterNode(fileNamed: "SubHomeSmoke")!
            smokeParticleLeft.position = CGPoint(x: frame.maxX, y: frame.midY)
            smokeParticleLeft.run(SKAction.moveTo(x: frame.midX, duration: 1.5))
            smokeParticleLeft.zPosition = 99
            addChild(smokeParticleLeft)
        } else if timeRemaining >= 0.5 {
            timeRemaining = -100
            
            let transition = SKTransition.fade(with: .white, duration: 1)
            let scene = MainMenu(fileNamed: "MainMenu")!
            self.view?.presentScene(scene, transition: transition)
        }
    }

}
