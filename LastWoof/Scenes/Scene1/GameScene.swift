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
    //    func didEnd(_ contact: SKPhysicsContact)
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
    
    let velocityMultiplier: CGFloat = 0.0375
    lazy var analogJoystick: AnalogJoystick = {
        let js = AnalogJoystick(diameter: 300, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jStick")))
        js.position = CGPoint(x: -450, y: -400)
        js.zPosition = 2
        return js
    }()
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        guard let backgroundNode = childNode(withName: "background") as? SKSpriteNode else {
            fatalError("Background node not found in .sks file")
        }
        self.background = backgroundNode
        self.background?.zPosition = -1
        
        character = generateCharacter(imagedName: "DummyCharacter", width: 200, height: 200, xPosition: 140, yPosition: -183, zPosition: 1, zRotation: 0, isDynamic: true)
        addChild(character!)
        
        cameraNode.position = character!.position
        
        setupJoystick()
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        lastTouchLocation = touchLocation
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        lastTouchLocation = touchLocation
    }
    
    override func update(_ currentTime: TimeInterval) {
        physicsComponentSystem.update(deltaTime: currentTime)
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        cameraNode.position = character!.position
        scene?.camera = cameraNode
        boundsCheckCamera()
        let elapsedDidBeginTime = currentTime - lastDidBeginTime
        if elapsedDidBeginTime > 0.5 {
            isColliding = false
                        print("Character separated with obstacle")
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
    
    func setupJoystick() {
        addChild(analogJoystick)
        analogJoystick.trackingHandler = { [unowned self] data in
            self.character!.position = CGPoint(x: self.character!.position.x + (data.velocity.x * self.velocityMultiplier),
                                           y: self.character!.position.y + (data.velocity.y * self.velocityMultiplier))
            self.character!.zRotation = data.angular
            
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
            
       
            self.analogJoystick.position = CGPoint(x: cameraX - 600 + (data.velocity.x * self.velocityMultiplier),
                                                  y: cameraY - 220 + (data.velocity.y * self.velocityMultiplier))
            print(analogJoystick.position)
            
        }
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - self.x
        let dy = point.y - self.y
        return sqrt(dx*dx + dy*dy)
    }
}
