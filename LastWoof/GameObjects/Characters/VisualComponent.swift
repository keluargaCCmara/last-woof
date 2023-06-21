//
//  VisualComponent.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 19/06/23.
//

import SpriteKit
import GameplayKit

class VisualComponent: GKComponent {
    
    let visualNode: SKSpriteNode
    
    init(imageName: String, size: CGSize, position: CGPoint, zPosition: CGFloat, zRotation: CGFloat) {
        visualNode = SKSpriteNode(imageNamed: imageName)
        visualNode.size = size
        visualNode.position = position
        visualNode.zPosition = zPosition
        visualNode.zRotation = zRotation * CGFloat.pi / 180
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveCharacter(_ data: AnalogJoystickData, velocityMultiplier: CGFloat) {
        visualNode.position = CGPoint(x: visualNode.position.x + (data.velocity.x * velocityMultiplier),
                                           y: visualNode.position.y + (data.velocity.y * velocityMultiplier))
        visualNode.zRotation = data.angular
    }
    
}
