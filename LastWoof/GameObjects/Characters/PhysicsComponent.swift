//
//  PhysicsComponent.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 21/06/23.
//

import SpriteKit
import GameplayKit

class PhysicsComponent: GKComponent {
    
    var visualComponent: VisualComponent? {
        return entity?.component(ofType: VisualComponent.self)
    }
    
    var nodeHasPhysics: Bool = false
    let texture: SKTexture
    let size: CGSize
    let imageName: String
    let isDynamic: Bool
    let categoryBitMask: UInt32
    let collisionBitMask: UInt32
    let contactTestBitMask: UInt32
    
    init(size: CGSize, imageName: String, isDynamic: Bool, categoryBitMask: UInt32, collisionBitMask: UInt32, contactTestBitMask: UInt32) {
        self.texture = SKTexture(imageNamed: imageName)
        self.size = size
        self.imageName = imageName
        self.isDynamic = isDynamic
        self.categoryBitMask = categoryBitMask
        self.collisionBitMask = collisionBitMask
        self.contactTestBitMask = contactTestBitMask
        super.init()
        addPhysics()
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        addPhysics()
    }
    
    private func addPhysics() {
        if let visualComponent = visualComponent, !nodeHasPhysics {
            visualComponent.visualNode.physicsBody = SKPhysicsBody(texture: texture, size: size)
            visualComponent.visualNode.physicsBody?.isDynamic = isDynamic
            visualComponent.visualNode.physicsBody?.categoryBitMask = categoryBitMask
            visualComponent.visualNode.physicsBody?.collisionBitMask = collisionBitMask
            visualComponent.visualNode.physicsBody?.contactTestBitMask = contactTestBitMask
            visualComponent.visualNode.physicsBody?.affectedByGravity = false
            visualComponent.visualNode.physicsBody?.allowsRotation = false
            nodeHasPhysics = true
        }
    }
    
    func removePhysics() {
        visualComponent?.visualNode.physicsBody = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
