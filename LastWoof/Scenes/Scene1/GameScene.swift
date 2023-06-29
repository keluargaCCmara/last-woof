//
//  GameScene.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 15/06/23.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let object: UInt32 = 0b1
    static let character: UInt32 = 0b10
    static let obstacle: UInt32 = 0b100
}

protocol PhysicsContactDelegate: AnyObject {
    func didBegin(_ contact: SKPhysicsContact)
}

class GameScene: SKScene, SKPhysicsContactDelegate, PhysicsContactDelegate {
    private var cameraNode: SKCameraNode = SKCameraNode()
    private var background: SKSpriteNode?
    private var entities: [GKEntity] = []
    private var character: SKSpriteNode?
    
    private let characterMovePointsPerSec: CGFloat = 480.0
    private var characterVelocity = CGPoint.zero
    
    private var lastUpdateTime: TimeInterval = 0
    private var dt: TimeInterval = 0
    
    private var lastTouchLocation: CGPoint?
    
    private var isColliding: Bool = false
    private var lastDidBeginTime: TimeInterval = 0
    
    let physicsComponentSystem = GKComponentSystem(componentClass: PhysicsComponent.self)
    
    override func didMove(to view: SKView) {
        
        let whiteRectangle = SKSpriteNode(color: .white, size: CGSize(width: frame.size.width, height: frame.size.height))
            whiteRectangle.position = CGPoint(x: 0, y: 0)
            whiteRectangle.alpha = 1.0
            whiteRectangle.zPosition = 1000
            addChild(whiteRectangle)
            
            let fadeOutAction = SKAction.fadeOut(withDuration: 1.0)
            whiteRectangle.run(fadeOutAction)
        
        physicsWorld.contactDelegate = self
        guard let backgroundNode = childNode(withName: "background") as? SKSpriteNode else {
            fatalError("Background node not found in .sks file")
        }
        self.background = backgroundNode
        self.background?.zPosition = -1
        
        character = generateCharacter(imagedName: "DummyCharacter", width: 100, height: 100, xPosition: 0, yPosition: 0, zPosition: 1, zRotation: 0, isDynamic: true)
        addChild(character!)
        
        cameraNode.position = character!.position
        
        let pond = generateEntity(components: [
            VisualComponent(imageName: "Pond", size: CGSize(width: 1604, height: 844), position: CGPoint(x: 1647, y: -1217), zPosition: 2, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1604, height: 844), imageName: "Pond", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ])
        
        let plant1 = generateEntity(components: [
            VisualComponent(imageName: "Plant1-Task", size: CGSize(width: 1288, height: 651), position: CGPoint(x: 1777, y: 325), zPosition: 2, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1288, height: 651), imageName: "Plant1-Task", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ])
        
        let plant2 = generateEntity(components: [
            VisualComponent(imageName: "Plant2-Decoration", size: CGSize(width: 1097, height: 617), position: CGPoint(x: 1932, y: -651), zPosition: 2, zRotation: -90),
            PhysicsComponent(size: CGSize(width: 1097, height: 617), imageName: "Plant2-Decoration", isDynamic: false, categoryBitMask: PhysicsCategory.obstacle, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ])
        
        let fence = generateEntity(components: [
            VisualComponent(imageName: "Fence", size: CGSize(width: 1340, height: 2481), position: CGPoint(x: 2105, y: -519), zPosition: 1, zRotation: 0),
            PhysicsComponent(size: CGSize(width: 1340, height: 2481), imageName: "Fence", isDynamic: false, categoryBitMask: PhysicsCategory.object, collisionBitMask: PhysicsCategory.character, contactTestBitMask: PhysicsCategory.character)
        ])
        
        entities = [pond, plant1, plant2, fence]
        entities.forEach { entity in
            if let visualComponent = entity.component(ofType: VisualComponent.self) {
                addChild(visualComponent.visualNode)
                physicsComponentSystem.addComponent(foundIn: entity)
            }
        }
    }
    
    private func generateEntity(components: [GKComponent]) -> GKEntity {
        let entity = GKEntity()
        components.forEach { component in
            entity.addComponent(component)
        }
        return entity
    }
    
    private func generateCharacter(imagedName: String, width: Double, height: Double, xPosition: Double, yPosition: Double, zPosition: CGFloat, zRotation: CGFloat, isDynamic: Bool, allowsRotation: Bool = false) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: imagedName)
        let textureSize = CGSize(width: width, height: height)
        let entity = SKSpriteNode(texture: texture, size: textureSize)
        entity.physicsBody = SKPhysicsBody(texture: texture, size: textureSize)
        entity.physicsBody?.isDynamic = isDynamic
        entity.physicsBody?.allowsRotation = allowsRotation
        entity.physicsBody?.affectedByGravity = false
        entity.physicsBody?.categoryBitMask = PhysicsCategory.character
        entity.physicsBody?.collisionBitMask = PhysicsCategory.obstacle | PhysicsCategory.object
        entity.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle
        entity.position = CGPoint(x: xPosition, y: yPosition)
        entity.zPosition = zPosition
        entity.zRotation = zRotation * CGFloat.pi / 180
        
        return entity
    }
    
    private func boundsCheckCharacter() {
        let minX = background!.position.x - background!.size.width / 2 + character!.size.width / 2
        let minY = background!.position.y - background!.size.height / 2 + character!.size.height / 2
        let maxX = background!.position.x + background!.size.width / 2 - character!.size.width / 2
        let maxY = background!.position.y + background!.size.height / 2 - character!.size.height / 2
        
        if character!.position.x < minX {
            character!.position.x = minX
        } else if character!.position.x > maxX {
            character!.position.x = maxX
        }
        
        if character!.position.y < minY {
            character!.position.y = minY
        } else if character!.position.y > maxY {
            character!.position.y = maxY
        }
    }
    
    private func boundsCheckCamera() {
        let minX = background!.position.x - background!.size.width / 2 + size.width / 2
        let minY = background!.position.y - background!.size.height / 2 + size.height / 2
        let maxX = background!.position.x + background!.size.width / 2 - size.width / 2
        let maxY = background!.position.y + background!.size.height / 2 - size.height / 2
        
        let cameraX = cameraNode.position.x
        let cameraY = cameraNode.position.y
        
        if cameraX < minX {
            cameraNode.position.x = minX
        } else if cameraX > maxX {
            cameraNode.position.x = maxX
        }
        
        if cameraY < minY {
            cameraNode.position.y = minY
        } else if cameraY > maxY {
            cameraNode.position.y = maxY
        }
    }
    
    func moveCharacterToward(location: CGPoint) {
        let offset = CGPoint(x: location.x - character!.position.x, y: location.y - character!.position.y)
        let xSquared = offset.x * offset.x
        let ySquared = offset.y * offset.y
        let sumOfSquares = xSquared + ySquared
        let length = sqrt(Double(sumOfSquares))
        
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        
        characterVelocity = CGPoint(x: direction.x * characterMovePointsPerSec, y: direction.y * characterMovePointsPerSec)
    }
    
    func moveCharacter(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
        
        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        lastTouchLocation = touchLocation
        moveCharacterToward(location: touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        lastTouchLocation = touchLocation
        moveCharacterToward(location: touchLocation)
    }
    
    override func update(_ currentTime: TimeInterval) {
        physicsComponentSystem.update(deltaTime: currentTime)
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        if let lastTouchLocation = lastTouchLocation {
            let diff = CGPoint(x: lastTouchLocation.x - character!.position.x, y: lastTouchLocation.y - character!.position.y )
            let diffLength = hypot(diff.x, diff.y)
            if (diffLength <= characterMovePointsPerSec * CGFloat(dt)) {
                character!.position = lastTouchLocation
                characterVelocity = CGPointZero
            } else {
                moveCharacter(sprite: character!, velocity: characterVelocity)
            }
        }
        cameraNode.position = character!.position
        scene?.camera = cameraNode
        boundsCheckCamera()
        let elapsedDidBeginTime = currentTime - lastDidBeginTime
        if elapsedDidBeginTime > 0.5 {
            isColliding = false
//            print("Character separated with obstacle")
        }
    }
        
    // MARK: PhysicsContactDelegate Protocol
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        self.lastDidBeginTime = CACurrentMediaTime()

        if collision == PhysicsCategory.character | PhysicsCategory.obstacle {
            isColliding = true
            handleCharacterObstacleCollision(contact: contact)
        }
    }
    
//    func didEnd(_ contact: SKPhysicsContact) {
//        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
//
//        if collision == PhysicsCategory.character | PhysicsCategory.obstacle {
////            handleCharacterObstacleSeparation(contact: contact)
//        }
//    }
    
    private func handleCharacterObstacleCollision(contact: SKPhysicsContact) {
        let characterNode = contact.bodyA.categoryBitMask == PhysicsCategory.character ? contact.bodyA.node : contact.bodyB.node
        let obstacleNode = contact.bodyA.categoryBitMask == PhysicsCategory.obstacle ? contact.bodyA.node : contact.bodyB.node
        
        // Perform actions or logic when character collides with an obstacle
        print("Character collided with obstacle")
        
    }
    
    private func handleCharacterObstacleSeparation(contact: SKPhysicsContact) {
        print("Character separated with obstacle")
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - self.x
        let dy = point.y - self.y
        return sqrt(dx*dx + dy*dy)
    }
}
