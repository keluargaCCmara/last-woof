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
    
    var epilogueFrame: SKNode!
    
    override func didMove(to view: SKView) {
        for i in 1...nFrames {
            self.sceneFrames.append(SKTexture(imageNamed: "\(sceneName)\(i)"))
        }
        
        let epilogueEntity = GKEntity()
        
        let vc = VisualComponent(imageName: "\(sceneName)1", size: CGSize(
            width: 1,
            height: 1),
                                 position: CGPoint(x: 0.5, y: 0.5), zPosition: .zero, zRotation: .zero)
        epilogueEntity.addComponent(vc)
            
        setupAnimation(node: vc.visualNode)
        
        self.addChild(vc.visualNode)
    }
    
    func setupAnimation(node: SKSpriteNode) {
        let fadeIn = SKAction.fadeIn(withDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let frames = SKAction.animate(with: sceneFrames, timePerFrame: 5.0)
        
        let seq = SKAction.sequence([fadeIn, SKAction.wait(forDuration:3.0), fadeOut])
        let group = SKAction.group([SKAction.repeat(seq, count: nFrames), frames])
        
        node.run(group)
    }
}
