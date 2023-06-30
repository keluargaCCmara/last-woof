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
    var categoryBitMask: UInt32
    var collisionBitMask: UInt32
    var contactTestBitMask: UInt32
    
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
            let vn = visualComponent.visualNode
            if imageName == "DummyCharacter" {
                let x = 0.0
                let y = -vn.size.height/2 + 40
            
//                vn.physicsBody? = SKPhysicsBody(texture: texture, size: size)
//                vn.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: vn.size.width, height: vn.size.height/2), center: CGPoint(x: x, y: y))
                vn.physicsBody = SKPhysicsBody(circleOfRadius: 20, center: CGPoint(x: x, y: y))
            } else if imageName == "Terrace" {
                vn.physicsBody = SKPhysicsBody(rectangleOf: vn.size)
            } else {
                vn.physicsBody = SKPhysicsBody(texture: texture, size: size)
            }
            vn.physicsBody?.isDynamic = isDynamic
            vn.physicsBody?.categoryBitMask = categoryBitMask
            vn.physicsBody?.collisionBitMask = collisionBitMask
            vn.physicsBody?.contactTestBitMask = contactTestBitMask
            vn.physicsBody?.affectedByGravity = false
            vn.physicsBody?.allowsRotation = false
            
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
