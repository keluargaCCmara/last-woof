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
        visualNode.name = imageName
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
    
    override func update(deltaTime seconds: TimeInterval) {
        let background = SKSpriteNode(imageNamed: "Background")
        background.size = CGSize(width: 4242, height: 2167)
        background.position = CGPoint(x: 520, y: -480)
        boundsCheckCharacter(background: background)
    }
    
    private func boundsCheckCharacter(background: SKSpriteNode) {
        if ((entity?.component(ofType: MovementComponent.self)) != nil) {
            let minX = background.position.x - background.size.width / 2 + visualNode.size.width / 2
            let minY = background.position.y - background.size.height / 2 + visualNode.size.height / 2
            let maxX = background.position.x + background.size.width / 2 - visualNode.size.width / 2
            let maxY = background.position.y + background.size.height / 2 - visualNode.size.height / 2

            if visualNode.position.x < minX {
                visualNode.position.x = minX
            } else if visualNode.position.x > maxX {
                visualNode.position.x = maxX
            }

            if visualNode.position.y < minY {
                visualNode.position.y = minY
            } else if visualNode.position.y > maxY {
                visualNode.position.y = maxY
            }
        }
    }
    
}
