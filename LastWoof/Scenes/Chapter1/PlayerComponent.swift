//
//  PlayerComponent.swift
//  Last Woof
//
//  Created by Angelica Patricia on 21/06/23.
//

import SpriteKit
import GameplayKit

class PlayerComponent: GKComponent {
    
    let node: SKSpriteNode
    public var movementComponent: MovementComponent?
    
    init(imagedName: String, width: Double, height: Double, position: CGPoint, zPosition: CGFloat, zRotation: CGFloat, isDynamic: Bool, allowsRotation: Bool = false) {
        let texture = SKTexture(imageNamed: imagedName)
        let textureSize = CGSize(width: width, height: height)
        node = SKSpriteNode(texture: texture, size: textureSize)
        node.position = position
        node.zPosition = zPosition
        node.zRotation = zRotation * CGFloat.pi / 180
        node.physicsBody = SKPhysicsBody(texture: texture, size: textureSize)
        node.physicsBody!.isDynamic = isDynamic
        node.physicsBody!.allowsRotation = allowsRotation
        node.physicsBody!.affectedByGravity = false
        node.physicsBody!.categoryBitMask = PhysicsCategory.character
        node.physicsBody!.collisionBitMask = PhysicsCategory.obstacle | PhysicsCategory.object
        node.physicsBody!.contactTestBitMask = PhysicsCategory.obstacle
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
            movementComponent?.update(deltaTime: seconds) // Call update on movementComponent
        }
    
}

