//
//  VisualComponent.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 19/06/23.
//

import SpriteKit
import GameplayKit

class VisualComponent: GKComponent {
    
    let node: SKSpriteNode
    
    init(imageName: String, size: CGSize, position: CGPoint, zPosition: CGFloat, zRotation: CGFloat, isDynamic: Bool, categoryBitMask: UInt32, collisionBitMask: UInt32, contactTestBitMask: UInt32) {
        let texture = SKTexture(imageNamed: imageName)
        node = SKSpriteNode(imageNamed: imageName)
        node.size = size
        node.position = position
        node.zPosition = zPosition
        node.zRotation = zRotation * CGFloat.pi / 180
        node.physicsBody = SKPhysicsBody(texture: texture, size: size)
        node.physicsBody!.isDynamic = isDynamic
        node.physicsBody!.categoryBitMask = categoryBitMask
        node.physicsBody!.collisionBitMask = collisionBitMask
        node.physicsBody!.contactTestBitMask = contactTestBitMask
        node.physicsBody!.affectedByGravity = false
        node.physicsBody!.allowsRotation = false
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
